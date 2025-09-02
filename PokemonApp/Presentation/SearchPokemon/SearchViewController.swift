//
//  SearchViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    private let searchBar = UISearchBar().configure {
        $0.placeholder = "Pokemon Name"
    }
    
    private let tableView = UITableView().configure {
        $0.separatorStyle = .none
        $0.backgroundColor = .systemGroupedBackground
        $0.showsVerticalScrollIndicator = false
    }
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraint()
        bindEvent()
        viewModel.fetchPokemonListFromCache()
    }
    
    private func setupView() {
        navigationItem.title = "Search Pokemon"
        view.backgroundColor = .systemBackground
        view.addSubviews(tableView, searchBar)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(PokemonCardTableViewCell.self)
    }
    
    private func setConstraint() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func bindEvent() {
        viewModel.bindSearchSubject()
        
        viewModel.loadingState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .finished:
                    self.tableView.reloadData()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
    }
    
    private func navigateToDetailPokemon(with pokemon: PokemonDetailModel) {
        let vc = DetailPokemonViewController()
        vc.setContent(with: pokemon)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonCardTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        guard let data = viewModel.searchResult[safe: indexPath.row] else { return cell }
        cell.setContent(with: data, isFavorite: viewModel.isPokemonFavorite(data))
        cell.toggleFavorite = { [weak self] save in
            guard let self = self else { return }
            if save {
                self.viewModel.saveFavoritePokemon(data)
            } else {
                self.viewModel.deleteFavoritePokemon(data)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.searchResult[safe: indexPath.row] else { return }
        navigateToDetailPokemon(with: data)
    }
}
