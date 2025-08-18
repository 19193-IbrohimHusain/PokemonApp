//
//  DetailPokemonImageTableViewCell.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import UIKit
import SnapKit
import Kingfisher

final class DetailPokemonImageTableViewCell: BaseTableViewCell {
    private let pokemonName = UILabel().configure {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private let pokemonIndex = UILabel().configure {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private let pokemonGenera = UILabel().configure {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let pokemonImage = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).configure {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = 8
        layout?.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let roundView = UIView().configure {
        $0.setTopCornerRadius(radius: 16)
        $0.backgroundColor = .systemBackground
    }
    
    private var pokemonType = [TypeElement]()
    
    override func configView() {
        super.configView()
        setupView()
        setConstraint()
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.addSubviews(pokemonName, collectionView, pokemonIndex, pokemonGenera, roundView, pokemonImage)
        pokemonImage.kf.indicatorType = .activity
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerCell(PokemonTypeCollectionViewCell.self)
    }
    
    private func setConstraint() {
        pokemonName.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(pokemonIndex.snp.leading).inset(-12)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(pokemonName.snp.bottom).inset(-12)
            $0.leading.equalToSuperview()
            $0.height.equalTo(30)
            $0.trailing.equalTo(pokemonGenera.snp.leading).inset(-12)
        }
        pokemonIndex.snp.makeConstraints {
            $0.centerY.equalTo(pokemonName)
            $0.trailing.equalToSuperview().inset(16)
        }
        pokemonGenera.snp.makeConstraints {
            $0.centerY.equalTo(collectionView)
            $0.trailing.equalToSuperview().inset(16)
        }
        pokemonImage.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).inset(-12)
            $0.horizontalEdges.equalToSuperview().inset(100)
            $0.height.equalTo(Screen.width - 100 - 100)
        }
        roundView.snp.makeConstraints {
            $0.top.equalTo(pokemonImage.snp.bottom).inset(50)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(28)
        }
    }
    
    private func changeBgAndTextColor() {
        let elementColor = ElementColor.color(for: pokemonType.first?.type.name ?? "")
        pokemonIndex.textColor = elementColor.contrastingTextColor
        pokemonName.textColor = elementColor.contrastingTextColor
        pokemonGenera.textColor = elementColor.contrastingTextColor
        backgroundColor = elementColor.withAlphaComponent(0.7)
    }
    
    internal func setContent(with data: PokemonDetailModel, genera: String?) {
        pokemonIndex.text = "#\(data.id)"
        pokemonName.text = data.name.capitalized
        pokemonGenera.text = genera
        pokemonType = data.types
        changeBgAndTextColor()
        collectionView.reloadData()
        guard let imgLink = data.sprites.frontDefault, let url = URL(string: imgLink) else {
            pokemonImage.image = UIImage(named: "Pokeball")
            return
        }
        let options: KingfisherOptionsInfo = [
            .cacheOriginalImage,
            .memoryCacheExpiration(.seconds(600)),
            .transition(.fade(0.3))
        ]
        pokemonImage.kf.setImage(with: url, options: options)
    }
}

extension DetailPokemonImageTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PokemonTypeCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let elementType = pokemonType[safe: indexPath.item]?.type.name
        cell.titleLabel.text = elementType?.capitalized
        cell.backgroundColor = ElementColor.color(for: elementType ?? "")
        cell.titleLabel.textColor = cell.backgroundColor?.contrastingTextColor
        return cell
    }
}

extension DetailPokemonImageTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSizeMake(68, 24)
    }
}
