// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
// ITE 8291 (048d:600b, rev 0.03) keyboard backlight controller - macOS IOHID driver.
// Protocol: written from the documented behaviour (byte layout) of pobrn/ite8291r3-ctl; no code copied.
import Foundation
import IOKit.hid

enum ITEEffect: UInt8, CaseIterable {
    case breathing = 0x02, wave = 0x03, random = 0x04, rainbow = 0x05, ripple = 0x06
    case marquee = 0x09, raindrop = 0x0A, aurora = 0x0E, fireworks = 0x11

    var name: String { String(describing: self) }
    /// efektin kullandigi ayarlar
    var usesSpeed: Bool { self != .rainbow }
    var usesColor: Bool { [.breathing, .random, .ripple, .raindrop, .aurora, .fireworks].contains(self) }
    var usesDirection: Bool { self == .wave }
    var usesReactive: Bool { [.random, .ripple, .aurora, .fireworks].contains(self) }
}

enum ITEColor: UInt8, CaseIterable {
    case none = 0, red, orange, yellow, green, blue, teal, purple, random
}
enum ITEDirection: UInt8, CaseIterable { case none = 0, right, left, up, down }

struct ITEState {
    var off: Bool
    var effect: UInt8, speed: UInt8, brightness: UInt8, color: UInt8, direction: UInt8, save: UInt8
}

final class ITE8291 {
    static let vid = 0x048D, pid = 0x600B
    static let rows = 6, cols = 21
    private let manager: IOHIDManager
    private let dev: IOHIDDevice
    var verbose = false

    init?() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(manager, [kIOHIDVendorIDKey: Self.vid, kIOHIDProductIDKey: Self.pid] as CFDictionary)
        guard IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess,
              let set = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>,
              let d = set.first(where: { (IOHIDDeviceGetProperty($0, kIOHIDPrimaryUsagePageKey as CFString) as? Int) == 0xFF03 }),
              IOHIDDeviceOpen(d, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess
        else { return nil }
        dev = d
    }

    deinit { IOHIDDeviceClose(dev, IOOptionBits(kIOHIDOptionsTypeNone)) }

    // MARK: ham iletisim
    @discardableResult
    func control(_ cmd: [UInt8]) -> Bool {
        var out = cmd + [UInt8](repeating: 0, count: max(0, 8 - cmd.count))
        let r = IOHIDDeviceSetReport(dev, kIOHIDReportTypeFeature, 0, &out, 8)
        if verbose || r != kIOReturnSuccess { FileHandle.standardError.write(Data("control \(out.map { String(format: "%02x", $0) }.joined()) -> 0x\(String(UInt32(bitPattern: r), radix: 16))\n".utf8)) }
        return r == kIOReturnSuccess
    }

    func query(_ cmd: UInt8) -> [UInt8]? {
        guard control([cmd]) else { return nil }
        var buf = [UInt8](repeating: 0, count: 8); var len = 8
        guard IOHIDDeviceGetReport(dev, kIOHIDReportTypeFeature, 0, &buf, &len) == kIOReturnSuccess else { return nil }
        return Array(buf.prefix(len))
    }

    // MARK: bilgi
    func firmware() -> String? { query(0x80).map { "\($0[1]).\($0[2]).\($0[3]).\($0[4])" } }

    func state() -> ITEState? {
        guard let b = query(0x88), b.count >= 8 else { return nil }
        return ITEState(off: b[1] == 1, effect: b[2], speed: b[3], brightness: b[4], color: b[5], direction: b[6], save: b[7])
    }

    // MARK: komutlar
    func turnOff() -> Bool { control([0x08, 0x01, 0, 0, 0, 0, 0, 0]) }

    func setBrightness(_ v: Int) -> Bool { control([0x09, 0x02, UInt8(max(0, min(50, v)))]) }

    func setEffect(_ e: UInt8, speed: Int = 5, brightness: Int = 25, color: UInt8 = 0, direction: UInt8 = 0, save: Bool = false) -> Bool {
        control([0x08, 0x02, e, UInt8(max(0, min(11, speed))), UInt8(max(0, min(50, brightness))), color, direction, save ? 1 : 0])
    }

    func setEffect(_ e: ITEEffect, speed: Int = 5, brightness: Int = 25, color: ITEColor = .random,
                   direction: ITEDirection = .none, reactive: Bool = false, save: Bool = false) -> Bool {
        let dirByte: UInt8 = e.usesDirection ? direction.rawValue : (e.usesReactive ? (reactive ? 1 : 0) : 0)
        return setEffect(e.rawValue, speed: e.usesSpeed ? speed : 0, brightness: brightness,
                         color: e.usesColor ? color.rawValue : 0, direction: dirByte, save: save)
    }

    func setPaletteColor(index: Int, r: UInt8, g: UInt8, b: UInt8) -> Bool {
        guard (1...7).contains(index) else { return false }
        return control([0x14, 0x00, UInt8(index), r, g, b])
    }

    // MARK: tus bazli (kullanici modu)
    /// 6x21 matris; her eleman (r,g,b). Cikis raporu: 64 bayt = mavi[21], yesil[21], kirmizi[21], 0 (planar).
    func setKeys(_ colors: [[(UInt8, UInt8, UInt8)]], brightness: Int = 25, save: Bool = false, enterMode: Bool = true) -> Bool {
        if enterMode {
            guard control([0x08, 0x02, 0x33, 0x00, UInt8(max(0, min(50, brightness))), 0x00, 0x00, save ? 1 : 0]) else { return false }
        }
        for row in 0..<Self.rows {
            guard control([0x16, 0x00, UInt8(row)]) else { return false }
            var payload = [UInt8](repeating: 0, count: 64)
            for col in 0..<Self.cols {
                let c = (row < colors.count && col < colors[row].count) ? colors[row][col] : (0, 0, 0)
                payload[col] = c.2          // mavi
                payload[21 + col] = c.1     // yesil
                payload[42 + col] = c.0     // kirmizi
            }
            let r = IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 0, payload, 64)
            if verbose || r != kIOReturnSuccess { FileHandle.standardError.write(Data("satir \(row) cikis raporu -> 0x\(String(UInt32(bitPattern: r), radix: 16))\n".utf8)) }
            if r != kIOReturnSuccess { return false }
        }
        return true
    }

    func fill(r: UInt8, g: UInt8, b: UInt8, brightness: Int = 25, save: Bool = false) -> Bool {
        let row = [(UInt8, UInt8, UInt8)](repeating: (r, g, b), count: Self.cols)
        return setKeys([[(UInt8, UInt8, UInt8)]](repeating: row, count: Self.rows), brightness: brightness, save: save)
    }
}
