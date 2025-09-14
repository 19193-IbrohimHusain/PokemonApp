//
//  PokemonTypeCollectionViewCell.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import UIKit
import SnapKit

final class PokemonTypeCollectionViewCell: BaseCollectionViewCell {
    internal let titleLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textAlignment = .center
    }
    
    override func configView() {
        contentView.addSubview(titleLabel)
        setCornerRadius(radius: 12)
        layer.masksToBounds = false
        shadowColor = UIColor.black
        shadowOffset = CGSizeMake(0, 2)
        shadowRadius = 2
        shadowOpacity = 0.3
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(4)
            $0.horizontalEdges.equalToSuperview().inset(8)
        }
    }
}
