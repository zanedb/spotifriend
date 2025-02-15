//
//  ActivityRow.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI

struct ActivityRow: View {
    @AppStorage("monospaced") var monospaced = false
    
    var friend: Friend
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: friend.user.imageURL!) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
                    .scaledToFit()
            }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(friend.user.name)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .lineLimit(1)
                    .monospaced(monospaced)
            
                Text("\(friend.track.name) • \(friend.track.artist.name)")
                    .font(.subheadline)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .monospaced(monospaced)
                    .padding(.bottom, 5)
                
                HStack {
                    Image(systemName:
                        friend.track.context.uri == friend.track.album.uri
                            ? "record.circle"
                            : "music.note.list"
                    )
                        .font(.system(size: 15))
                    Text(friend.track.context.name)
                        .font(.subheadline)
                        .padding(.leading, -2)
                        .lineLimit(1)
                        .monospaced(monospaced)
                }
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                if (friend.formattedTimestamp.isNow) {
                    Image(systemName: "waveform")
                        .symbolEffect(.breathe.pulse.byLayer, options: .repeat(.continuous).speed(0.5))
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
