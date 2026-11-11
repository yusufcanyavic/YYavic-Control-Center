// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
// yycc-kb - command line tool for the ITE 8291 keyboard backlight (048d:600b), e.g. Tongfang laptops
import Foundation

func usage() -> Never {
    print("""
    usage: yycc-kb <command> [options]
      info                         device, firmware version, current effect
      off | on                     turn the lights off / on
      brightness <0-50>            brightness
      effect <ad> [--speed 0-11] [--brightness 0-50] [--color ad] [--direction ad] [--reactive] [--save]
          effects: \(ITEEffect.allCases.map { $0.name }.joined(separator: ", "))
          colors: \(ITEColor.allCases.map { String(describing: $0) }.joined(separator: ", "))
          directions: \(ITEDirection.allCases.map { String(describing: $0) }.joined(separator: ", "))
      color <R> <G> <B> [--brightness 0-50] [--save]    all keys one color (user mode)
      palette <1-7> <R> <G> <B>    change a color of the effect palette
    --save: writes the setting to the keyboard's flash (default: not saved, the keyboard
            returns to its stored setting after a reboot)
    """)
    exit(2)
}

var args = Array(CommandLine.arguments.dropFirst())
guard let cmd = args.first else { usage() }
args.removeFirst()

func opt(_ name: String) -> String? {
    if let i = args.firstIndex(of: "--\(name)"), i + 1 < args.count { return args[i + 1] }
    return nil
}
func flag(_ name: String) -> Bool { args.contains("--\(name)") }

guard let kb = ITE8291() else { print("ERROR: ITE 8291 (048d:600b) not found / could not be opened"); exit(1) }
kb.verbose = flag("verbose")

func finish(_ ok: Bool) -> Never { print(ok ? "ok" : "ERROR"); exit(ok ? 0 : 1) }

switch cmd {
case "info":
    print("firmware: \(kb.firmware() ?? "?")")
    if let s = kb.state() {
        let e = ITEEffect(rawValue: s.effect).map { $0.name } ?? (s.effect == 0x33 ? "user mode" : "0x\(String(s.effect, radix: 16))")
        print("off: \(s.off)  effect: \(e)  speed: \(s.speed)  brightness: \(s.brightness)/50  color: \(ITEColor(rawValue: s.color).map { String(describing: $0) } ?? "\(s.color)")  direction/reactive: \(s.direction)  saved: \(s.save)")
    }
case "off": finish(kb.turnOff())
case "on":
    guard let s = kb.state() else { finish(false) }
    finish(kb.setEffect(s.effect, speed: Int(s.speed), brightness: Int(s.brightness), color: s.color, direction: s.direction, save: false))
case "brightness":
    guard let v = args.first.flatMap({ Int($0) }) else { usage() }
    finish(kb.setBrightness(v))
case "effect":
    guard let name = args.first, let e = ITEEffect.allCases.first(where: { $0.name == name }) else { usage() }
    let color = opt("color").flatMap { n in ITEColor.allCases.first { String(describing: $0) == n } } ?? .random
    let dir = opt("direction").flatMap { n in ITEDirection.allCases.first { String(describing: $0) == n } } ?? .right
    finish(kb.setEffect(e, speed: opt("speed").flatMap { Int($0) } ?? 5, brightness: opt("brightness").flatMap { Int($0) } ?? 25,
                        color: color, direction: dir, reactive: flag("reactive"), save: flag("save")))
case "color":
    let v = args.prefix(3).compactMap { UInt8($0) }
    guard v.count == 3 else { usage() }
    finish(kb.fill(r: v[0], g: v[1], b: v[2], brightness: opt("brightness").flatMap { Int($0) } ?? 25, save: flag("save")))
case "palette":
    let v = args.prefix(4).compactMap { Int($0) }
    guard v.count == 4 else { usage() }
    finish(kb.setPaletteColor(index: v[0], r: UInt8(v[1]), g: UInt8(v[2]), b: UInt8(v[3])))
default: usage()
}
