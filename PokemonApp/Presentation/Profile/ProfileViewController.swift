//
//  ProfileViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit
import MBProgressHUD
import XLPagerTabStrip

final class ProfileViewController: BaseViewController {
    private let profileImage = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "BlankUser")
        $0.setCornerRadius(radius: 40)
    }
    
    private let usernameLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private let emailLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped).configure {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraint()
        bindEvent()
        viewModel.fetchCurrentUser()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubviews(profileImage, usernameLabel, emailLabel, tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: viewModel.defaultCellIdentifier)
    }
    
    private func setConstraint() {
        profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(80)
        }
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImage.snp.trailing).inset(-10)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(profileImage.snp.centerY)
        }
        emailLabel.snp.makeConstraints {
            $0.leading.equalTo(usernameLabel)
            $0.top.equalTo(usernameLabel.snp.bottom).inset(-4)
        }
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(profileImage.snp.bottom).inset(-8)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bindEvent() {
        viewModel.userData
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.usernameLabel.text = $0.name
                self.emailLabel.text = $0.email
            }
            .store(in: &cancellables)
        
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                case .finished:
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.navigateToLogin()
                default:
                    MBProgressHUD.hide(for: self.view, animated: true)
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

extension ProfileViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profile")
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.defaultCellIdentifier, for: indexPath)
        let data = viewModel.menuData[safe: indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = data?.title
        cell.imageView?.image = data?.icon
        cell.imageView?.tintColor = data?.tint
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Menu"
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
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
