//
//  PasswordHasher.swift
//  PATHFINDER
//
//  Created by Breck Neal on 3/22/26.
//


import Foundation
import CryptoKit

enum PasswordHasher {
    static func hash(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}