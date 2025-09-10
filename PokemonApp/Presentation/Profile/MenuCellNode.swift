//
//  MenuCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import AsyncDisplayKit

final class MenuCellNode: BaseCellNode {
    private let iconNode = ASImageNode()
    private let titleNode = ASTextNode()

    init(title: String?, icon: UIImage?, tint: UIColor?) {
        super.init()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = .systemBackground
        iconNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(tint ?? .label)
        iconNode.image = icon
        iconNode.style.preferredSize = CGSize(width: 22, height: 22)
        titleNode.attributedText = NSAttributedString(
            string: title.orEmpty,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .start,
            alignItems: .center,
            children: [iconNode, titleNode]
        )

        return ASInsetLayoutSpec(insets: .init(top: 10, left: 16, bottom: 10, right: 16), child: stack)
    }
}
