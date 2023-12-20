//
//  LoginView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 11/25/23.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var ViewModel: AuthViewModel
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Image
                    Image("logo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 120)
                        .padding(.vertical, 32)

                    // Form fields
                    VStack(spacing: 24) {
                        inputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                            .autocapitalization(.none)

                        inputView(text: $password, title: "Password", placeholder: "Enter Your Password", isSecureField: true)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Sign-in button
                    Button {
                        Task {
                            do {
                                try await ViewModel.signIn(withEmail: email, password: password)
                            } catch {
                                showAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("Sign In")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(isFormValid ? Color.blue : Color.gray.opacity(0.5))
                    .disabled(!isFormValid)
                    .cornerRadius(10)
                    .padding(.top, 24)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Invalid Credentials"),
                            message: Text("Please check your email and password and try again."),
                            dismissButton: .default(Text("OK"))
                        )
                    }

                    Spacer()

                    // Sign-up button
                    NavigationLink(destination: registrationView().navigationBarBackButtonHidden(true)) {
                        HStack {
                            Text("Don't have an account?")
                            Text("Sign Up")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                    }
                }
                .padding()
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5
    }
}

#Preview {
    LoginView()
}
