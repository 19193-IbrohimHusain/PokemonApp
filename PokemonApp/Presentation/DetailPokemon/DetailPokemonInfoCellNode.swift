//
//  DetailPokemonInfoCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 10/09/25.
//

import AsyncDisplayKit

final class DetailPokemonInfoCellNode: BaseCellNode {
    private let titleNode = ASTextNode()
    
    private let descNode = ASTextNode()
    
    private let containerChip = ASDisplayNode()
    
    private let chipNode = ASDisplayNode().configure {
        $0.cornerRadius = 12
    }
    
    private let chipText = ASTextNode()
    
    private var chipFormat = false
    
    init(title: String, desc: String, chipFormat: Bool = false) {
        self.chipFormat = chipFormat
        super.init()
        backgroundColor = .systemBackground
        titleNode.style.width = ASDimensionMake(68)
        titleNode.attributedText = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.label
            ]
        )
        descNode.attributedText = NSAttributedString(
            string: desc,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
        guard chipFormat else { return }
        let elementColor = ElementColor.color(for: desc)
        chipText.attributedText = NSAttributedString(
            string: desc,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: elementColor.contrastingTextColor
            ]
        )
        chipNode.backgroundColor = elementColor
        chipNode.shadowColor = UIColor.black.cgColor
        chipNode.shadowOffset = CGSizeMake(0, 2)
        chipNode.shadowRadius = 2
        chipNode.shadowOpacity = 0.3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var childNode: [ASLayoutElement] = [titleNode]
        if chipFormat {
            let textInset = ASInsetLayoutSpec(insets: .init(top: 4, left: 8, bottom: 4, right: 8), child: chipText)
            let chip = ASBackgroundLayoutSpec(child: textInset, background: chipNode)
            childNode.append(chip)
            let spacer = ASLayoutSpec()
            spacer.style.flexGrow = 1
            childNode.append(spacer)
        } else {
            childNode.append(descNode)
        }
        let stack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 16,
            justifyContent: .start,
            alignItems: .center,
            children: childNode
        )
        return ASInsetLayoutSpec(insets: .init(top: 6, left: 16, bottom: 6, right: 16), child: stack)
    }
}
