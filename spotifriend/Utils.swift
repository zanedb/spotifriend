//
//  Utils.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import Foundation
import SwiftUI

// https://github.com/sindresorhus/Blear/blob/5326e9b891e609c23641d43b966501afe21019ca/Blear/Utilities.swift#L190
enum SSApp {
    static let idString = Bundle.main.bundleIdentifier!
    static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    static let versionWithBuild = "\(version) (\(build))"
    // static let rootName = Bundle.app.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String

    static let isFirstLaunch: Bool = {
        let key = "__hasLaunched__"

        if UserDefaults.standard.bool(forKey: key) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
    }()
}

extension String {
    // https://medium.com/@mrtrinh5293/pure-swiftui-phone-number-formatter-a-manual-approach-free-from-third-party-apis-and-uikit-75b83027e567
    func formatFromMask(mask: String) -> String {
        let cleanNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var result = ""
        var startIndex = cleanNumber.startIndex
        let endIndex = cleanNumber.endIndex
        
        for char in mask where startIndex < endIndex {
            if char == "X" {
                result.append(cleanNumber[startIndex])
                startIndex = cleanNumber.index(after: startIndex)
            } else {
                result.append(char)
            }
        }
        
        return result
    }
    
    func checkRegex(pattern: String) -> Bool {
        let result = self.range(
            of: pattern,
            options: .regularExpression
        )
        return (result != nil)
    }
}

// https://github.com/sindresorhus/Blear/blob/5326e9b891e609c23641d43b966501afe21019ca/Blear/Utilities.swift#L1881
extension Text {
    /**
    By default, `Text` only accepts Markdown when using a string literal or explicitly passing a `LocalizedStringKey`. That's a bit too magic and I prefer an explicit initializer.
    */
    init(markdown: String) {
        self.init(LocalizedStringKey(markdown))
    }
}

// https://github.com/sindresorhus/Blear/blob/5326e9b891e609c23641d43b966501afe21019ca/Blear/Utilities.swift#L1891
extension View {
    /**
    Fills the frame.
    */
    func fillFrame(
        _ axis: Axis.Set = [.horizontal, .vertical],
        alignment: Alignment = .center
    ) -> some View {
        frame(
            maxWidth: axis.contains(.horizontal) ? .infinity : nil,
            maxHeight: axis.contains(.vertical) ? .infinity : nil,
            alignment: alignment
        )
    }
}

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
