//
//  DetailPokemonTriviaCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 10/09/25.
//

import AsyncDisplayKit

final class DetailPokemonTriviaCellNode: BaseCellNode {
    private let textNode = ASTextNode()
    
    init(_ text: String?) {
        super.init()
        textNode.attributedText = NSAttributedString(
            string: text.orEmpty,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.label
            ]
        )
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .init(top: 12, left: 12, bottom: 12, right: 12), child: textNode)
    }
}
