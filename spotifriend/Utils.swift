//
//  Utils.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import Foundation

func getSpotifyUrl(initialUrl: String) -> URL {
    // convert Spotify URI to open.spotify.com URL
    // why open.spotify.com? so that website opens if user doesn't have spotify app installed
    var spotifyURL = initialUrl
    spotifyURL.insert(contentsOf: "https://open.", at: spotifyURL.startIndex)
    spotifyURL.insert(contentsOf: ".com/", at: spotifyURL.index(spotifyURL.startIndex, offsetBy: 20))
    spotifyURL.remove(at: spotifyURL.index(spotifyURL.startIndex, offsetBy: 25))
    spotifyURL.remove(at: spotifyURL.index(spotifyURL.endIndex, offsetBy: -23))
    spotifyURL.insert(contentsOf: "/", at: spotifyURL.index(spotifyURL.endIndex, offsetBy: -22))
    return URL(string: spotifyURL)!
}

// Spotify custom names have different URL length. Needs separate function
// TODO: store url, don't run function everytime new json loaded
func getSpotifyUserUrl(initialUrl: String) -> URL {
    var spotifyURL = initialUrl
    if (spotifyURL.count == 35){
        return getSpotifyUrl(initialUrl: initialUrl)
    }
    spotifyURL.insert(contentsOf: "https://open.", at: spotifyURL.startIndex)
    spotifyURL.insert(contentsOf: ".com/", at: spotifyURL.index(spotifyURL.startIndex, offsetBy: 20))
    spotifyURL.remove(at: spotifyURL.index(spotifyURL.startIndex, offsetBy: 25))
    let index = spotifyURL.lastIndex(of: ":")!
    spotifyURL.remove(at: index)
    spotifyURL.insert(contentsOf: "/", at: index)
    return URL(string: spotifyURL)!
}

func timePlayer(initialTimeStamp: Int) -> (humanTimestamp: String, nowOrNot: Bool) {
    let timeStamp = Int(abs(Date.init(timeIntervalSince1970: TimeInterval((initialTimeStamp/1000))).timeIntervalSinceNow)/60)
    var timeString: String
    var nowOrNot = false
    if (timeStamp > (24 * 60)) {
        timeString = "\(timeStamp / (24 * 60)) d"
    }
    else if (timeStamp > 60){
        timeString = "\(timeStamp / 60) hr"
    }
    else if (timeStamp > 5){
        timeString = "\(timeStamp) m"
    }
    else{
        timeString = "now"; nowOrNot = true
    }
    return (timeString, nowOrNot)

}
