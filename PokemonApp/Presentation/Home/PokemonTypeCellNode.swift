//
//  PokemonTypeCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import AsyncDisplayKit

final class PokemonTypeCellNode: BaseCellNode {
    private let titleNode = ASTextNode()
    
    init(title: String?, background: UIColor, textColor: UIColor) {
        super.init()
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        titleNode.attributedText = NSAttributedString(
            string: title.orEmpty,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: textColor,
                .paragraphStyle: style
            ]
        )
        backgroundColor = background
        cornerRadius = 12
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSizeMake(0, 2)
        shadowRadius = 2
        shadowOpacity = 0.3
    }
    
    override func didLoad() {
        super.didLoad()
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: frame, cornerRadius: 12).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: .init(top: 4, left: 8, bottom: 4, right: 8), child: titleNode)
    }
}
