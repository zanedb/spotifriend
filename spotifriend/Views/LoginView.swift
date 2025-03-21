//
//  LoginView.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import SwiftUI
import WebKit

struct LoginView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer()
                
                Text("One more thing.")
                    .font(.largeTitle)
                    .bold()
                
                NavigationLink(destination: WebViewLogin()) {
                    Text("Authorize Spotify")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                        .bold()
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                }
                .background(.green)
                .cornerRadius(10)
                
                Spacer()
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
        }
    }
}

#Preview {
    LoginView()
}

class NavigationState: NSObject, ObservableObject {
    @Published var url : URL?
    let webView = WKWebView()
}

extension NavigationState: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.url = webView.url
        
        Task {
            if FriendActivityBackend.shared.state == .loggedOut {
                FriendActivityBackend.shared.checkLoginStatus()
            }
        }
        
        if (self.url?.absoluteString.starts(with: "https://accounts.google.com/") ?? false) {
            print("google link discovered woah \(self.url?.absoluteString ?? "none" )")
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15"
        }
    }
}


struct WebView : UIViewRepresentable {
    let request: URLRequest
    var navigationState : NavigationState
        
    func makeUIView(context: Context) -> WKWebView  {
        let webView = navigationState.webView
        webView.navigationDelegate = navigationState
        webView.load(request)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct WebViewLogin: View {
    @StateObject var navigationState = NavigationState()
    
    init() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }

    var body: some View {
        VStack {
            WebView(request: URLRequest(url: URL(string: "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!), navigationState: navigationState)
        }
    }
}
