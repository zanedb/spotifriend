//
//  Structs.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import Foundation

// MARK: - Spotify Access Token JSON
struct SpotifyAccessToken: Codable {
    let accessToken: String
    let isAnonymous: Bool
}

// MARK: - SpotifyIdentifiable
protocol SpotifyIdentifiable: Identifiable {
    var uri: String { get }
    var url: URL { get }
}

extension SpotifyIdentifiable {
    var id: String { uri }
}

// MARK: - FriendList
struct FriendList: Codable {
    let friends: [Friend]
}

// MARK: - Friend
struct Friend: Codable, Identifiable {
    let timestamp: Int
    let user: User
    let track: Track
    let id: String
    
    var formattedTimestamp: (display: String, isNow: Bool) {
        formatTimestamp(timestamp)
    }
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, user, track
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decode(Int.self, forKey: .timestamp)
        user = try container.decode(User.self, forKey: .user)
        track = try container.decode(Track.self, forKey: .track)
        id = user.uri
    }
}

// MARK: - Track
extension Friend {
    struct Track: Codable, Identifiable, SpotifyIdentifiable {
        let uri: String
        let name: String
        let url: URL
        let imageURL: URL?
        let album: Album
        let artist: Album
        let context: Context
        
        var id: String { uri }
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
            case imageURL = "imageUrl"
            case album, artist, context
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uri = try container.decode(String.self, forKey: .uri)
            name = try container.decode(String.self, forKey: .name)
            imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
                .flatMap { URL(string: "https" + $0.dropFirst(4)) }
            album = try container.decode(Album.self, forKey: .album)
            artist = try container.decode(Album.self, forKey: .artist)
            context = try container.decode(Context.self, forKey: .context)
            url = SpotifyURLBuilder.build(fromURI: uri)
        }
    }
}

// MARK: - Album
extension Friend {
    struct Album: Codable, Identifiable, SpotifyIdentifiable {
        let uri: String
        let name: String
        let url: URL
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uri = try container.decode(String.self, forKey: .uri)
            name = try container.decode(String.self, forKey: .name)
            url = SpotifyURLBuilder.build(fromURI: uri)
        }
    }
}

// MARK: - Context
extension Friend {
    struct Context: Codable, Identifiable, SpotifyIdentifiable {
        let uri: String
        let name: String
        let index: Int
        let url: URL
        
        private enum CodingKeys: String, CodingKey {
            case uri, name, index
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uri = try container.decode(String.self, forKey: .uri)
            name = try container.decode(String.self, forKey: .name)
            index = try container.decode(Int.self, forKey: .index)
            url = SpotifyURLBuilder.build(fromURI: uri)
        }
    }
}

// MARK: - User
extension Friend {
    struct User: Codable, Identifiable, SpotifyIdentifiable {
        let uri: String
        let name: String
        let imageURL: URL?
        let url: URL
        
        private enum CodingKeys: String, CodingKey {
            case uri, name
            case imageURL = "imageUrl"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uri = try container.decode(String.self, forKey: .uri)
            name = try container.decode(String.self, forKey: .name)
            imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
                .flatMap { URL(string: $0) }
            url = SpotifyURLBuilder.buildUserURL(fromURI: uri)
        }
    }
}

// MARK: - Spotify URL Builder
enum SpotifyURLBuilder {
    static func build(fromURI uri: String) -> URL {
        let components = uri.split(separator: ":")
        guard components.count >= 2 else {
            return URL(string: "https://open.spotify.com")!
        }
        
        let type = components[1]
        let id = components[2]
        return URL(string: "https://open.spotify.com/\(type)/\(id)")!
    }
    
    static func buildUserURL(fromURI uri: String) -> URL {
        let userId = uri.split(separator: ":").last ?? ""
        return URL(string: "https://open.spotify.com/user/\(userId)")!
    }
}

// MARK: - Timestamp Formatting
func formatTimestamp(_ timestamp: Int) -> (display: String, isNow: Bool) {
    let timeStamp = Int(abs(Date.init(timeIntervalSince1970: TimeInterval((timestamp/1000))).timeIntervalSinceNow) / 60)
    var timeString: String
    var isNow = false
    
    if (timeStamp > (24 * 60)) {
        timeString = "\(timeStamp / (24 * 60))d"
    }
    else if (timeStamp > 60) {
        timeString = "\(timeStamp / 60)hr"
    }
    else if (timeStamp > 5) {
        timeString = "\(timeStamp)m"
    }
    else {
        timeString = "now"; isNow = true
    }
    
    return (timeString, isNow)
}

#if DEBUG
// MARK: - Preview Helpers
// Ugh, I can't get this to work.. later..
//extension Friend {
//    static var preview: Friend {
//        Friend(
//            timestamp: Int(Date().timeIntervalSince1970 * 1000),
//            user: .preview,
//            track: .preview,
//            id: "preview"
//        )
//    }
//}

extension Friend.User {
    static var preview: Friend.User {
        try! JSONDecoder().decode(Friend.User.self, from: """
        {
            "uri": "spotify:user:previewuser",
            "name": "Preview User",
            "imageUrl": null
        }
        """.data(using: .utf8)!)
    }
}

extension Friend.Track {
    static var preview: Friend.Track {
        try! JSONDecoder().decode(Friend.Track.self, from: """
        {
            "uri": "spotify:track:previewtrack",
            "name": "Preview Track",
            "imageUrl": null,
            "album": {
                "uri": "spotify:album:previewalbum",
                "name": "Preview Album"
            },
            "artist": {
                "uri": "spotify:artist:previewartist",
                "name": "Preview Artist"
            },
            "context": {
                "uri": "spotify:playlist:previewplaylist",
                "name": "Preview Playlist",
                "index": 0
            }
        }
        """.data(using: .utf8)!)
    }
}
#endif
