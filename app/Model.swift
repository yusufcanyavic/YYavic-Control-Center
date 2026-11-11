// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation
import AppKit
import SwiftUI
import ServiceManagement

enum LightMode: String, Codable, CaseIterable, Identifiable {
    case effect, solid, keys
    var id: String { rawValue }
    var title: String { switch self { case .effect: return L("Effect"); case .solid: return L("Solid color"); case .keys: return L("Per-key") } }
}

struct KBSettings: Codable, Equatable {
    var power = true
    var mode: LightMode = .effect
    var effect: ITEEffect = .raindrop
    var speed = 3            // donanim degeri: 0 (hizli) ... 10 (yavas)
    var brightness = 36      // 0...50
    var color: ITEColor = .random
    var direction: ITEDirection = .right
    var reactive = false
    var solid = RGB(r: 255, g: 255, b: 255)
    var keys: [[RGB]] = KBSettings.uniform(RGB(r: 255, g: 255, b: 255))
    var saveToKeyboard = false
    var palette: [RGB]? = nil

    static func uniform(_ c: RGB) -> [[RGB]] {
        [[RGB]](repeating: [RGB](repeating: c, count: ITE8291.cols), count: ITE8291.rows)
    }
}

struct Profile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var settings: KBSettings
}

final class KBModel: ObservableObject {
    @Published var settings: KBSettings { didSet { settingsChanged(old: oldValue) } }
    @Published var connected = false
    @Published var firmware = ""
    @Published var profiles: [Profile] = []
    @Published var loginItem = false
    @Published var message = ""
    /// "auto" = macOS sistem dili (desteklenmiyorsa Ingilizce); aksi halde dil kodu (ornek "de")
    @Published var language: String = "auto" {
        didSet { defaults.set(language, forKey: "language"); applyLanguage() }
    }

    private let kb = ITE8291()
    private let hw = DispatchQueue(label: "yycc.hw")
    private var suppress = false
    private var applyItem: DispatchWorkItem?
    private var brightnessItem: DispatchWorkItem?
    private var timer: Timer?
    private let defaults = UserDefaults.standard

    init() {
        if let d = defaults.data(forKey: "settings"), let s = try? JSONDecoder().decode(KBSettings.self, from: d) { settings = s } else { settings = KBSettings() }
        if let d = defaults.data(forKey: "profiles"), let p = try? JSONDecoder().decode([Profile].self, from: d) { profiles = p }
        loginItem = SMAppService.mainApp.status == .enabled
        language = defaults.string(forKey: "language") ?? "auto"
        applyLanguage()

        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self?.applyNow() }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in self?.tick() }
        tick()
    }

    private func applyLanguage() {
        Localizer.current = (language == "auto" || !Localizer.languages.contains { $0.code == language }) ? nil : language
    }

    // MARK: kalicilik
    private func persist() {
        if let d = try? JSONEncoder().encode(settings) { defaults.set(d, forKey: "settings") }
    }
    private func persistProfiles() {
        if let d = try? JSONEncoder().encode(profiles) { defaults.set(d, forKey: "profiles") }
    }

    private func settingsChanged(old: KBSettings) {
        persist()
        if suppress { return }
        // yalnizca parlaklik degistiyse animasyonu bozmadan hafif komut
        var a = old, b = settings
        a.brightness = 0; b.brightness = 0
        if a == b && old.brightness != settings.brightness && settings.power {
            scheduleBrightness()
        } else {
            scheduleApply()
        }
    }

    // MARK: donanim
    private func scheduleApply() {
        applyItem?.cancel()
        let w = DispatchWorkItem { [weak self] in self?.applyNow() }
        applyItem = w
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: w)
    }

    private func scheduleBrightness() {
        brightnessItem?.cancel()
        let b = settings.brightness
        let w = DispatchWorkItem { [weak self] in self?.hw.async { self?.kb.setBrightness(b) } }
        brightnessItem = w
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04, execute: w)
    }

    func applyNow() {
        let s = settings
        hw.async { [weak self] in
            guard let self = self else { return }
            guard self.kb.connect() else { DispatchQueue.main.async { self.connected = false }; return }
            var ok = true
            if let pal = s.palette { for (i, c) in pal.prefix(7).enumerated() { ok = self.kb.setPaletteColor(index: i + 1, c) && ok } }
            if !s.power {
                ok = self.kb.turnOff()
            } else {
                switch s.mode {
                case .effect:
                    ok = self.kb.setEffect(s.effect, speed: s.speed, brightness: s.brightness, color: s.color,
                                           direction: s.direction, reactive: s.reactive, save: s.saveToKeyboard)
                case .solid:
                    ok = self.kb.fill(s.solid, brightness: s.brightness, save: s.saveToKeyboard)
                case .keys:
                    ok = self.kb.setKeys(s.keys, brightness: s.brightness, save: s.saveToKeyboard)
                }
            }
            DispatchQueue.main.async { self.connected = ok || self.kb.isConnected }
        }
    }

    /// Her 4 sn: baglanti kontrolu; yeniden baglaninca ayarlari uygular. Fn tuslariyla degisen parlaklik/aciklik durumunu okur.
    private func tick() {
        hw.async { [weak self] in
            guard let self = self else { return }
            let was = self.kb.isConnected
            guard self.kb.connect() else { DispatchQueue.main.async { self.connected = false }; return }
            guard let fw = self.kb.firmware(), let st = self.kb.state() else {
                DispatchQueue.main.async { self.connected = false }; return
            }
            DispatchQueue.main.async {
                self.connected = true
                self.firmware = fw
                if !was { self.applyNow(); return }
                self.syncFromHardware(st)
            }
        }
    }

    private func syncFromHardware(_ st: ITEState) {
        var s = settings
        var changed = false
        if st.off == s.power { s.power = !st.off; changed = true }                    // Fn ile acilip/kapandi
        if !st.off && Int(st.brightness) != s.brightness && applyItem == nil { s.brightness = Int(st.brightness); changed = true }
        if changed { suppress = true; settings = s; suppress = false }
    }

    // MARK: profiller
    func saveProfile(named name: String) {
        let n = name.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        profiles.removeAll { $0.name == n }
        profiles.append(Profile(name: n, settings: settings))
        persistProfiles()
    }
    func load(_ p: Profile) { settings = p.settings }
    func delete(_ p: Profile) { profiles.removeAll { $0.id == p.id }; persistProfiles() }

    // MARK: oturum acilisi
    func setLoginItem(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            message = ""
        } catch { message = String(format: L("Could not set the login item: %@"), error.localizedDescription) }
        loginItem = SMAppService.mainApp.status == .enabled
    }

    // MARK: yardimcilar
    func paintKey(row: Int, col: Int, _ c: RGB) {
        guard row >= 0, row < ITE8291.rows, col >= 0, col < ITE8291.cols else { return }
        if settings.keys[row][col] == c && settings.mode == .keys { return }
        var s = settings
        s.keys[row][col] = c
        s.mode = .keys
        s.power = true
        settings = s
    }
}

// SwiftUI Color <-> RGB
extension RGB {
    var color: Color { Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255) }
    init(_ c: Color) {
        let n = NSColor(c).usingColorSpace(.sRGB) ?? NSColor.white
        self.init(r: UInt8(max(0, min(255, round(n.redComponent * 255)))),
                  g: UInt8(max(0, min(255, round(n.greenComponent * 255)))),
                  b: UInt8(max(0, min(255, round(n.blueComponent * 255)))))
    }
    static func hsb(_ h: Double, _ s: Double, _ v: Double) -> RGB {
        RGB(Color(hue: h, saturation: s, brightness: v))
    }
}
