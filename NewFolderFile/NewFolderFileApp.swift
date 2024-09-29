//
//  NewFolderFileApp.swift
//  NewFolderFile
//
//  Created by Mate Tohai on 15/09/2024.
//

import SwiftUI
import KeyboardShortcuts
import Foundation
import ServiceManagement

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
                .environmentObject(appState)
        }
        .windowResizability(.contentSize)
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isLoginItemEnabled: Bool = false
    
    init() {
        KeyboardShortcuts.onKeyUp(for: .convertFolder) { [weak self] in
            print("Triggered shortcut .convertFolder")
            self?.convertFolder()
        }
        KeyboardShortcuts.onKeyUp(for: .convertFolderOpen) { [weak self] in
            print("Triggered shortcut .convertFolderOpen")
            self?.convertFolderOpen()
        }
        
        updateLoginItemStatus()
    }
    
    private func convertFolder() {
        let fileHandler = FileHandler.shared
        let _ = fileHandler.convertFile()
    }
    
    private func convertFolderOpen() {
        let fileHandler = FileHandler.shared
        let _ = fileHandler.convertFile(open: true)
    }
    
    func toggleLoginItem() {
        if isLoginItemEnabled {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
        
        updateLoginItemStatus()
    }
    
    private func updateLoginItemStatus() {
        isLoginItemEnabled = SMAppService.mainApp.status == .enabled
    }
}
