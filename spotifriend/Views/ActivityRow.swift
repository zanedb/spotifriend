//
//  ActivityRow.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ActivityRow: View {
    var imageURL: URL
    var friend: String
    var track: String
    var artist: String
    var context: String
    var isAlbum: Bool
    var isListeningNow: Bool
    var timestamp: String
    
    var body: some View {
        HStack(alignment: .top) {
            WebImage(url: imageURL)
                .resizable()
                .placeholder {
                    ProgressView()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .padding(.trailing, 5)
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) {
                Text(friend)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .lineLimit(1)
                
                HStack(spacing: 0) {
                    Text(track)
                        .lineLimit(1)
                        .font(.subheadline)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 3))
                        .padding(.horizontal, 5)
                    Text(artist)
                        .font(.subheadline)
                        .font(.system(size: 16))
                        .lineLimit(1)
                }
                    .padding(.bottom, 5)
                
                HStack {
                    Image(systemName: isAlbum ? "record.circle" : "music.note.list")
                        .font(.system(size: 15))
                    Text(context)
                        .font(.subheadline)
                        .padding(.leading, -2)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                if (isListeningNow) {
                    Image(systemName: "waveform")
                } else {
                    Text(timestamp)
                        .font(.caption)
                        .padding(.top, 2)
                }
            }
        }
    }
}

#Preview {
    List {
        ActivityRow(imageURL: URL(string: "https://www.hackingwithswift.com/samples/paul.jpg")!, friend: "Paul", track: "Glimpse of Us", artist: "Joji", context: "SMITHEREENS", isAlbum: true, isListeningNow: true, timestamp: "now")
        ActivityRow(imageURL: URL(string: "https://github.com/zanedb.png")!, friend: "Zane", track: "Lazy Bird", artist: "Tom Browne", context: "Funkin' For Jamaica", isAlbum: true, isListeningNow: true, timestamp: "now")
        ActivityRow(imageURL: URL(string: "https://github.com/lachlanjc.png")!, friend: "Lachlan", track: "Rush", artist: "Troye Sivan", context: "Something To Give Each Other", isAlbum: true, isListeningNow: true, timestamp: "now")
        ActivityRow(imageURL: URL(string: "https://github.com/matthewstanciu.png")!, friend: "Matthew", track: "Eye in the Wall", artist: "Perfume Genius", context: "Ugly Season", isAlbum: true, isListeningNow: true, timestamp: "now")
    }
    .listStyle(.inset)
}
