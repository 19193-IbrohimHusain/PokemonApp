//
//  ParentTabViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit
import XLPagerTabStrip

final class ParentTabViewController: ButtonBarPagerTabStripViewController {
    private let home = HomeViewController()
    private let profile = ProfileViewController()
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .systemBackground
        settings.style.buttonBarItemBackgroundColor = .systemBackground
        settings.style.selectedBarBackgroundColor = .systemBlue
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .label
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell, newCell, _, changeIndex, _) in
            guard let _ = self, changeIndex == true else { return }
            oldCell?.label.textColor = .label
            newCell?.label.textColor = .systemBlue
        }
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setConstraint()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [home, profile]
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
    
    private func setConstraint() {
        buttonBarView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
        containerView.snp.remakeConstraints {
            $0.top.equalTo(buttonBarView.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    @objc
    private func navigateToSearch() {
        let vc = SearchViewController()
//        vc.setContent(with: home.fetchPokemonList())
        navigationController?.pushViewController(vc, animated: true)
    }
}

