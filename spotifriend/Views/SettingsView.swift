//
//  SettingsView.swift
//  spotifriend
//
//  Created by Zane on 11/17/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: FriendActivityBackend
    @AppStorage("alwaysDark") var alwaysDark = false
    @AppStorage("monospaced") var monospaced = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(action: { viewModel.logout() }) {
                        HStack {
                            Text("Disconnect")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                        }
                            .tint(.red)
                    }
                } header: {
                    Text("Account")
                }
                
                Section {
                    Toggle(isOn: $alwaysDark, label: {
                        Text("Always Dark")
                    })
                    Toggle(isOn: $monospaced, label: {
                        Text("Monospaced")
                    })
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2023.11 (\(SSApp.version))")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink {
                        ErrorView(icon: monospaced ? "eye.fill" : "questionmark", title: "", subtitle: "")
                    } label: {
                        Text("Libraries")
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text(markdown: "\n\nmade with ♥ by zdb\n\n.·:*¨༺ ༻¨*:·.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 370) // Make it look good on iPad.
                        .fillFrame(.horizontal)
                }
            }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
        }
    }
}

#Preview {
    SettingsView()
}
