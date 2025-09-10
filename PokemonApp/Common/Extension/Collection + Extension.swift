//
//  Collection + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        guard index >= startIndex, index < endIndex else { return nil }
        return self[index]
    }
}

extension Collection where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}
