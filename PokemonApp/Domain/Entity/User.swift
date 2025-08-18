//
//  LoginModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Foundation

struct User: Codable {
    let email, name, password: String
    
    init(email: String = "", name: String = "", password: String = "") {
        self.email = email
        self.name = name
        self.password = password
    }

    enum CodingKeys: String, CodingKey {
        case email, name, password
    }
}

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email && lhs.password == rhs.password
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(email)
        hasher.combine(password)
    }
}
