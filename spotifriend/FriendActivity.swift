//
//  FriendActivity.swift
//  spotifriend
//
//  Created by Zane on 8/13/23.
//

import Foundation
import Network
import SwiftUI
import WidgetKit
import WebKit
import os
import SDWebImage

@MainActor final class FriendActivityBackend: ObservableObject {
    // MARK: - State Enums
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        case offline
        case loggedOut
    }
    
    struct NotificationState: Identifiable {
        let id = UUID()
        let message: String
        let timestamp = Date()
    }
    
    // MARK: - Properties
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FriendActivityBackend.self)
    )
    private let queue = DispatchQueue(label: "FriendActivityBackend.Network")
    private let networkMonitor = NWPathMonitor()
    
    static let shared = FriendActivityBackend()
    
    @Published private(set) var state: State = .idle
    @Published private(set) var friendArray: [Friend]?
    @Published private(set) var notificationState: NotificationState?

    // MARK: - Initialization
    init() {
        setupNetworkMonitoring()
    }

    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self else { return }
                
                switch path.status {
                case .satisfied:
                    self.logger.debug("Network connection satisfied")
                    if case .loggedOut = self.state { return }
                    
                    await self.refreshFriends()
                    
                default:
                    self.state = .offline
                }
            }
        }
        networkMonitor.start(queue: queue)
    }

    // MARK: - Public Methods
    func refreshFriends() async {
        if state == .loading { return }
        
        state = .loading
        
        do {
            let friends = try await fetchFriendList()
            state = .loaded
            friendArray = friends.reversed()
        } catch {
            handleError(error)
        }
    }
    
    func logout() {
        state = .loggedOut
        UserDefaults.standard.removeObject(forKey: "spDcCookie")
        showNotification("Logged out.")
    }
    
    func checkLoginStatus() {
        Task { @MainActor in
            await checkSpotifyCookie()
        }
    }

    // MARK: - Private Methods
    private func fetchFriendList() async throws -> [Friend] {
        guard let cookie = UserDefaults.standard.string(forKey: "spDcCookie") else {
            throw AuthError.noCookie
        }
        
        let accessToken = try await fetchAccessToken(cookie: cookie)
        return try await fetchFriends(accessToken: accessToken)
    }
    
    private func fetchAccessToken(cookie: String) async throws -> String {
        let tokenResponse: accessTokenJSON = try await fetch(
            urlString: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player",
            httpValue: "sp_dc=\(cookie)",
            httpField: "Cookie",
            method: .get
        )
        return tokenResponse.accessToken
    }
    
    private func fetchFriends(accessToken: String) async throws -> [Friend] {
        let response: Welcome = try await fetch(
            urlString: "https://guc-spclient.spotify.com/presence-view/v1/buddylist",
            httpValue: "Bearer \(accessToken)",
            httpField: "Authorization",
            method: .get
        )
        return response.friends
    }
    
    private func fetch<T: Decodable>(
        urlString: String,
        httpValue: String,
        httpField: String,
        method: HTTPMethod
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(httpValue, forHTTPHeaderField: httpField)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw AuthError.unauthorized
        } else if httpResponse.statusCode == 429 {
            throw NetworkError.tooManyRequests
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func checkSpotifyCookie() async {
        try? await Task.sleep(for: .seconds(1))
        
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self else { return }
            
            for cookie in cookies where cookie.name == "sp_dc" {
                UserDefaults.standard.set(cookie.value, forKey: "spDcCookie")
                self.state = .idle
                Task {
                    await self.refreshFriends()
                }
                break
            }
        }
    }
    
    private func showNotification(_ message: String) {
        notificationState = NotificationState(message: message)
        print("NOTIFICATION " + message)
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if notificationState?.timestamp == notificationState?.timestamp {
                notificationState = nil
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let message: String
        
        switch error {
        case AuthError.unauthorized, AuthError.noCookie:
            logout()
            return
        case NetworkError.tooManyRequests:
            message = "Too many requests. Try again later."
        default:
            message = "Error: \(error.localizedDescription)"
        }
        
        state = .error(message)
        showNotification(message)
    }
}
    
// MARK: - Supporting Types
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum AuthError: Error {
    case unauthorized
    case noCookie
}

enum NetworkError: Error {
    case invalidResponse
    case tooManyRequests
}
