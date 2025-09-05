//
//  ParentTabViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit

final class ParentTabViewController: UIViewController {
    private let headerBarView = UnderlineHeaderBar()
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
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let pages: [UIViewController] = [
        HomeViewController(),
        ProfileViewController()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setConstraint()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
        headerBarView.updateLayout()
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
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubviews(headerBarView, collectionView)
        headerBarView.delegate = self
        headerBarView.setTitles(["Home", "Profile"])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(TabContainerCell.self)
    }
    
    private func setConstraint() {
        headerBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerBarView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func navigateToSearch() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ParentTabViewController: UnderlineHeaderBarDelegate {
    func tabBar(_ tabBar: UnderlineHeaderBar, didSelectItemAt index: Int) {
        guard index >= 0, index < pages.count else { return }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension ParentTabViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TabContainerCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.host(pages[indexPath.item], in: self)
        return cell
    }
}

extension ParentTabViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerBarView.setIndicatorPosition(with: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.width)
        headerBarView.selectTab(at: index)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return collectionView.bounds.size
    }
}

final class TabContainerCell: UICollectionViewCell {
    func host(_ vc: UIViewController, in parent: UIViewController) {
        if vc.parent != parent {
            parent.addChild(vc)
            contentView.addSubview(vc.view)
            vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            vc.didMove(toParent: parent)
        } else if vc.view.superview != contentView {
            contentView.addSubview(vc.view)
            vc.view.snp.remakeConstraints { $0.edges.equalToSuperview() }
        }
    }
}
