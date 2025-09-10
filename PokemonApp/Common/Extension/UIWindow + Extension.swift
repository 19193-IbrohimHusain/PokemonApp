//
//  UIWindow + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import UIKit

extension UIWindow {
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
