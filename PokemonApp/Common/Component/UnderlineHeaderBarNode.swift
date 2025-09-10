//
//  UnderlineHeaderBarNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import AsyncDisplayKit
import UIKit

protocol UnderlineHeaderBarNodeDelegate: AnyObject {
    func tabBar(_ tabBar: UnderlineHeaderBarNode, didSelectItemAt index: Int)
}

final class UnderlineHeaderBarNode: BaseDisplayNode {
    private let collectionNode = ASCollectionNode(
        collectionViewLayout: UICollectionViewFlowLayout()
    ).configure {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = .zero
        layout?.minimumInteritemSpacing = .zero
        layout?.sectionInset = .zero
        $0.backgroundColor = .systemBackground
        $0.showsHorizontalScrollIndicator = false
        $0.style.height = ASDimensionMake(44)
    }
    
    private let indicatorNode = ASDisplayNode().configure {
        $0.backgroundColor = .systemBlue
        $0.style.height = ASDimensionMake(1)
    }
    
    private(set) var titles: [String] = []
    internal weak var delegate: UnderlineHeaderBarNodeDelegate?
    private var indicatorPosition: CGFloat = 0
        
    init(titles: [String]) {
        self.titles = titles
        super.init()
        backgroundColor = .systemBackground
        collectionNode.dataSource = self
        collectionNode.delegate = self
        selectTab(at: 0)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width / CGFloat(max(titles.count, 1))
        indicatorNode.style.width = ASDimensionMake(width)
        indicatorNode.style.layoutPosition = .init(x: indicatorPosition, y: 0)
        let nodeLayout = ASAbsoluteLayoutSpec(children: [indicatorNode])
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: .zero,
            justifyContent: .start,
            alignItems: .start,
            children: [collectionNode, nodeLayout]
        )
    }
    
    internal func selectTab(at index: Int) {
        guard index >= 0 && index < titles.count else { return }
        DispatchQueue.main.async {
            self.collectionNode.selectItem(
                at: IndexPath(item: index, section: 0),
                animated: false,
                scrollPosition: .centeredHorizontally
            )
        }
    }
    
    internal func setIndicatorPosition(with offset: CGFloat) {
        guard titles.count > 0 else { return }
        indicatorPosition = offset / CGFloat(titles.count)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    internal func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
        collectionNode.relayoutItems()
    }
}

extension UnderlineHeaderBarNode: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let title = titles[indexPath.item]
        let cell = UnderlineTabCellNode()
        cell.configure(title: title)
        return cell
    }
}

extension UnderlineHeaderBarNode: ASCollectionDelegateFlowLayout {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        delegate?.tabBar(self, didSelectItemAt: indexPath.item)
        selectTab(at: indexPath.item)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionNode.bounds.width / CGFloat(titles.count)
        return ASSizeRangeMake(CGSizeMake(width, collectionNode.bounds.width))
    }
}

private final class UnderlineTabCellNode: BaseCellNode {
    private let titleNode = ASTextNode()
    
    override func configNode() {
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
    }
    
    override var isSelected: Bool {
        didSet {
            let color: UIColor = isSelected ? .systemBlue : .label
            titleNode.attributedText = NSAttributedString(
                string: titleNode.attributedText?.string ?? "",
                attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: color]
            )
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: titleNode)
    }

    func configure(title: String) {
        titleNode.attributedText = NSAttributedString(
            string: title,
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.label]
        )
        accessibilityLabel = title
    }
}
