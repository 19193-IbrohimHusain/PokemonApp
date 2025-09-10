//
//  UIImage + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import UIKit

extension UIImage {
    func resized(
        to targetSize: CGSize,
        tint: UIColor? = nil,
        isOpaque: Bool = false,
        scale: CGFloat = 0
    ) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        format.scale = scale == 0 ? UIScreen.main.scale : scale
        
        let rect = CGRect(origin: .zero, size: targetSize)
        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            if let tint {
                tint.set()
                withRenderingMode(.alwaysTemplate).draw(in: rect)
            } else {
                draw(in: rect)
            }
        }
    }
}
