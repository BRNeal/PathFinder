//
//  LoginView.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("PathFinder")
                    .font(.largeTitle).bold()
                Text("Find trails. Save adventures.")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                if let msg = auth.errorMessage {
                    Text(msg).foregroundStyle(.red).font(.footnote)
                }

                Button {
                    auth.login(context: context, email: email, password: password)
                } label: {
                    Text("Log In").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Create an account") {
                    SignUpView()
                }
                .padding(.top, 4)

                Spacer()
            }
            .padding()
        }
    }
}