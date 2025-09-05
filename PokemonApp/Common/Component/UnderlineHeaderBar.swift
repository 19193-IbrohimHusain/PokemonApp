//
//  UnderlineHeaderBar.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 05/09/25.
//

import UIKit
import SnapKit

protocol UnderlineHeaderBarDelegate: AnyObject {
    func tabBar(_ tabBar: UnderlineHeaderBar, didSelectItemAt index: Int)
}

final class UnderlineHeaderBar: BaseView {
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).configure {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = .zero
        layout?.minimumInteritemSpacing = .zero
        layout?.sectionInset = .zero
        $0.backgroundColor = .systemBackground
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let indicator = UIView().configure {
        $0.backgroundColor = .systemBlue
    }
    
    private(set) var titles: [String] = []
    
    internal weak var delegate: UnderlineHeaderBarDelegate?
    
    override func configView() {
        addSubviews(collectionView, indicator)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(UnderlineTabCell.self)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    internal func setIndicatorPosition(with offset: CGFloat) {
        guard !titles.isEmpty else { return }
        let tabCount = CGFloat(titles.count)
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.indicator.snp.updateConstraints { $0.leading.equalToSuperview().offset(offset / tabCount) }
        }
    }
        
    internal func selectTab(at index: Int) {
        guard index >= 0, index < titles.count else { return }
        collectionView.selectItem(
            at: IndexPath(item: index, section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }
    
    internal func setTitles(_ data: [String]) {
        titles = data
        collectionView.reloadData()
        guard !data.isEmpty else { return }
        selectTab(at: 0)
        indicator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.leading.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(data.count)
        }
    }
    
    internal func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadData()
    }
}

extension UnderlineHeaderBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UnderlineTabCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        if let title = titles[safe: indexPath.item] {
            cell.configure(title: title)
        }
        return cell
    }
}

extension UnderlineHeaderBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        delegate?.tabBar(self, didSelectItemAt: indexPath.item)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.width / CGFloat(titles.count)
        return CGSizeMake(width, collectionView.height)
    }
}

private final class UnderlineTabCell: BaseCollectionViewCell {
    private let titleLabel = UILabel().configure {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .label
        $0.textAlignment = .center
    }
    
    override var isSelected: Bool {
        didSet { updateUI() }
    }
    
    override func configView() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
    }
    
    func configure(title: String) {
        titleLabel.text = title
        accessibilityLabel = title
    }
    
    private func updateUI() {
        titleLabel.textColor = isSelected ? .systemBlue : .label
    }
}
