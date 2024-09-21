//
//  NewFolderFileApp.swift
//  NewFolderFile
//
//  Created by Mate Tohai on 15/09/2024.
//

import SwiftUI
import KeyboardShortcuts
import Foundation

extension KeyboardShortcuts.Name {
    static let convertFolder = Self("convertFolder")
    static let convertFolderOpen = Self("convertFolderOpen")
}

@main
struct NewFileFolderApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["maxAge": 60])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyUp(for: .convertFolder) { [weak self] in
            print("Triggered shortcut .convertFolder")
            self?.convertFolder()
        }
        KeyboardShortcuts.onKeyUp(for: .convertFolderOpen) { [weak self] in
            print("Triggered shortcut .convertFolderOpen")
            self?.convertFolderOpen()
        }
    }
    
    private func convertFolder() {
        let fileHandler = FileHandler.shared
        let _ = fileHandler.convertFile()
    }
    
    private func convertFolderOpen() {
        let fileHandler = FileHandler.shared
        let _ = fileHandler.convertFile(open: true)
    }
}
