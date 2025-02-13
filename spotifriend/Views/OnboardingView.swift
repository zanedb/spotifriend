//
//  OnboardingView.swift
//  spotifriend
//
//  Created by Zane on 2/18/24.
//

//
// 2025.02.13: AUTH CODE REMOVED
// BUT YOU CAN FIND IT HERE
// https://github.com/zanedb/spotifriend/pull/1/files#diff-43dc25831b195ce239697f67be12f76968d4679fa7296c66b30f28f64b8e776c
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var viewModel: FriendActivityBackend
    @State private var pulseAmount: CGFloat = 1
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.05))
                        .frame(width: 256, height: 256)
                        .scaleEffect(pulseAmount * 1.1)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.1)
                                .speed(0.05).repeatForever(autoreverses: true)) {
                                    pulseAmount = 1.1
                                }
                        }
                    HStack(alignment: .center) {
                        Spacer()
                            }
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .frame(width: showForm ? 57 : 144, height: showForm ? 57 : 144)
                                .cornerRadius(showForm ? 10 : 25.263)
                        })
                        
                        Spacer()
                    }
                }
                    .padding(.bottom, 18)
                
                Spacer()
                    
                Button(action: {
                    Task {
                        await viewModel.refreshFriends()
                    }
                }, label: {
                    Text("Let’s go")
                        .foregroundColor(.primary)
                        .colorInvert()
                        .font(.system(size: 17))
                        .bold()
                        .padding(.vertical)
                        .fillFrame(.horizontal)
                })
                    .background(.primary)
                    .cornerRadius(10)
                    
                Text(markdown: "By continuing, you agree to our\n[Terms](https://zane.app/tc) and [Privacy Policy](https://zane.app/privacy).")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15))
                    .fontWeight(.light)
                    .padding(.top, 5)
                    .padding(.bottom, -15)
                    .frame(maxWidth: 370) // Make it look good on iPad.
                    .fillFrame(.horizontal)
            }
                .padding()
        }
    }
}

#Preview {
    OnboardingView()
}
