//
//  FileHandler.swift
//  NewFolderFile
//
//  Created by Mate Tohai on 17/09/2024.
//

//
// Contains main functions for converting the file.
// Every interaction with finder is dont through AppleScript due to permission issues otherwise.
// Theoretically a Finder Sync extension could easily be added for accessing the conversion through the right click menu,
// but macOS 15 seems to have broken it.
//

import Foundation
import AppKit

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output
}

struct FileHandler {
    static let shared = FileHandler()
    
    func convertFile(currentPath: String? = nil, open: Bool = false) -> Bool {
        let path = currentPath ?? getSelectedFile() ?? ""
        print("Converting file at path: \(path)")
        
        guard !path.isEmpty else {
            print("No valid path provided")
            return false
        }
        
        guard deleteFolder(at: path) else {
            print("Failed to delete folder")
            return false
        }
        
        guard createFile(at: path) else {
            print("Failed to create file")
            return false
        }
        
        if open {
            openFile(at: path)
        }
        
        return true
    }

    
    func getSelectedFile() -> String? {
        print("getSelectedFile")
        
        return shell(
            """
              osascript -e 'try
                  tell application "Finder"
                      set temp to selection as alias list
                      if length of temp is 0 then
                          error "No items selected in Finder"
                      end if
                      repeat with i from 1 to length of temp
                          set the_item to item i of temp
                          set the_result to POSIX path of the_item
                          return the_result
                      end repeat
                  end tell
              on error errorMessage
                  return "Error: " & errorMessage
              end try'
            """)
    }
    
    func isFolderEmpty(at path: String) -> Bool {
        let fileManager = FileManager.default
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else { return false }
        
        return contents.isEmpty
    }
    
    func deleteFolder(at path: String) -> Bool {
        var finalPath = path
        finalPath.remove(at: finalPath.firstIndex(of: "\n")!)
        
        let defaults = UserDefaults.standard
        let maxAge = defaults.integer(forKey: "maxAge")
        
        let command = """
            osascript -e '
            try
                tell application "Finder"
                    set theFile to POSIX file "\(finalPath)" as alias
                    if items of theFile is {} then
                        if \(maxAge) = -1 then
                            delete theFile
                            return "success"
                        else
                            set creationDate to creation date of theFile
                            set currentDate to current date
                            set timeDifference to currentDate - creationDate
                            if timeDifference ≤ \(maxAge) then
                                delete theFile
                                return "success"
                            else
                                return "too old"
                            end if
                        end if
                    else
                        return "not empty"
                    end if
                end tell
            on error errMsg
                return "error"
            end try'
        """
        
        if shell(command).trimmingCharacters(in: .whitespacesAndNewlines) == "success" {
            return true
        }
        
        return false
    }
    
    func createFile(at path: String) -> Bool {
        var finalPath = path
        if let newlineIndex = finalPath.firstIndex(of: "\n") {
            finalPath.remove(at: newlineIndex)
            finalPath.removeLast()
        }
        
        let command =
        """
        touch "\(finalPath)"
        """
        
        print(shell(command))
        return true
    }
    
    func openFile(at path: String) {
        print("opening")
        print(shell("open \(path)"))
    }
}
