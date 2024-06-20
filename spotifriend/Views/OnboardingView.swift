//
//  OnboardingView.swift
//  spotifriend
//
//  Created by Zane on 2/18/24.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var network: Network
    
    @State private var pulseAmount: CGFloat = 1
    @State private var showForm = false
    @FocusState private var focusedField: FocusedField?
    
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
        let e164Number = "+1\(phoneNumber.formatFromMask(mask: "XXXXXXXXXX"))"
        // User has submitted phone number, send them SMS
        if (phoneStatus == .ready && isValidPhone) {
            // MARK: disable auth for now
            // network.authenticateWithPhone(number: e164Number)
            
            withAnimation {
                phoneStatus = .done
            }
        }
        
        // User has submitted SMS code
        if (phoneStatus == .done && isValidSms && smsStatus != .done) {
            // Sign in user
            // MARK: disable auth for now
            // network.confirmSmsCode(number: e164Number, code: smsCode)
            
            withAnimation {
                smsStatus = .done
            }
        }
        
        // Account does not exist, user has submitted username
        if (smsStatus == .done && isValidUsername && usernameStatus != .done) {
            // TODO: Validate on server side
            // For now, just proceed to full name entry and submit there ..
            
            withAnimation {
                usernameStatus = .done
            }
        }
        
        // User has submitted full name
        if (usernameStatus == .done && !name.isEmpty) {
            // Assuming name is valid ..
            
            // Update user object w/ info
            // MARK: disable auth for now
            // network.setUserInfo(username: username, name: name)
            
            withAnimation {
                nameStatus = .done
            }
            
            // MARK: disable auth for now
            network.loggedOut = false
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
                    Form {
                        if (usernameStatus == .done) {
                            HStack {
                                Chevron(status: nameStatus)
                                TextField("Enter your full name", text: $name)
                                    .font(.system(size: 18))
                                    .focused($focusedField, equals: .name)
                                    .onAppear {
                                        focusedField = .name
                                    }
                                    .onChange(of: network.user) {
                                        if (network.user!.username != nil && network.user!.name != nil) {
                                            withAnimation {
                                                nameStatus = .done
                                            }
                                            
                                            // If successful, will set loggedOut to false & end flow
                                            network.saveCredentials()
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
                                    .focused($focusedField, equals: .username)
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .onAppear {
                                        focusedField = .username
                                    }
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
                                    .focused($focusedField, equals: .sms)
                                    .keyboardType(.numberPad)
                                    .disableAutocorrection(true)
                                    .onAppear {
                                        focusedField = .sms
                                    }
                                    .onChange(of: smsCode) {
                                        if !smsCode.isEmpty {
                                            smsCode = smsCode.formatFromMask(mask: "XXXXXX")
                                            isValidSms = smsCode.checkRegex(pattern: #"^\d{3}\d{3}$"#)
                                        }
                                    }
                                    .onChange(of: network.user) {
                                        if network.user != nil {
                                            if network.user!.username == nil {
                                                // Username undefined, continue flow..
                                                withAnimation {
                                                    smsStatus = .done
                                                }
                                            } else {
                                                // If successful, will set loggedOut to false & end flow
                                                network.saveCredentials()
                                            }
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
                                .focused($focusedField, equals: .phone)
                                .keyboardType(.numberPad)
                                .disableAutocorrection(true)
                                .onAppear {
                                    focusedField = .phone
                                }
                                .onChange(of: phoneNumber) {
                                    if !phoneNumber.isEmpty {
                                        phoneNumber = phoneNumber.formatFromMask(mask: "(XXX) XXX-XXXX")
                                        isValidPhone = phoneNumber.checkRegex(pattern: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#)
                                    }
                                }
                                .onChange(of: network.codeSent) {
                                    if network.codeSent {
                                        withAnimation {
                                            phoneStatus = .done
                                        }
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
                    }
                        .formStyle(.columns)
                    
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
                            // MARK: disable auth for now
                            // showForm.toggle()
                            network.loggedOut = false
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

enum FocusedField {
    case phone, sms, username, name
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
