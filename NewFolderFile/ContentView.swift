//
//  ContentView.swift
//  NewFolderFile
//
//  Created by Mate Tohai on 15/09/2024.
//

import SwiftUI
import KeyboardShortcuts
import Combine

struct ContentView: View {
    @State var ageToggle: Bool = false
    
    @State var age: Int = -1
    @State var ageString: String = "-1"
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            HStack {
                Text("New FolderFile")
                    .font(.largeTitle)
                    .padding([.leading, .bottom, .trailing])
                    .padding(.top, 5)
                    .padding(.leading, 4)
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                Spacer()
                Spacer()
                VStack {
                    Text("Convert folder")
                        .font(.title2)
                        .padding(.top, 6)
                    
                    Form {
                        KeyboardShortcuts.Recorder("", name: .convertFolder)
                            .padding(.leading, -6)
                    }
                }
                .padding(5)
                Spacer()
                VStack {
                    Text("Convert and open")
                        .font(.title2)
                        .padding(.top, 6)
                    
                    Form {
                        KeyboardShortcuts.Recorder("", name: .convertFolderOpen)
                            .padding(.leading, -6)
                    }
                }
                .padding(5)
                Spacer()
                Spacer()
            }
            
            Toggle("Launch at login", isOn: Binding(
                get: { appState.isLoginItemEnabled },
                set: { _ in appState.toggleLoginItem() }
            ))
            .padding(.bottom, 4)
            
            Toggle("Check folder age before converting", isOn: $ageToggle)
            
            if ageToggle {
                HStack {
                    Text("Max age (seconds)")
                    TextField("20", text: $ageString)
                        .onReceive(Just(ageString)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.ageString = filtered
                            }
                            self.age = Int(filtered) ?? -1
                        }
                        .frame(maxWidth: 200)
                }
            }
            
            Spacer()
            
        }
        .frame(width: 400, height: 240)
        
        .onAppear {
            fetchVars()
        }
        
        .onChange(of: ageToggle, {
            updateAge()
        })
        .onChange(of: age, {
            updateAge()
        })
        
        .background(.ultraThinMaterial)
    }
    
    func fetchVars() {
        let defaults = UserDefaults.standard
        
        age = defaults.integer(forKey: "maxAge")
        ageString = String(age)
        ageToggle = age == -1 ? false : true
        
        print(defaults.integer(forKey: "maxAge"))
    }
    
    func updateAge() {
        let defaults = UserDefaults.standard
        
        defaults.set(!ageToggle ? -1 : age, forKey: "maxAge")
        defaults.synchronize()
        
        print("update")
        print(defaults.integer(forKey: "maxAge"))
    }
}

#Preview {
    ContentView()
}
