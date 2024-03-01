//
//  spotifriendApp.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI

@main
struct spotifriendApp: App {
    var network = Network()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(network)
        }
    }
}
