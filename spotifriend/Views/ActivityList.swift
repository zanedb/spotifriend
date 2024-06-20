//
//  ActivityList.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI
import SwiftUIBackports

struct ActivityList: View {
    @EnvironmentObject var viewModel: FriendActivityBackend
    private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ZStack {
                if viewModel.networkUp {
                    if let friendArray = viewModel.friendArray {
                        if friendArray.count == 0 {
                            ErrorView(icon: "moon.zzz", title: "No Friends", subtitle: "Go forth and make some.")
                        } else {
                            List {
                                ForEach(friendArray) { friend in
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
                                        ActivityRow(imageURL: friend.user.imageURL!, friend: friend.user.name, track: friend.track.name, artist: friend.track.artist.name, context: friend.track.context.name, isAlbum: friend.track.context.uri == friend.track.album.uri, isListeningNow: friend.humanTimestamp.nowOrNot, timestamp: friend.humanTimestamp.humanTimestamp)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .listStyle(.inset)
                            .backport.refreshable {
                                print("logged, getfriendactivitynoanimation called from refreshing friendlist")
                                Task {
                                    await viewModel.actor.getFriends()
                                    #if RELEASE
                                    let count = UserDefaults.standard.integer(forKey: "successCount") ?? 0
                                    if (count > 20) {
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                                            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                                SKStoreReviewController.requestReview(in: scene)
                                            }
                                        }
                                    }
                                    #endif
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                else {
                    ErrorView(icon: "wifi.slash", title: "Network Unavailable", subtitle: "This sucks for both of us.")
                }
            }
        }
        .onReceive(timer) { _ in
            if (!viewModel.loggedOut) {
                viewModel.isLoading = true
                Task {
                    print("timer works")
                    await viewModel.actor.getFriends()
                }
            }
            else {
                print("timer worked but it's logged out so nothign happened")
            }
        }
        
        
//            List {
//                ForEach(tempActivity, id: \.id) { friend in
//                    ActivityRow(imageURL: friend.imageURL, friend: friend.friendName, track: friend.trackName, artist: friend.artistName, context: friend.contextName, isAlbum: friend.isAlbum, isListeningNow: friend.isListeningNow, timestamp: friend.timestamp)
//                }
//            }
//            .listStyle(.inset)
    }
}
