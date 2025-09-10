//
//  DetailPokemonImageCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 10/09/25.
//

import AsyncDisplayKit

final class DetailPokemonImageCellNode: BaseCellNode {
    private let pokemonName = ASTextNode()
    
    private let pokemonIndex = ASTextNode()
    
    private let pokemonGenera = ASTextNode()
    
    private let pokemonImage = ASNetworkImageNode().configure {
        $0.contentMode = .scaleAspectFill
        $0.defaultImage = UIImage(named: "Pokeball")
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
        $0.style.flexGrow = 1
    }
    
    private let roundNode = ASDisplayNode().configure {
        $0.backgroundColor = .systemBackground
        $0.style.height = ASDimensionMake(28)
    }
    
    private var pokemonType = [TypeElement]()
    
    init(data: PokemonDetailModel, genera: String?) {
        pokemonType = data.types
        super.init()
        let elementColor = ElementColor.color(for: data.types.first?.type.name ?? "")
        let textColor = elementColor.contrastingTextColor
        backgroundColor = elementColor
        pokemonName.attributedText = NSAttributedString(
            string: data.name.capitalized,
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: textColor
            ]
        )
        pokemonIndex.attributedText = NSAttributedString(
            string: "#\(data.id)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: textColor
            ]
        )
        pokemonGenera.attributedText = NSAttributedString(
            string: genera.orEmpty,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: textColor
            ]
        )
        
        collectionNode.dataSource = self
        collectionNode.delegate = self
        
        guard let urlStr = data.sprites.frontDefault, let url = URL(string: urlStr) else { return }
        pokemonImage.setURL(url, resetToDefault: true)
    }
    
    override func didLoad() {
        super.didLoad()
        roundNode.view.setTopCornerRadius(radius: 16)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let row1 = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [pokemonName, pokemonIndex]
        )
        
        let row1Inset = ASInsetLayoutSpec(
            insets: .init(top: 20, left: 16, bottom: 0, right: 16),
            child: row1
        )
                
        let row2 = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [collectionNode, pokemonGenera]
        )
        
        let row2Inset = ASInsetLayoutSpec(
            insets: .init(top: 12, left: 0, bottom: 0, right: 16),
            child: row2
        )
        
        let imageInset = ASInsetLayoutSpec(
            insets: .init(top: 12, left: 100, bottom: 0, right: 100),
            child: ASRatioLayoutSpec(ratio: 1.0, child: pokemonImage)
        )
        
        let insetRoundNode = ASInsetLayoutSpec(
            insets: .init(top: .infinity, left: 0, bottom: 0, right: 0),
            child: roundNode
        )
        
        let imageAndRoundNode = ASBackgroundLayoutSpec(child: imageInset, background: insetRoundNode)
        
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [row1Inset, row2Inset, imageAndRoundNode]
        )
    }
}

extension DetailPokemonImageCellNode: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        pokemonType.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let elementType = pokemonType[safe: indexPath.item]?.type.name
        return PokemonTypeCellNode(
            title: elementType?.capitalized,
            background: ElementColor.color(for: elementType.orEmpty),
            textColor: ElementColor.color(for: elementType.orEmpty).contrastingTextColor
        )
    }
}

extension DetailPokemonImageCellNode: ASCollectionDelegateFlowLayout {
    func collectionNode(
        _ collectionNode: ASCollectionNode,
        constrainedSizeForItemAt indexPath: IndexPath
    ) -> ASSizeRange {
        return ASSizeRangeMake(CGSizeMake(68, 24))
    }
}
