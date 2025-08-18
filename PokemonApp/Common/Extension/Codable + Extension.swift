//
//  Codable + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import Foundation

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let obj  = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = obj as? [String: Any] else { return [:] }
        return dict
    }
}

extension Decodable {
    static func toSelf(_ dict: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
