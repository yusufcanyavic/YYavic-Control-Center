// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
// ITE 8291 (048d:600b, rev 0.03) keyboard backlight controller - macOS IOHID driver.
// Protocol: written from the documented behaviour (byte layout) of pobrn/ite8291r3-ctl; no code copied.
import Foundation
import IOKit.hid

/// Yerellestirme: anahtar Ingilizce metindir (Localizable.strings). `current == nil` -> otomatik (macOS sistem dili,
/// desteklenmiyorsa gelistirme dili Ingilizce). Aksi halde secilen dilin .lproj paketi kullanilir.
enum Localizer {
    static var base: Bundle = .main
    static var current: String? = nil
    static let languages: [(code: String, name: String)] = [
        ("en", "English"), ("tr", "Türkçe"), ("de", "Deutsch"), ("fr", "Français"), ("es", "Español"), ("it", "Italiano"),
        ("pt-BR", "Português (Brasil)"), ("pt-PT", "Português (Portugal)"), ("ru", "Русский"), ("cs", "Čeština"),
        ("da", "Dansk"), ("nb", "Norsk bokmål"), ("sv", "Svenska"), ("fi", "Suomi"), ("hu", "Magyar"), ("pl", "Polski"),
        ("ja", "日本語"), ("ko", "한국어"), ("zh-Hans", "简体中文"), ("zh-Hant", "繁體中文"),
    ]
    /// Sistem dil listesine (uygulama basina dil ayari dahil) gore desteklenen ilk dil; yoksa Ingilizce.
    static func automaticCode() -> String {
        let codes = languages.map { $0.code }
        return Bundle.preferredLocalizations(from: codes, forPreferences: Locale.preferredLanguages).first ?? "en"
    }
    static func string(_ key: String) -> String {
        let code = current ?? automaticCode()
        if let path = base.path(forResource: code, ofType: "lproj"), let b = Bundle(path: path) {
            return b.localizedString(forKey: key, value: key, table: nil)
        }
        return key   // Ingilizce metin zaten anahtardir
    }
}
func L(_ key: String) -> String { Localizer.string(key) }

enum ITEEffect: UInt8, CaseIterable, Identifiable, Codable {
    case breathing = 0x02, wave = 0x03, random = 0x04, rainbow = 0x05, ripple = 0x06
    case marquee = 0x09, raindrop = 0x0A, aurora = 0x0E, fireworks = 0x11
    var id: UInt8 { rawValue }
    var name: String { String(describing: self) }
    var title: String {
        switch self {
        case .breathing: return L("Breathing")
        case .wave: return L("Wave")
        case .random: return L("Random")
        case .rainbow: return L("Rainbow")
        case .ripple: return L("Ripple")
        case .marquee: return L("Marquee")
        case .raindrop: return L("Raindrop")
        case .aurora: return L("Aurora")
        case .fireworks: return L("Fireworks")
        }
    }
    var usesSpeed: Bool { self != .rainbow }
    var usesColor: Bool { [.breathing, .random, .ripple, .raindrop, .aurora, .fireworks].contains(self) }
    var usesDirection: Bool { self == .wave }
    var usesReactive: Bool { [.random, .ripple, .aurora, .fireworks].contains(self) }
}

enum ITEColor: UInt8, CaseIterable, Identifiable, Codable {
    case none = 0, red, orange, yellow, green, blue, teal, purple, random
    var id: UInt8 { rawValue }
    var title: String {
        switch self {
        case .none: return L("None")
        case .red: return L("Red")
        case .orange: return L("Orange")
        case .yellow: return L("Yellow")
        case .green: return L("Green")
        case .blue: return L("Blue")
        case .teal: return L("Teal")
        case .purple: return L("Purple")
        case .random: return L("Random")
        }
    }
}

enum ITEDirection: UInt8, CaseIterable, Identifiable, Codable {
    case right = 1, left, up, down
    var id: UInt8 { rawValue }
    var title: String {
        switch self { case .right: return L("Right"); case .left: return L("Left"); case .up: return L("Up"); case .down: return L("Down") }
    }
}

struct ITEState {
    var off: Bool
    var effect: UInt8, speed: UInt8, brightness: UInt8, color: UInt8, direction: UInt8, save: UInt8
}

struct RGB: Codable, Equatable {
    var r: UInt8, g: UInt8, b: UInt8
    static let black = RGB(r: 0, g: 0, b: 0)
}

final class ITE8291 {
    static let vid = 0x048D, pid = 0x600B
    static let rows = 6, cols = 21
    private var manager: IOHIDManager?
    private var dev: IOHIDDevice?
    private let lock = NSLock()

    var isConnected: Bool { lock.lock(); defer { lock.unlock() }; return dev != nil }

    /// Aygiti acmayi dener; zaten aciksa true doner.
    @discardableResult
    func connect() -> Bool {
        lock.lock(); defer { lock.unlock() }
        if dev != nil { return true }
        let m = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(m, [kIOHIDVendorIDKey: Self.vid, kIOHIDProductIDKey: Self.pid] as CFDictionary)
        guard IOHIDManagerOpen(m, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess,
              let set = IOHIDManagerCopyDevices(m) as? Set<IOHIDDevice>,
              let d = set.first(where: { (IOHIDDeviceGetProperty($0, kIOHIDPrimaryUsagePageKey as CFString) as? Int) == 0xFF03 }),
              IOHIDDeviceOpen(d, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess
        else {
            IOHIDManagerClose(m, IOOptionBits(kIOHIDOptionsTypeNone))
            return false
        }
        manager = m; dev = d
        return true
    }

    func disconnect() {
        lock.lock(); defer { lock.unlock() }
        if let d = dev { IOHIDDeviceClose(d, IOOptionBits(kIOHIDOptionsTypeNone)) }
        if let m = manager { IOHIDManagerClose(m, IOOptionBits(kIOHIDOptionsTypeNone)) }
        dev = nil; manager = nil
    }

    private func fail(_ r: IOReturn) {
        // aygit cekildi / uyku sonrasi gecersiz: baglantiyi dusur, bir sonraki islemde yeniden denenir
        if r == kIOReturnNotAttached || r == kIOReturnNoDevice || r == kIOReturnNotOpen || r == kIOReturnOffline || r == kIOReturnAborted {
            disconnect()
        }
    }

    // MARK: ham iletisim
    @discardableResult
    func control(_ cmd: [UInt8]) -> Bool {
        guard connect(), let d = dev else { return false }
        var out = cmd + [UInt8](repeating: 0, count: max(0, 8 - cmd.count))
        let r = IOHIDDeviceSetReport(d, kIOHIDReportTypeFeature, 0, &out, 8)
        if r != kIOReturnSuccess { fail(r) }
        return r == kIOReturnSuccess
    }

    func query(_ cmd: UInt8) -> [UInt8]? {
        guard control([cmd]), let d = dev else { return nil }
        var buf = [UInt8](repeating: 0, count: 8); var len = 8
        let r = IOHIDDeviceGetReport(d, kIOHIDReportTypeFeature, 0, &buf, &len)
        if r != kIOReturnSuccess { fail(r); return nil }
        return Array(buf.prefix(len))
    }

    // MARK: bilgi
    func firmware() -> String? { query(0x80).map { "\($0[1]).\($0[2]).\($0[3]).\($0[4])" } }

    func state() -> ITEState? {
        guard let b = query(0x88), b.count >= 8 else { return nil }
        return ITEState(off: b[1] == 1, effect: b[2], speed: b[3], brightness: b[4], color: b[5], direction: b[6], save: b[7])
    }

    // MARK: komutlar
    @discardableResult func turnOff() -> Bool { control([0x08, 0x01, 0, 0, 0, 0, 0, 0]) }

    @discardableResult func setBrightness(_ v: Int) -> Bool { control([0x09, 0x02, UInt8(max(0, min(50, v)))]) }

    @discardableResult
    func setEffect(_ e: ITEEffect, speed: Int, brightness: Int, color: ITEColor, direction: ITEDirection, reactive: Bool, save: Bool) -> Bool {
        let dirByte: UInt8 = e.usesDirection ? direction.rawValue : (e.usesReactive ? (reactive ? 1 : 0) : 0)
        return control([0x08, 0x02, e.rawValue, UInt8(max(0, min(11, e.usesSpeed ? speed : 0))), UInt8(max(0, min(50, brightness))),
                        e.usesColor ? color.rawValue : 0, dirByte, save ? 1 : 0])
    }

    @discardableResult
    func setPaletteColor(index: Int, _ c: RGB) -> Bool {
        guard (1...7).contains(index) else { return false }
        return control([0x14, 0x00, UInt8(index), c.r, c.g, c.b])
    }

    // MARK: tus bazli (kullanici modu), 6x21
    /// Cikis raporu: 64 bayt = mavi[21], yesil[21], kirmizi[21], 0 (planar). Once satir indeksi (0x16) gonderilir.
    @discardableResult
    func setKeys(_ colors: [[RGB]], brightness: Int, save: Bool = false, enterMode: Bool = true) -> Bool {
        if enterMode {
            guard control([0x08, 0x02, 0x33, 0x00, UInt8(max(0, min(50, brightness))), 0x00, 0x00, save ? 1 : 0]) else { return false }
        }
        guard connect(), let d = dev else { return false }
        for row in 0..<Self.rows {
            guard control([0x16, 0x00, UInt8(row)]) else { return false }
            var payload = [UInt8](repeating: 0, count: 64)
            for col in 0..<Self.cols {
                let c = (row < colors.count && col < colors[row].count) ? colors[row][col] : RGB.black
                payload[col] = c.b; payload[21 + col] = c.g; payload[42 + col] = c.r
            }
            let r = IOHIDDeviceSetReport(d, kIOHIDReportTypeOutput, 0, payload, 64)
            if r != kIOReturnSuccess { fail(r); return false }
        }
        return true
    }

    @discardableResult
    func fill(_ c: RGB, brightness: Int, save: Bool = false) -> Bool {
        let row = [RGB](repeating: c, count: Self.cols)
        return setKeys([[RGB]](repeating: row, count: Self.rows), brightness: brightness, save: save)
    }
}
