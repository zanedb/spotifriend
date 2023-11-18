//
//  ContentView.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @StateObject var viewModel = FriendActivityBackend.shared
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ActivityList()
                .navigationTitle("Friend Activity")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        
                        Button(action: { showingSettings.toggle() }) {
                            Label("Settings", systemImage: "gearshape")
                        }
                            .buttonStyle(.plain)
                    }
                    if (viewModel.isLoading) {
                        ToolbarItem {
                            ProgressView()
                        }
                    }
                }
        }
            #if DEBUG
            .alert(isPresented: $viewModel.showDebugAlert) {
                Alert(title: Text("Debug Log"), message: Text(viewModel.debugError ?? "no error. suspicious"), dismissButton: .cancel())
            }
            #endif
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
