//
//  Network.swift
//  spotifriend
//
//  Created by Zane on 2/21/24.
//

import Foundation
import Combine

class Network: ObservableObject {
    let API_BASE = "https://spot.zane.app/api"
    
    @Published var codeSent: Bool = false
    @Published var token: String?
    @Published var user: User?
    @Published var loggedOut: Bool = false
    
    init() {
        guard let token = UserDefaults.standard.string(forKey: "apiAuthToken") else {
            loggedOut = true
            return
        }
        self.token = token
    }
    
    func authenticateWithPhone(number: String) {
        let request = apiRequest(endpoint: "/auth/phone", json: ["number": number], method: "POST", authorization: nil)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard data != nil else { return }
                
                DispatchQueue.main.async {
                    self.codeSent = true
                }
            }
        }
        
        dataTask.resume()
    }
    
    func confirmSmsCode(number: String, code: String) {
        let request = apiRequest(endpoint: "/auth/confirm", json: ["number": number, "code": code], method: "POST", authorization: nil)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    do {
                        let authorization = try JSONDecoder().decode(AuthorizationResponse.self, from: data)
                        self.token = authorization.authorization
                        self.getUserObject()
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func getUserObject() {
        let request = apiRequest(endpoint: "/users/me", json: [:], method: "GET", authorization: self.token)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        self.user = user
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func setUserInfo(username: String, name: String) {
        let request = apiRequest(endpoint: "/users/me", json: ["username": username, "name": name], method: "POST", authorization: self.token)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        self.user = user
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    func saveCredentials() {
        UserDefaults.standard.set(self.token, forKey: "apiAuthToken")
        loggedOut = false
    }
    
    func logout() {
        loggedOut = true
        UserDefaults.standard.set(nil, forKey: "apiAuthToken")
    }
    
    private func apiRequest(endpoint: String, json: [String: Any], method: String, authorization: String?) -> URLRequest {
        guard let url = URL(string: API_BASE + endpoint) else { fatalError("Missing URL") }
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        if (method != "GET") { urlRequest.httpBody = jsonData }
        if (authorization != nil) { urlRequest.setValue( "Bearer \(authorization ?? "")", forHTTPHeaderField: "Authorization") }
        
        return urlRequest
    }
}
