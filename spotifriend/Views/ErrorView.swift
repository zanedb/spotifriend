//
//  ErrorView.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI

struct ErrorView: View {
    var icon: String
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: icon)
                .foregroundColor(.blue.opacity(0.70))
                .font(.system(size: 48))
                .padding(.top, 50)
            Text(title)
                .padding(.top, 40)
                .bold()
                .foregroundColor(.primary)
                .font(.system(size: 22))
            Text(subtitle)
                .padding(.top, 10)
                .foregroundColor(.gray)
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
        }
            .frame(maxWidth: 320, maxHeight: .infinity)
    }
}

struct ErrorViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ErrorView(icon: "moon.zzz", title: "No Friends", subtitle: "Go forth and make some.")
                .navigationTitle("Friend Activity")
                .navigationBarTitleDisplayMode(.inline)
        }
        NavigationView {
            ErrorView(icon: "wifi.slash", title: "Network Unavailable", subtitle: "Go to a library, perhaps?")
                .navigationTitle("Friend Activity")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
