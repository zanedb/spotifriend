//
//  FriendActivityWidget.swift
//  FriendActivityWidget
//
//  Created by Zane on 2/13/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FriendActivityEntry {
        FriendActivityEntry(date: Date(), friends: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (FriendActivityEntry) -> ()) {
        let entry = FriendActivityEntry(date: Date(), friends: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FriendActivityEntry>) -> ()) {
        Task {
            do {
                let friends = try await FriendActivityBackend.shared.fetchFriendList()
                let entry = FriendActivityEntry(date: Date(), friends: friends)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                let entry = FriendActivityEntry(date: Date(), friends: [])
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
                completion(timeline)
            }
        }
    }
}

struct FriendActivityEntry: TimelineEntry {
    let date: Date
    let friends: [Friend]
}

struct FriendActivityWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            if entry.friends.isEmpty {
                Text("No friends currently listening.")
                    .foregroundColor(.secondary)
            } else {
                let displayFriends = Array(entry.friends.prefix(family == .systemLarge ? 4 : 2))
                
                ForEach(0..<displayFriends.count, id: \.self) { index in
                    let friend = displayFriends[index]
                    
                    WidgetActivityRow(friend: friend)
                        .padding(.vertical, 8)
                        .overlay(
                            // Create List-esque trailing border on all but last child
                            Group {
                                if index != displayFriends.count - 1 {
                                    Rectangle()
                                        .frame(height: 0.5)
                                        .foregroundColor(Color(.systemGray4))
                                        .offset(y: family == .systemLarge ? 8 : 6)
                                }
                            },
                            alignment: .bottom
                        )
                    
                    Spacer()
                }
            }
        }
    }
}

struct WidgetActivityRow: View {
    var friend: Friend
    
    var body: some View {
        HStack(alignment: .top) {
            Link(destination: URL(string: "spotifriendWidget://play?id=\(friend.track.uri.split(separator: ":")[2])")!) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.green)
            }
                .padding(.trailing, 4)
            
            VStack(alignment: .leading) {
                Text(friend.user.name)
                    .font(.headline)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .padding(.bottom, 1)
                Text("\(friend.track.name) • \(friend.track.artist.name)")
                    .font(.subheadline)
                    .font(.system(size: 16))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                if (friend.formattedTimestamp.isNow) {
                    Image(systemName: "waveform")
                } else {
                    Text(friend.formattedTimestamp.display)
                        .font(.caption)
                        .padding(.top, 2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


@main
struct FriendActivityWidget: Widget {
    let kind: String = "FriendActivityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FriendActivityWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Friend Activity")
        .description("See what your friends are listening to.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
