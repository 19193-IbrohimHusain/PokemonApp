//
//  FavoritePokemonViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import AsyncDisplayKit

final class FavoritePokemonViewController: BaseASDKViewController {
    private let tableNode = ASTableNode().configure {
        $0.backgroundColor = .systemGroupedBackground
        $0.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        $0.view.separatorStyle = .none
        $0.view.showsVerticalScrollIndicator = false
    }
    
    private let viewModel = FavoritePokemonViewModel()
    
    override func configNode() {
        navigationItem.title = "Favorite Pokemon"
        tableNode.dataSource = self
        tableNode.delegate = self
        node.layoutSpecBlock = { [weak self] _,_ in
            guard let self = self else { return ASLayoutSpec() }
            return ASInsetLayoutSpec(insets: .zero, child: tableNode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindEvent()
        viewModel.fetchPokemonList()
    }
    
    private func bindEvent() {
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    LoadingHUDNode.show(in: self.node)
                default:
                    LoadingHUDNode.hide()
                    self.tableNode.reloadData()
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

extension FavoritePokemonViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemonList.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return { .init() } }
        return {
            let cell = PokemonCardCellNode(data: data, isFavorite: true)
            cell.toggleFavorite = { [weak self] save in
                guard let self = self else { return }
                self.viewModel.deleteFavoritePokemon(at: indexPath.row)
                tableNode.deleteRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
    }
}

extension FavoritePokemonViewController: ASTableDelegate {
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
