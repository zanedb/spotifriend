//
//  ActivityList.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI

struct ActivityList: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        switch(viewModel.state) {
        case .error(_):
            ErrorView(icon: "exclamationmark.triangle.fill", title: "Uh-oh!", subtitle: viewModel.notificationState?.message ?? "An error occurred.")
        case .loading, .loaded, .offline:
            VStack {
                if let friendArray = viewModel.friendArray {
                    List(friendArray) { friend in
                        Menu {
                            Link(destination: friend.track.url) {
                                Label("Play", systemImage: "play")
                            }
                            Link(destination: friend.user.url) {
                                Label("View Profile", systemImage: "person")
                            }
                            Link(destination: friend.track.artist.url) {
                                Label("View Artist", systemImage: "music.mic.circle")
                            }
                            Link(destination: friend.track.album.url) {
                                Label("View Album", systemImage: "record.circle")
                            }
                            if (friend.track.context.name != friend.track.artist.name && friend.track.context.name != friend.track.album.name) {
                                Link(destination: friend.track.context.url) {
                                    Label("View Playlist", systemImage: "music.note")
                                }
                            }
                        } label: {
                            ActivityRow(friend: friend)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.inset)
                    .refreshable {
                        await viewModel.refreshFriends()
                    }
                    
                    if (friendArray.count == 0) {
                        ErrorView(icon: "moon.zzz", title: "No Friends", subtitle: "Go forth and make some.")
                    }
                } else if (viewModel.state == .offline) {
                    ErrorView(icon: "wifi.slash", title: "Network Unavailable", subtitle: "This sucks for both of us.")
                }
            }
                .onReceive(timer) { _ in
                    guard viewModel.state != .loggedOut else { return }
                    
                    Task {
                        await viewModel.refreshFriends()
                    }
                }
        default:
            EmptyView()
        }
    }
}
