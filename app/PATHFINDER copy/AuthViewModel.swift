//
//  AuthViewModel.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: PFUser?
    @Published var errorMessage: String?

    @AppStorage("pf_currentEmail") private var currentEmail: String = ""

    func bootstrap(context: ModelContext) {
        guard !currentEmail.isEmpty else { return }
        do {
            let emailLower = currentEmail.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptor = FetchDescriptor<PFUser>(
                predicate: #Predicate { $0.email == emailLower }
            )
            self.currentUser = try context.fetch(descriptor).first
        } catch {
            self.errorMessage = "Failed to restore session."
        }
    }

    func signUp(context: ModelContext, username: String, email: String, password: String, confirm: String) {
        errorMessage = nil

        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard !u.isEmpty, !e.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        guard password == confirm else {
            errorMessage = "Passwords do not match."
            return
        }

        do {
            let check = FetchDescriptor<PFUser>(predicate: #Predicate { $0.email == e })
            if try context.fetch(check).first != nil {
                errorMessage = "An account with that email already exists."
                return
            }

            let user = PFUser(email: e, username: u, passwordHash: PasswordHasher.hash(password))
            context.insert(user)
            try context.save()

            currentEmail = e
            currentUser = user
        } catch {
            errorMessage = "Sign up failed. Try again."
        }
    }

    func login(context: ModelContext, email: String, password: String) {
        errorMessage = nil

        let e = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }

        do {
            let descriptor = FetchDescriptor<PFUser>(predicate: #Predicate { $0.email == e })
            guard let user = try context.fetch(descriptor).first else {
                errorMessage = "No account found for that email."
                return
            }

            if user.passwordHash == PasswordHasher.hash(password) {
                currentEmail = e
                currentUser = user
            } else {
                errorMessage = "Invalid email or password."
            }
        } catch {
            errorMessage = "Login failed. Try again."
        }
    }

    func logout() {
        currentEmail = ""
        currentUser = nil
        errorMessage = nil
    }
}
