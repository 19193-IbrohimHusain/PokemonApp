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
        layer.masksToBounds = false
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 2)
        shadowRadius = 2
        shadowOpacity = 0.3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: .init(top: 4, left: 8, bottom: 4, right: 8), child: titleNode)
    }
}
