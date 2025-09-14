//
//  SearchViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import AsyncDisplayKit
import Combine

final class SearchViewController: BaseASDKViewController {
    private let searchController = UISearchController().configure {
        $0.searchBar.placeholder = "Pokemon Name"
        $0.hidesNavigationBarDuringPresentation = false
        $0.automaticallyShowsCancelButton = false
    }
    
    private let tableNode = ASTableNode().configure {
        $0.backgroundColor = .systemGroupedBackground
        $0.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        $0.view.separatorStyle = .none
        $0.view.showsVerticalScrollIndicator = false
        $0.style.flexGrow = 1
    }
    
    private let viewModel = SearchViewModel()
    
    override func configNode() {
        navigationItem.title = "Search Pokemon"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        node.backgroundColor = .systemBackground
        tableNode.dataSource = self
        tableNode.delegate = self
        node.layoutSpecBlock = { [weak self] node,_ in
            guard let self = self else { return ASLayoutSpec() }
            return ASInsetLayoutSpec(insets: .zero, child: self.tableNode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindEvent()
        viewModel.fetchPokemonListFromCache()
    }
    
    private func bindEvent() {
        viewModel.bindSearchSubject()
        
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .finished:
                    self.tableNode.reloadData()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: searchController.searchBar.searchTextField
        )
        .map { ($0.object as? UISearchTextField)?.text }
        .receive(on: RunLoop.main)
        .subscribe(viewModel.searchQuery)
        .store(in: &cancellables)
    }
    
    private func navigateToDetailPokemon(with pokemon: PokemonDetailModel) {
        let vc = DetailPokemonViewController()
        vc.setContent(with: pokemon)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResult.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let data = viewModel.searchResult[safe: indexPath.row] else { return { .init() } }
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

extension SearchViewController: ASTableDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.searchResult[safe: indexPath.row] else { return }
        navigateToDetailPokemon(with: data)
    }
}
