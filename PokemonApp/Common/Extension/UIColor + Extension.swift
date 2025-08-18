//
//  UIColor + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import UIKit

extension UIColor {
    private var luminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        func adjust(_ c: CGFloat) -> CGFloat {
            return (c < 0.03928) ? (c / 12.92) : pow((c + 0.055) / 1.055, 2.4)
        }

        let R = adjust(r)
        let G = adjust(g)
        let B = adjust(b)
        return 0.2126 * R + 0.7152 * G + 0.0722 * B
    }

    var contrastingTextColor: UIColor {
        return luminance < 0.5 ? .white : .black
    }
}
