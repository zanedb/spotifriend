//
//  ContentView.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("alwaysDark") var alwaysDark = false
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
                    if (viewModel.state == .loading) {
                        ToolbarItem {
                            ProgressView()
                        }
                    }
                }
        }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: Binding(
                get: { viewModel.state == .loggedOut },
                set: { _ in }
            )) {
                LoginView()
            }
            .preferredColorScheme(alwaysDark ? .dark : colorScheme)
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
