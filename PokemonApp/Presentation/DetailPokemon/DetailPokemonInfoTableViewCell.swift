//
//  DetailPokemonInfoTableViewCell.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import UIKit
import SnapKit
import Kingfisher

final class DetailPokemonInfoTableViewCell: BaseTableViewCell {
    private let stackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 16
    }
    
    private let titleLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    private let descLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
    }
    
    private let containerChip = UIView()
    
    private let chipView = UIView().configure {
        $0.setCornerRadius(radius: 12)
        $0.layer.masksToBounds = false
        $0.shadowColor = UIColor.black
        $0.shadowOffset = CGSizeMake(0, 2)
        $0.shadowRadius = 2
        $0.shadowOpacity = 0.3
    }
    
    private let chipLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
    }
    
    override func configView() {
        super.configView()
        setupView()
        setConstraint()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        contentView.addSubview(stackView)
        stackView.addArrangedSubviews(titleLabel, descLabel, containerChip)
        containerChip.addSubview(chipView)
        chipView.addSubview(chipLabel)
    }
    
    private func setConstraint() {
        stackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(68)
        }
        chipView.snp.makeConstraints {
            $0.verticalEdges.leading.equalToSuperview()
        }
        chipLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(4)
            $0.horizontalEdges.equalToSuperview().inset(8)
        }
    }
    
    internal func setContent(title: String, desc: String, chipFormat: Bool = false) {
        titleLabel.text = title
        descLabel.text = desc
        descLabel.isHidden = chipFormat
        containerChip.isHidden = !chipFormat
        guard chipFormat else { return }
        chipLabel.text = desc
        let elementColor = ElementColor.color(for: desc)
        chipView.backgroundColor = elementColor
        chipLabel.textColor = elementColor.contrastingTextColor
    }
}
