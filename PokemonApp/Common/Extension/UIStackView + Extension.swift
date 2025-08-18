//
//  UIStackView + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import UIKit

extension UIStackView {
    func removeArrangedSubview<T: UIView>(_ view: T) {
        arrangedSubviews.forEach { view in
            guard view is T else { return }
            view.removeFromSuperview()
        }
    }
    
    func removeArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
}

