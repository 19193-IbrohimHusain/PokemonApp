//
//  ProfileViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import AsyncDisplayKit

final class ProfileViewController: BaseASDKViewController {
    private let profileImage = ASImageNode().configure {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "BlankUser")
        $0.cornerRadius = 40
        $0.style.preferredSize = CGSizeMake(80, 80)
    }
    
    private let usernameNode = ASTextNode()
    private let emailNode = ASTextNode()
    
    private let tableNode = ASTableNode(style: .insetGrouped)
    
    private let viewModel = ProfileViewModel()
    
    override func configNode() {
        setupNode()
        bindEvent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.view.showsVerticalScrollIndicator = false
        viewModel.fetchCurrentUser()
    }
    
    private func setupNode() {
        node.backgroundColor = .systemGroupedBackground
        tableNode.style.flexGrow = 1
        tableNode.dataSource = self
        tableNode.delegate = self
        node.layoutSpecBlock = { [weak self] _,_ in
            guard let self = self else { return ASLayoutSpec() }
            let nameAndEmailStack = ASStackLayoutSpec(
                direction: .vertical,
                spacing: 4,
                justifyContent: .spaceBetween,
                alignItems: .stretch,
                children: [usernameNode, emailNode]
            )
            
            let pictureNameAndEmailStack = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 10,
                justifyContent: .start,
                alignItems: .center,
                children: [profileImage, nameAndEmailStack]
            )
            
            let insetProfileInfo = ASInsetLayoutSpec(
                insets: .init(top: 16, left: 8, bottom: 0, right: 8),
                child: pictureNameAndEmailStack
            )
            
            let profileInfoAndTableStack = ASStackLayoutSpec(
                direction: .vertical,
                spacing: 8,
                justifyContent: .start,
                alignItems: .stretch,
                children: [insetProfileInfo, tableNode]
            )
            
            return ASInsetLayoutSpec(
                insets: .init(top: 0, left: 8, bottom: 0, right: 8),
                child: profileInfoAndTableStack
            )
        }
    }
    
    private func bindEvent() {
        viewModel.userData
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.usernameNode.attributedText = NSAttributedString(
                    string: $0.name,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                        .foregroundColor: UIColor.label
                    ]
                )
                self.emailNode.attributedText = NSAttributedString(
                    string: $0.email,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                )
            }
            .store(in: &cancellables)
        
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    LoadingHUDNode.show()
                case .finished:
                    LoadingHUDNode.hide()
                    self.navigateToLogin()
                default:
                    LoadingHUDNode.hide()
                }
            }
            .store(in: &cancellables)
            
        viewModel.displayAlert
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.displayAlert(title: $0.title, message: $0.message)
            }
            .store(in: &cancellables)
    }
    
    private func navigateToLogin() {
        let vc = LoginViewController()
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    private func navigateToFavorite() {
        let vc = FavoritePokemonViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showEditProfile() {
        let vc = EditProfileViewController()
        navigationController?.present(vc, animated: true)
    }
    
    private func confimLogout() {
        displayAlert(
            title: "Confirm Logout",
            message: "Are you sure you want to logout?",
            showSecondAction: true,
            actionHandler: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.logout()
            }
        )
    }
}

extension ProfileViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuData.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let data = viewModel.menuData[safe: indexPath.row]
        return { MenuCellNode(title: data?.title, icon: data?.icon, tint: data?.tint) }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Menu"
    }
}

extension ProfileViewController: ASTableDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let title = viewModel.menuData[safe: indexPath.row]?.title else { return }
        switch title {
        case "Edit Profile":
            displayAlert(title: "Coming Soon", message: "This feature is still in development")
        case "Favorites":
            navigateToFavorite()
        case "Logout":
            confimLogout()
        default: break
        }
    }
}
