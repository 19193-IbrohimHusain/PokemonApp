//
//  FavoritePokemonViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import UIKit
import SnapKit
import MBProgressHUD

final class FavoritePokemonViewController: BaseViewController {
    private let tableView = UITableView().configure {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .systemGroupedBackground
        $0.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private let viewModel = FavoritePokemonViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindEvent()
        viewModel.fetchPokemonList()
    }
    
    private func setupView() {
        navigationItem.title = "Favorite Pokemon"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(PokemonCardTableViewCell.self)
    }
    
    private func bindEvent() {
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                default:
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func navigateToDetailPokemon(with pokemon: PokemonDetailModel) {
        let vc = DetailPokemonViewController()
        vc.setContent(with: pokemon)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FavoritePokemonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonCardTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return cell }
        cell.setContent(with: data, isFavorite: true)
        cell.toggleFavorite = { [weak self] save in
            guard let self = self else { return }
            self.viewModel.deleteFavoritePokemon(at: indexPath.row)
            tableView.reloadData()
        }
        return cell
    }
}

extension FavoritePokemonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeAction = UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,_ in
            guard let self = self else { return }
            self.viewModel.deleteFavoritePokemon(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }])
        swipeAction.performsFirstActionWithFullSwipe = true
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return }
        navigateToDetailPokemon(with: data)
    }
}
