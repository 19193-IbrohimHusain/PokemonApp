//
//  PokemonCardTableViewCell.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import UIKit
import SnapKit
import Kingfisher

final class PokemonCardTableViewCell: BaseTableViewCell {
    private let bgView = UIView().configure {
        $0.backgroundColor = .systemFill
        $0.setCornerRadius(radius: 12)
    }
    
    private let pokeballImage = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "BackgroundPokeball")
    }
    
    private let pokemonImage = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
    }
    
    private let pokemonName = UILabel().configure {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    private let pokemonIndex = UILabel().configure {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let favoriteIcon = UIButton(type: .system).configure {
        $0.setImage(SFSymbols.favorite, for: .normal)
        $0.tintColor = .systemRed
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).configure {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = 8
        layout?.sectionInset = .init(top: 0, left: 12, bottom: 0, right: 12)
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    
    private var isFavorite = false
    private var pokemonType = [TypeElement]()
    
    internal var toggleFavorite: ((Bool) -> Void)?
    
    override func configView() {
        super.configView()
        setupView()
        setConstraint()
        bindEvent()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pokemonImage.kf.cancelDownloadTask()
        pokemonImage.image = nil
    }
    
    private func setupView() {
        backgroundColor = .systemGroupedBackground
        contentView.addSubview(bgView)
        bgView.addSubviews(pokemonIndex, pokemonName, collectionView, pokeballImage, pokemonImage, favoriteIcon)
        pokemonImage.kf.indicatorType = .activity
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerCell(PokemonTypeCollectionViewCell.self)
    }
    
    private func setConstraint() {
        bgView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.height.equalTo(150)
        }
        pokemonIndex.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        pokemonName.snp.makeConstraints {
            $0.top.equalTo(pokemonIndex.snp.bottom).inset(-4)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualTo(collectionView.snp.top)
        }
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(30)
            $0.trailing.equalTo(pokemonImage.snp.leading).inset(-12)
            $0.bottom.equalToSuperview().inset(12)
        }
        pokeballImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(150)
        }
        pokemonImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(150)
        }
        favoriteIcon.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(24)
            $0.width.equalTo(26)
        }
    }
    
    private func bindEvent() {
        favoriteIcon.addTarget(self, action: #selector(addFavorites), for: .touchUpInside)
    }
    
    @objc
    private func addFavorites() {
        toggleFavorite?(!isFavorite)
    }
    
    private func changeBgAndTextColor() {
        let elementColor = ElementColor.color(for: pokemonType.first?.type.name ?? "")
        bgView.backgroundColor = elementColor.withAlphaComponent(0.7)
        pokemonIndex.textColor = elementColor.contrastingTextColor
        pokemonName.textColor = elementColor.contrastingTextColor
    }
    
    internal func setContent(with data: PokemonDetailModel, isFavorite: Bool) {
        pokemonIndex.text = "#\(data.id)"
        pokemonName.text = data.name.capitalized
        pokemonType = data.types
        changeBgAndTextColor()
        collectionView.reloadData()
        self.isFavorite = isFavorite
        let asset = isFavorite ? SFSymbols.favoriteFilled : SFSymbols.favorite
        favoriteIcon.setImage(asset, for: .normal)
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

extension PokemonCardTableViewCell: UICollectionViewDataSource {
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

extension PokemonCardTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSizeMake((collectionView.width - 24 - 8) / 2, 24)
    }
}
