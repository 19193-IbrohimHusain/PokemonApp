//
//  DetailPokemonTriviaTableViewCell.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import UIKit
import SnapKit

final class DetailPokemonTriviaTableViewCell: BaseTableViewCell {
    internal let triviaLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.numberOfLines = 0
    }
    
    override func configView() {
        super.configView()
        contentView.addSubview(triviaLabel)
        triviaLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
    }
}
