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
    
    var body: some View {
        NavigationView {
            ActivityList()
                .navigationTitle("Friend Activity")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Menu {
                            Button(action: { viewModel.logout() }) {
                                Label("Log out", systemImage: "rectangle.portrait.and.arrow.forward")
                            }
                        } label: {
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
            .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
