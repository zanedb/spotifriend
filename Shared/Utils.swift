//
//  Utils.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import Foundation
import SwiftUI

// MARK: - App Global Helpers
// https://github.com/sindresorhus/Blear/blob/5326e9b891e609c23641d43b966501afe21019ca/Blear/Utilities.swift#L190
enum SSApp {
    static let idString = Bundle.main.bundleIdentifier!
    static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let datedVersion = "2025.02 (\(version))"
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

// MARK: - Markdown Support
// https://github.com/sindresorhus/Blear/blob/5326e9b891e609c23641d43b966501afe21019ca/Blear/Utilities.swift#L1881
extension Text {
    /**
    By default, `Text` only accepts Markdown when using a string literal or explicitly passing a `LocalizedStringKey`. That's a bit too magic and I prefer an explicit initializer.
    */
    init(markdown: String) {
        self.init(LocalizedStringKey(markdown))
    }
}

// MARK: - View.fillFrame()
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


// MARK: - Icon File Name
// https://stackoverflow.com/a/65153628
extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}
