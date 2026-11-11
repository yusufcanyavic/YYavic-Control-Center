// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
import SwiftUI
import AppKit

/// Yerellestirilmis Text kisayolu (secilen dile gore anlik degisir).
func T(_ key: String) -> Text { Text(verbatim: L(key)) }

struct PanelView: View {
    @ObservedObject var model: KBModel
    @Environment(\.openWindow) private var openWindow
    @State private var newProfile = ""
    @State private var showPalette = false

    private var palette: [RGB] {
        model.settings.palette ?? [RGB(r: 255, g: 0, b: 0), RGB(r: 255, g: 28, b: 0), RGB(r: 255, g: 119, b: 0), RGB(r: 0, g: 255, b: 0),
                                   RGB(r: 0, g: 0, b: 255), RGB(r: 0, g: 255, b: 255), RGB(r: 255, g: 0, b: 255)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            Picker("", selection: $model.settings.mode) {
                ForEach(LightMode.allCases) { Text(verbatim: $0.title).tag($0) }
            }
            .pickerStyle(.segmented).labelsHidden()

            switch model.settings.mode {
            case .effect: effectControls
            case .solid:
                ColorPicker(L("Color"), selection: Binding(get: { model.settings.solid.color }, set: { model.settings.solid = RGB($0) }), supportsOpacity: false)
            case .keys:
                Button(L("Open key editor…")) {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "keys")
                }
            }

            HStack {
                Image(systemName: "sun.min")
                Slider(value: Binding(get: { Double(model.settings.brightness) }, set: { model.settings.brightness = Int($0) }), in: 0...50, step: 1)
                Image(systemName: "sun.max.fill")
            }
            .help(L("Brightness"))

            Divider()
            profiles
            Toggle(L("Save permanently to the keyboard (survives restart)"), isOn: $model.settings.saveToKeyboard)
                .font(.callout)
            Toggle(L("Start at login"), isOn: Binding(get: { model.loginItem }, set: { model.setLoginItem($0) }))
                .font(.callout)
            languagePicker
            DisclosureGroup(L("Effect palette"), isExpanded: $showPalette) {
                ForEach(0..<7, id: \.self) { i in
                    ColorPicker(String(format: L("Color %d"), i + 1), selection: Binding(
                        get: { palette[i].color },
                        set: { var p = palette; p[i] = RGB($0); model.settings.palette = p }), supportsOpacity: false)
                }
                Button(L("Reset to default")) { model.settings.palette = nil }
            }
            .font(.callout)
            if !model.message.isEmpty { Text(verbatim: model.message).font(.caption).foregroundColor(.orange) }
            HStack {
                Text(verbatim: model.connected ? String(format: L("Connected · FW %@"), model.firmware) : L("Keyboard controller not found"))
                    .font(.caption).foregroundColor(.secondary)
                Spacer()
                Button(L("Quit")) { NSApp.terminate(nil) }.buttonStyle(.link)
            }
            HStack {
                Spacer()
                Text(verbatim: "© 2026 Yusufcan Yavic · YYavic").font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(width: 350)
    }

    private var header: some View {
        HStack {
            Image(systemName: "keyboard.fill")
            T("YYavic Control Center").font(.headline)
            Circle().fill(model.connected ? Color.green : Color.red).frame(width: 8, height: 8)
            Spacer()
            Toggle("", isOn: $model.settings.power).toggleStyle(.switch).labelsHidden()
        }
    }

    /// Otomatik (sistem dili) + elle secilebilen diller. Sistem dili desteklenmiyorsa otomatik = Ingilizce.
    private var languagePicker: some View {
        HStack {
            Image(systemName: "globe")
            T("Language").font(.callout)
            Spacer()
            Picker("", selection: $model.language) {
                Text(verbatim: L("Automatic (system language)")).tag("auto")
                Divider()
                ForEach(Localizer.languages, id: \.code) { Text(verbatim: $0.name).tag($0.code) }
            }
            .labelsHidden()
            .frame(maxWidth: 200)
        }
    }

    @ViewBuilder private var effectControls: some View {
        let e = model.settings.effect
        Picker(L("Effect"), selection: $model.settings.effect) {
            ForEach(ITEEffect.allCases) { Text(verbatim: $0.title).tag($0) }
        }
        if e.usesSpeed {
            // donanimda 0 = en hizli, 10 = en yavas; arayuzde sag = daha hizli
            HStack {
                T("Speed").fixedSize()
                Slider(value: Binding(get: { Double(10 - model.settings.speed) }, set: { model.settings.speed = 10 - Int($0) }), in: 0...10, step: 1)
            }
        }
        if e.usesColor {
            Picker(L("Color"), selection: $model.settings.color) {
                ForEach(ITEColor.allCases.filter { $0 != .none }) { Text(verbatim: $0.title).tag($0) }
            }
        }
        if e.usesDirection {
            Picker(L("Direction"), selection: $model.settings.direction) {
                ForEach(ITEDirection.allCases) { Text(verbatim: $0.title).tag($0) }
            }
        }
        if e.usesReactive {
            Toggle(L("React when a key is pressed"), isOn: $model.settings.reactive).font(.callout)
        }
    }

    private var profiles: some View {
        HStack {
            Menu(L("Profiles")) {
                ForEach(model.profiles) { p in
                    Button(p.name) { model.load(p) }
                }
                if !model.profiles.isEmpty {
                    Divider()
                    Menu(L("Delete")) { ForEach(model.profiles) { p in Button(p.name) { model.delete(p) } } }
                }
            }
            TextField(L("New profile name"), text: $newProfile).textFieldStyle(.roundedBorder)
            Button(L("Save")) { model.saveProfile(named: newProfile); newProfile = "" }.disabled(newProfile.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

// MARK: tus bazli editor
struct KeyEditorView: View {
    @ObservedObject var model: KBModel
    @State private var brush = Color.red
    private let cell: CGFloat = 28, gap: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            T("Per-key color").font(.headline)
            T("Click or drag over the cells to paint; the change appears on the keyboard instantly. Painting shows which cell is which key.")
                .font(.caption).foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            grid
            HStack {
                ColorPicker(L("Brush"), selection: $brush, supportsOpacity: false)
                Button(L("Paint all")) { fill(RGB(brush)) }
                Button(L("White")) { fill(RGB(r: 255, g: 255, b: 255)) }
                Button(L("Clear")) { fill(.black) }
            }
            HStack {
                T("Presets:")
                Button(L("Rainbow")) { pattern { c, _ in RGB.hsb(Double(c) / Double(ITE8291.cols), 1, 1) } }
                Button(L("Fire")) { pattern { _, r in RGB.hsb(0.0 + Double(ITE8291.rows - 1 - r) * 0.025, 1, 1) } }
                Button(L("Ocean")) { pattern { c, r in RGB.hsb(0.5 + Double(c) / Double(ITE8291.cols) * 0.15, 1, 0.5 + Double(r) * 0.1) } }
                Button(L("Night")) { pattern { c, _ in RGB.hsb(0.72 - Double(c) / Double(ITE8291.cols) * 0.1, 0.9, 0.8) } }
            }
            HStack {
                T("Brightness")
                Slider(value: Binding(get: { Double(model.settings.brightness) }, set: { model.settings.brightness = Int($0) }), in: 0...50, step: 1).frame(width: 220)
            }
        }
        .padding(16)
        .frame(minWidth: 740)
    }

    private var grid: some View {
        let w = CGFloat(ITE8291.cols) * (cell + gap), h = CGFloat(ITE8291.rows) * (cell + gap)
        return Canvas { ctx, _ in
            for r in 0..<ITE8291.rows {
                for c in 0..<ITE8291.cols {
                    let rect = CGRect(x: CGFloat(c) * (cell + gap), y: CGFloat(r) * (cell + gap), width: cell, height: cell)
                    let k = model.settings.keys[r][c]
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 5), with: .color(k.color))
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: 5), with: .color(.gray.opacity(0.5)), lineWidth: 1)
                }
            }
        }
        .frame(width: w, height: h)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0).onChanged { v in
            let c = Int(v.location.x / (cell + gap)), r = Int(v.location.y / (cell + gap))
            model.paintKey(row: r, col: c, RGB(brush))
        })
    }

    private func fill(_ c: RGB) {
        var s = model.settings; s.keys = KBSettings.uniform(c); s.mode = .keys; s.power = true; model.settings = s
    }
    private func pattern(_ f: (Int, Int) -> RGB) {
        var s = model.settings
        s.keys = (0..<ITE8291.rows).map { r in (0..<ITE8291.cols).map { c in f(c, r) } }
        s.mode = .keys; s.power = true
        model.settings = s
    }
}
