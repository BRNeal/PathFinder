//
//  PFUser.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import Foundation
import SwiftData

@Model
final class PFUser {
    @Attribute(.unique) var email: String
    var username: String
    var passwordHash: String
    var createdAt: Date

    init(email: String, username: String, passwordHash: String, createdAt: Date = .now) {
        self.email = email
        self.username = username
        self.passwordHash = passwordHash
        self.createdAt = createdAt
    }
}