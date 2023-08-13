//
//  spotifriendApp.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI

@main
struct spotifriendApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
