//
//  ActivityList.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI
//import SwiftUIBackports

struct ActivityList: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if let friendArray = viewModel.friendArray {
            VStack {
                ZStack {
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
                            ActivityRow(imageURL: friend.user.imageURL!, friend: friend.user.name, track: friend.track.name, artist: friend.track.artist.name, context: friend.track.context.name, isAlbum: friend.track.context.uri == friend.track.album.uri, isListeningNow: friend.formattedTimestamp.isNow, timestamp: friend.formattedTimestamp.display)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.inset)
                    .refreshable {
                        await viewModel.refreshFriends()
                    }
                    
                    switch(viewModel.state) {
                    case .loaded:
                        if (friendArray.count == 0) {
                            ErrorView(icon: "moon.zzz", title: "No Friends", subtitle: "Go forth and make some.")
                        }
                    case .offline:
                        ErrorView(icon: "wifi.slash", title: "Network Unavailable", subtitle: "This sucks for both of us.")
                    case .loading:
                        EmptyView()
                    case .loggedOut:
                        EmptyView()
                    case .error(_):
                        ErrorView(icon: "wifi.slash", title: "Uh-oh!", subtitle: viewModel.notificationState?.message ?? "An error occurred.")
                    default:
                        ErrorView(icon: "wifi.slash", title: "Uh-oh!", subtitle: viewModel.notificationState?.message ?? "An error occurred.")
                    }
                }
            }
                .onReceive(timer) { _ in
                    if (viewModel.state != .loggedOut) {
                        Task {
                            await viewModel.refreshFriends()
                        }
                    }
                }
        } else {
            ProgressView()
        }
    }
}
