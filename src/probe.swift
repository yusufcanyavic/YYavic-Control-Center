// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
// ITE 8291 (048d:600b, rev 0.03) read-only probe: finds the device and READS the firmware version and current effect. Writes nothing.
import Foundation
import IOKit.hid

let VID = 0x048D, PID = 0x600B

let mgr = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
IOHIDManagerSetDeviceMatching(mgr, [kIOHIDVendorIDKey: VID, kIOHIDProductIDKey: PID] as CFDictionary)
let openRes = IOHIDManagerOpen(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
print("IOHIDManagerOpen -> 0x\(String(UInt32(bitPattern: openRes), radix: 16))")

guard let devs = IOHIDManagerCopyDevices(mgr) as? Set<IOHIDDevice>, !devs.isEmpty else {
    print("device not found"); exit(1)
}
for d in devs {
    func p(_ k: String) -> Any? { IOHIDDeviceGetProperty(d, k as CFString) }
    print("- device: usagePage=0x\(String((p(kIOHIDPrimaryUsagePageKey) as? Int) ?? 0, radix: 16)) usage=\(p(kIOHIDPrimaryUsageKey) ?? "?") featSize=\(p(kIOHIDMaxFeatureReportSizeKey) ?? "?") outSize=\(p(kIOHIDMaxOutputReportSizeKey) ?? "?") ver=\(p(kIOHIDVersionNumberKey) ?? "?") prod=\(p(kIOHIDProductKey) ?? "?")")
}
guard let dev = devs.first(where: { (IOHIDDeviceGetProperty($0, kIOHIDPrimaryUsagePageKey as CFString) as? Int) == 0xFF03 }) else {
    print("no interface with usage page 0xFF03"); exit(1)
}
let openDev = IOHIDDeviceOpen(dev, IOOptionBits(kIOHIDOptionsTypeNone))
print("IOHIDDeviceOpen(0xFF03) -> 0x\(String(UInt32(bitPattern: openDev), radix: 16))")

func xfer(_ cmd: [UInt8]) -> [UInt8]? {
    var out = cmd + [UInt8](repeating: 0, count: 8 - cmd.count)
    let s = IOHIDDeviceSetReport(dev, kIOHIDReportTypeFeature, 0, &out, 8)
    if s != kIOReturnSuccess { print("  SetReport error 0x\(String(UInt32(bitPattern: s), radix: 16))"); return nil }
    var buf = [UInt8](repeating: 0, count: 8); var len = 8
    let g = IOHIDDeviceGetReport(dev, kIOHIDReportTypeFeature, 0, &buf, &len)
    if g != kIOReturnSuccess { print("  GetReport error 0x\(String(UInt32(bitPattern: g), radix: 16))"); return nil }
    return Array(buf.prefix(len))
}

if let fw = xfer([0x80]) { print("FW reply: \(fw.map { String(format: "%02x", $0) }.joined(separator: " "))  -> version \(fw[1]).\(fw[2]).\(fw[3]).\(fw[4])") }
if let ef = xfer([0x88]) { print("Effect reply: \(ef.map { String(format: "%02x", $0) }.joined(separator: " "))  -> off=\(ef[1] == 1) effect=0x\(String(ef[2], radix: 16)) speed=\(ef[3]) brightness=\(ef[4]) color=\(ef[5]) direction=\(ef[6]) save=\(ef[7])") }
IOHIDDeviceClose(dev, IOOptionBits(kIOHIDOptionsTypeNone))
