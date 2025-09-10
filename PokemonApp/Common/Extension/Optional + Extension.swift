//
//  Optional + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 05/09/25.
//

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
    
    func or(_ string: String) -> String {
        guard let word = self, !word.isEmpty else { return string }
        
        return word
    }
    
    func display(placeholder: String) -> String {
        guard let string = self, !string.isEmpty else { return placeholder }
        return string
    }
}

extension Optional where Wrapped == Int {
    var orZero: Int {
        return self ?? 0
    }
    
    func or(_ number: Int) -> Int {
        guard let unwrappedNumber = self else { return number }
        return unwrappedNumber
    }
}
