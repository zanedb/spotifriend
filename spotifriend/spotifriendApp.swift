//
//  spotifriendApp.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI

@main
struct spotifriendApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }
}

// MARK: - Handle Incoming URL
// Right now, used to open Spotify links from the widget
private func handleIncomingURL(_ url: URL) {
    guard url.scheme == "spotifriendWidget" else {
        return
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        print("Invalid URL")
        return
    }
    
    guard let action = components.host, action == "play" else {
        print("Unknown URL scheme")
        return
    }

    guard let trackId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
        print("Track ID not found")
        return
    }
    
    openSpotifyURL(trackId)
}

private func openSpotifyURL(_ trackId: String) {
    guard let url = URL(string: "spotify:track:\(trackId)") else {
        print("Invalid URL")
        return
    }
    
    if UIApplication.shared.canOpenURL(url) {
        // Open Spotify app if installed
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        // Fallback to opening Spotify website
        if let webURL = URL(string: "https://open.spotify.com/track/\(trackId)") {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
