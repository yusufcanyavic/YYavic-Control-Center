// YYavic Control Center
// Copyright (C) 2026 Yusufcan Yavic
// SPDX-License-Identifier: GPL-3.0-or-later
import SwiftUI

@main
struct YYavicControlCenterApp: App {
    @StateObject private var model = KBModel()

    var body: some Scene {
        // model.language okunur: dil degisince sahne yeniden olusur (pencere basligi guncellenir)
        let _ = model.language
        MenuBarExtra(L("YYavic Control Center"), systemImage: "keyboard") {
            PanelView(model: model)
        }
        .menuBarExtraStyle(.window)

        Window(L("Per-key color"), id: "keys") {
            KeyEditorView(model: model)
        }
        .windowResizability(.contentSize)
    }
}
