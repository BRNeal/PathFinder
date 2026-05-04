//
//  SignUpView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var auth: AuthViewModel

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.title2).bold()

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm Password", text: $confirm)
                .textFieldStyle(.roundedBorder)

            if let msg = auth.errorMessage {
                Text(msg).foregroundStyle(.red).font(.footnote)
            }

            Button {
                auth.signUp(context: context,
                            username: username,
                            email: email,
                            password: password,
                            confirm: confirm)
            } label: {
                Text("Create Account").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}