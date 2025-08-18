//
//  Dictionary + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 18/08/25.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func decode<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
