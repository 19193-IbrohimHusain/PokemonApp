//
//  Constants.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit

struct BaseConstant {
    static let baseURL = "https://pokeapi.co/api/v2/"
}

struct ElementColor {
    private static let colors: [String: UIColor] = [
        "normal":   UIColor.systemGray,
        "fire":     UIColor.systemRed,
        "water":    UIColor.systemBlue,
        "electric": UIColor.systemYellow,
        "grass":    UIColor.systemGreen,
        "ice":      UIColor.cyan,
        "fighting": UIColor.brown,
        "poison":   UIColor.purple,
        "ground":   UIColor(red: 0.87, green: 0.75, blue: 0.53, alpha: 1.0),
        "flying":   UIColor.systemTeal,
        "psychic":  UIColor.systemPink,
        "bug":      UIColor(red: 0.54, green: 0.74, blue: 0.17, alpha: 1.0),
        "rock":     UIColor(red: 0.70, green: 0.62, blue: 0.42, alpha: 1.0),
        "ghost":    UIColor(red: 0.44, green: 0.34, blue: 0.60, alpha: 1.0),
        "dragon":   UIColor(red: 0.44, green: 0.22, blue: 0.89, alpha: 1.0),
        "dark":     UIColor(red: 0.33, green: 0.25, blue: 0.22, alpha: 1.0),
        "steel":    UIColor(red: 0.72, green: 0.72, blue: 0.82, alpha: 1.0),
        "fairy":    UIColor(red: 0.93, green: 0.63, blue: 0.82, alpha: 1.0)
    ]

    static func color(for type: String) -> UIColor {
        colors[type.lowercased()] ?? .systemFill
    }
}


enum SFSymbols {
    static let home = UIImage(systemName: "house")
    static let homeFilled = UIImage(systemName: "house.fill")
    static let profile = UIImage(systemName: "person.crop.circle")
    static let profileFilled = UIImage(systemName: "person.crop.circle.fill")
    static let editProfile = UIImage(systemName: "pencil.line")
    static let favorite = UIImage(systemName: "heart")
    static let favoriteFilled = UIImage(systemName: "heart.fill")
    static let logout = UIImage(systemName: "rectangle.portrait.and.arrow.forward")
    static let successIcon = UIImage(systemName: "checkmark.circle.fill")
    static let failedIcon = UIImage(systemName: "xmark.circle.fill")
}

enum Screen {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(Screen.width, Screen.height)
    static let minLength    = min(Screen.width, Screen.height)
}
