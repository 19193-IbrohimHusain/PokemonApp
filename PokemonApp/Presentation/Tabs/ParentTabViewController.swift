//
//  ParentTabViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import AsyncDisplayKit

final class ParentTabViewController: BaseASDKViewController {
    private let headerBarView = UnderlineHeaderBarNode(titles: ["Home", "Profile"])
    
    private let collectionNode = ASCollectionNode(
        collectionViewLayout: UICollectionViewFlowLayout()
    ).configure {
        let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.minimumLineSpacing = .zero
        layout?.minimumInteritemSpacing = .zero
        layout?.sectionInset = .zero
        $0.backgroundColor = .systemBackground
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.style.flexGrow = 1
    }
    
    private let pages: [ASDKViewController<ASDisplayNode>] = [
        HomeViewController(),
        ProfileViewController()
    ]
    
    override func configNode() {
        setupNavigationBar()
        setupNode()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionNode.relayoutItems()
            self.headerBarView.updateLayout()
        })
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Pokemon App"
        navigationItem.backButtonTitle = "Back"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(navigateToSearch)
        )
    }
    
    private func setupNode() {
        node.backgroundColor = .systemBackground
        headerBarView.delegate = self
        collectionNode.delegate = self
        collectionNode.dataSource = self
        node.layoutSpecBlock = { [weak self] node, size in
            guard let self = self else { return ASLayoutSpec() }
            return self.setLayout()
        }
    }
    
    private func setLayout() -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [headerBarView, collectionNode]
        )
        
        return ASInsetLayoutSpec(insets: .init(top: node.safeAreaInsets.top, left: 0, bottom: 0, right: 0), child: stack)
    }
    
    @objc
    private func navigateToSearch() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ParentTabViewController: UnderlineHeaderBarNodeDelegate {
    func tabBar(_ tabBar: UnderlineHeaderBarNode, didSelectItemAt index: Int) {
        guard index >= 0, index < pages.count else { return }
        collectionNode.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension ParentTabViewController: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let page = pages[indexPath.item]
        return { TabContainerCellNode(host: page, parent: self) }
    }
}

extension ParentTabViewController: ASCollectionDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerBarView.setIndicatorPosition(with: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.width)
        headerBarView.selectTab(at: index)
    }
    
    func collectionNode(
        _ collectionNode: ASCollectionNode,
        constrainedSizeForItemAt indexPath: IndexPath
    ) -> ASSizeRange {
        return ASSizeRangeMake(collectionNode.bounds.size)
    }
}

final class TabContainerCellNode: BaseCellNode {
    private weak var parent: ASDKViewController<ASDisplayNode>?
    private weak var hostedVC: ASDKViewController<ASDisplayNode>?
    
    init(host: ASDKViewController<ASDisplayNode>, parent: ASDKViewController<ASDisplayNode>) {
        self.hostedVC = host
        self.parent = parent
        super.init()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        guard let hostedVC = hostedVC else { return ASLayoutSpec() }
        return ASInsetLayoutSpec(insets: .zero, child: hostedVC.node)
    }
    
    override func didLoad() {
        super.didLoad()
        guard let parent, let hostedVC, hostedVC.parent != parent else { return }
        parent.addChild(hostedVC)
        hostedVC.didMove(toParent: parent)
    }
}
