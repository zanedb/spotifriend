//
//  OnboardingView.swift
//  spotifriend
//
//  Created by Zane on 2/18/24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var pulseAmount: CGFloat = 1
    @State private var showForm = false
    
    @State private var phoneNumber: String = ""
    @State private var smsCode: String = ""
    @State private var username: String = ""
    @State private var name: String = ""
    
    @State private var isValidPhone: Bool = false
    @State private var isValidSms: Bool = false
    @State private var isValidUsername: Bool = false
    
    @State private var phoneStatus: Status = .ready
    @State private var smsStatus: Status = .ready
    @State private var usernameStatus: Status = .ready
    @State private var nameStatus: Status = .ready
    
    func next() {
        // User has submitted phone number
        if (phoneStatus == .ready && isValidPhone) {
            // ...
            
            withAnimation {
                phoneStatus = .done
            }
        }
        
        // User has submitted SMS code
        if (phoneStatus == .done && isValidSms) {
            // ...
            // IF account exists, login & bring user to next page
            
            withAnimation {
                smsStatus = .done
            }
        }
        
        // Account does not exist, user has submitted username
        if (smsStatus == .done && isValidUsername) {
            // Validate on server side
            // ..
            
            withAnimation {
                usernameStatus = .done
            }
        }
        
        // User has submitted full name
        if (usernameStatus == .done && !name.isEmpty) {
            // Assuming name is valid ..
            
            // Update user object w/ info
            // ..
            
            withAnimation {
                nameStatus = .done
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if (!showForm) {
                    Spacer()
                }
                
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.05))
                        .frame(width: showForm ? 48 : 256, height: showForm ? 48 :  256)
                        .scaleEffect(pulseAmount * 1.1)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.1)
                                .speed(0.05).repeatForever(autoreverses: true)) {
                                    pulseAmount = 1.1
                                }
                        }
                    HStack(alignment: .center) {
                        Spacer()
                        Button(action: {
                            if(showForm) {
                                withAnimation {
                                    showForm.toggle()
                                }
                            }
                        }, label: {
                            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                .resizable()
                                .frame(width: showForm ? 57 : 144, height: showForm ? 57 : 144)
                                .cornerRadius(showForm ? 10 : 25.263)
                        })
                            .disabled(!showForm || phoneStatus == .done)
                        Spacer()
                    }
                }
                    .padding(.bottom, 18)
                
                if (showForm) {
                    if (usernameStatus == .done) {
                        HStack {
                            Chevron(status: nameStatus)
                            TextField("Enter your full name", text: $name)
                                .font(.system(size: 18))
                                .onChange(of: name) {
                                   if !name.isEmpty {
                                       // TODO: validate name ..?
                                       // ..
                                    }
                                 }
                                .onSubmit { next() }
                                .disabled(nameStatus == .done || nameStatus == .loading)
                        }
                            .padding(.vertical, -5)
                            .foregroundColor(nameStatus == .done ? .gray : .primary)
                    }
                    
                    if (smsStatus == .done) {
                        HStack {
                            Chevron(status: usernameStatus)
                            TextField("Choose a username", text: $username)
                                .font(.system(size: 18))
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.never)
                                .onChange(of: username) {
                                   if !username.isEmpty {
                                       // Validate username contains only alphanumeric & _
                                       isValidUsername = username.checkRegex(pattern: #"^[A-Za-z0-9_]{1,20}$"#)
                                       usernameStatus = isValidUsername ? .ready : .error
                                    }
                                 }
                                .onSubmit { next() }
                                .disabled(usernameStatus == .done || usernameStatus == .loading)
                        }
                            .padding(.vertical, -5)
                            .foregroundColor(usernameStatus == .done ? .gray : .primary)
                    }
                    
                    if (phoneStatus == .done) {
                        HStack {
                            Chevron(status: smsStatus)
                            TextField("Enter SMS code", text: $smsCode)
                                .font(.system(size: 18))
                                .keyboardType(.numberPad)
                                .disableAutocorrection(true)
                                .onChange(of: smsCode) {
                                   if !smsCode.isEmpty {
                                       smsCode = smsCode.formatFromMask(mask: "XXX-XXX")
                                       isValidSms = smsCode.checkRegex(pattern: #"^\d{3}[-]\d{3}$"#)
                                    }
                                 }
                                .onSubmit { next() }
                                .disabled(smsStatus == .done || smsStatus == .loading)
                        }
                            .padding(.vertical, -5)
                            .foregroundColor(smsStatus == .done ? .gray : .primary)
                    }
                    
                    HStack {
                        Chevron(status: phoneStatus)
                        TextField("Enter your phone number", text: $phoneNumber)
                            .font(.system(size: 18))
                            .keyboardType(.numberPad)
                            .disableAutocorrection(true)
                            .onChange(of: phoneNumber) {
                               if !phoneNumber.isEmpty {
                                   phoneNumber = phoneNumber.formatFromMask(mask: "(XXX) XXX-XXXX")
                                   isValidPhone = phoneNumber.checkRegex(pattern: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#)
                                }
                             }
                            .onSubmit { next() }
                            .disabled(phoneStatus == .done || phoneStatus == .loading)
                    }
                        .padding(.vertical, -5)
                        .foregroundColor(phoneStatus == .done ? .gray : .primary)
                        .transition(.asymmetric(
                            insertion: .push(from: .bottom).animation(.easeInOut(duration: 0.5)),
                            removal: .push(from: .top).animation(.easeInOut(duration: 0.08)))
                        )
                    
                    Spacer()
                    
                    Button(action: { next() }, label: {
                        Text("Next")
                            .bold(true)
                            .fillFrame(.horizontal)
                    })
                    .disabled(!((phoneStatus == .ready && isValidPhone) || (smsStatus == .ready && isValidSms) || (usernameStatus == .ready && isValidUsername) || (nameStatus == .ready && !name.isEmpty)))
                } else {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showForm.toggle()
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
                    
                    Text(markdown: "By continuing, you agree to our\n[Terms](https://zane.app/terms) and [Privacy Policy](https://zane.app/privacy).")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .padding(.top, 5)
                        .padding(.bottom, -15)
                        .frame(maxWidth: 370) // Make it look good on iPad.
                        .fillFrame(.horizontal)
                }
            }
                .padding()
        }
    }
}

enum Status {
    case ready
    case loading
    case error
    case done
}

struct Chevron: View {
    var status: Status = .ready
    
    var body: some View {
        VStack {
            switch status {
            case .ready:
                Image(systemName: "chevron.right")
            case .loading:
                ProgressView()
            case .error:
                Image(systemName: "xmark")
            case .done:
                Image(systemName: "checkmark")
            }
        }
            .frame(width: 16, height: 16)
            .padding(.horizontal, 4)
            .padding(.vertical, 16)
    }
}

#Preview {
    OnboardingView()
}
