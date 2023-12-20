//
//  registrationView.swift
//  StockMarketApp
//
//  Created by shubham sharad bagal on 11/25/23.
//

import SwiftUI

struct registrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            // Image
            Image(systemName: "person.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)

            // Form fields
            ScrollView {
                VStack(spacing: 24) {
                    inputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .autocapitalization(.none)

                    inputView(text: $fullname, title: "Full Name", placeholder: "Enter Your Name")

                    inputView(text: $password, title: "Password", placeholder: "Enter Your Password", isSecureField: true)

                    ZStack(alignment: .trailing) {
                        inputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Enter Password Again", isSecureField: true)

                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color(.systemRed))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }

            // Sign-up button
            Button {
                Task {
                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
                }
            } label: {
                HStack {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(isFormValid ? Color.blue : Color.gray.opacity(0.5))
            .cornerRadius(10)
            .padding(.top, 24)

            Spacer()

            // Already have an account button
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
        .padding()
    }
}

extension registrationView: AuthenticationFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty && !email.contains("@") && !password.isEmpty && password.count > 5 && !fullname.isEmpty && confirmPassword == password
    }
}

#Preview {
    registrationView()
}
