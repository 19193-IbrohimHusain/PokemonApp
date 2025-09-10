//
//  HomeViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import AsyncDisplayKit

final class HomeViewController: BaseASDKViewController {
    private let tableNode = ASTableNode().configure {
        $0.backgroundColor = .systemGroupedBackground
        $0.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        $0.view.separatorStyle = .none
        $0.view.showsVerticalScrollIndicator = false
    }
    
    private let viewModel = HomeViewModel()
    
    override func configNode() {
        node.backgroundColor = .systemGroupedBackground
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableNode.reloadData()
    }
    
    private func bindEvent() {
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading where self.viewModel.pokemonList.isEmpty:
                    LoadingHUDNode.show()
                default:
                    LoadingHUDNode.hide()
                }
            }
            .store(in: &cancellables)
        
        viewModel.insertRowSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] indexPaths in
                guard let self = self else { return }
                self.tableNode.performBatchUpdates({
                    self.tableNode.insertRows(at: indexPaths, with: .automatic)
                })
            }
            .store(in: &cancellables)
    }
    
    private func navigateToDetailPokemon(with pokemon: PokemonDetailModel) {
        let vc = DetailPokemonViewController()
        vc.setContent(with: pokemon)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemonList.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return { .init() } }
        let isFav = viewModel.isPokemonFavorite(data)
        return {
            let cell = PokemonCardCellNode(data: data, isFavorite: isFav)
            cell.toggleFavorite = { [weak self] save in
                guard let self = self else { return }
                if save {
                    self.viewModel.saveFavoritePokemon(data)
                } else {
                    self.viewModel.deleteFavoritePokemon(data)
                }
                tableNode.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
    }
}

extension HomeViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        guard node.indexPath?.row == viewModel.pokemonList.count - 1 else { return }
        viewModel.fetchPokemonList()
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return }
        navigateToDetailPokemon(with: data)
    }
}
