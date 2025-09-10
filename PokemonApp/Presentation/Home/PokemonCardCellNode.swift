//
//  PokemonCardCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import AsyncDisplayKit
import UIKit

final class PokemonCardCellNode: BaseCellNode {
    private let bgNode = ASDisplayNode().configure {
        $0.backgroundColor = .systemFill
        $0.cornerRadius = 12
        $0.clipsToBounds = true
        $0.style.height = ASDimensionMake(150)
    }
    
    private let pokeballImage = ASImageNode().configure {
        $0.image = UIImage(named: "BackgroundPokeball")
        $0.contentMode = .scaleAspectFill
        $0.style.width = ASDimensionMake(150)
    }
    
    private let pokemonImage = ASNetworkImageNode().configure {
        $0.contentMode = .scaleAspectFill
        $0.style.width = ASDimensionMake(150)
        $0.defaultImage = UIImage(named: "Pokeball")
    }
    
    private let nameNode = ASTextNode()
    private let indexNode = ASTextNode()
    
    private let favoriteBtn = ASButtonNode().configure {
        $0.style.preferredSize = CGSizeMake(26, 24)
    }
    
    private let collectionNode = ASCollectionNode(
        collectionViewLayout: UICollectionViewFlowLayout()
    ).configure {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = 8
        layout?.minimumInteritemSpacing = .zero
        layout?.sectionInset = .init(top: 0, left: 12, bottom: 0, right: 12)
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.style.height = ASDimensionMake(30)
    }
    
    private var isFavorite = false
    private var types: [TypeElement] = []
    
    var toggleFavorite: ((Bool) -> Void)?
    
    private let data: PokemonDetailModel
    
    init(data: PokemonDetailModel, isFavorite: Bool) {
        self.data = data
        self.isFavorite = isFavorite
        self.types = data.types
        super.init()
        let elementColor = ElementColor.color(for: types.first?.type.name ?? "")
        let textColor = elementColor.contrastingTextColor
        bgNode.backgroundColor = elementColor.withAlphaComponent(0.7)
        backgroundColor = .systemGroupedBackground
        nameNode.attributedText = NSAttributedString(
            string: data.name.capitalized,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: textColor
            ]
        )
        indexNode.attributedText = NSAttributedString(
            string: "#\(data.id)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: textColor
            ]
        )
        
        let image = isFavorite ? SFSymbols.favoriteFilled : SFSymbols.favorite
        let processedImage = image?.resized(to: CGSizeMake(26, 22), tint: .systemRed)
        favoriteBtn.setImage(processedImage, for: .normal)
        
        favoriteBtn.addTarget(
            self,
            action: #selector(tapFavorite),
            forControlEvents: .touchUpInside
        )
        
        collectionNode.dataSource = self
        collectionNode.delegate = self
        
        guard let urlStr = data.sprites.frontDefault, let url = URL(string: urlStr) else { return }
        pokemonImage.setURL(url, resetToDefault: true)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .start,
            children: [indexNode, nameNode]
        )
        
        let textAndFavBtnStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .stretch,
            children: [textStack, favoriteBtn]
        )
        
        let textAndFavBtnStackInset = ASInsetLayoutSpec(
            insets: .init(top: 12, left: 12, bottom: .infinity, right: 12),
            child: textAndFavBtnStack
        )
        
        let overlayPokemon = ASOverlayLayoutSpec(child: pokeballImage, overlay: pokemonImage)
        
        let insetOverlayPokemon = ASInsetLayoutSpec(
            insets: .init(top: 0, left: .infinity, bottom: 0, right: 12),
            child: overlayPokemon
        )
        
        let insetCollection = ASInsetLayoutSpec(
            insets: .init(top: .infinity, left: 0, bottom: 12, right: pokemonImage.style.width.value + 12),
            child: collectionNode
        )
        
        let wrapper = ASWrapperLayoutSpec(layoutElements: [insetOverlayPokemon, textAndFavBtnStackInset, insetCollection])
        let bgInset = ASInsetLayoutSpec(
            insets: .init(top: 8, left: 16, bottom: 8, right: 16),
            child: ASOverlayLayoutSpec(child: bgNode, overlay: wrapper)
        )
        return bgInset
    }
    
    @objc private func tapFavorite() {
        toggleFavorite?(!isFavorite)
    }
}

extension PokemonCardCellNode: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        types.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let elementType = types[safe: indexPath.item]?.type.name
        return PokemonTypeCellNode(
            title: elementType?.capitalized,
            background: ElementColor.color(for: elementType.orEmpty),
            textColor: ElementColor.color(for: elementType.orEmpty).contrastingTextColor
        )
    }
}

extension PokemonCardCellNode: ASCollectionDelegateFlowLayout {
    func collectionNode(
        _ collectionNode: ASCollectionNode,
        constrainedSizeForItemAt indexPath: IndexPath
    ) -> ASSizeRange {
        let totalWidth = collectionNode.bounds.width
        let width = (totalWidth - 24 - 8) / 2
        return ASSizeRangeMake(CGSizeMake(width, 24))
    }
}
