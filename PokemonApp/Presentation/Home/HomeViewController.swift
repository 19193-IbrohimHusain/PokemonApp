//
//  HomeViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit
import RxSwift
import MBProgressHUD
import XLPagerTabStrip

final class HomeViewController: BaseViewController {
    private let tableView = UITableView().configure {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .systemGroupedBackground
        $0.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindEvent()
        viewModel.fetchPokemonList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(PokemonCardTableViewCell.self)
    }
    
    private func bindEvent() {
        viewModel.loadingState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading where viewModel.pokemonList.isEmpty:
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                case .finished:
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                default:
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToDetailPokemon(with pokemon: PokemonDetailModel) {
        let vc = DetailPokemonViewController()
        vc.setContent(with: pokemon)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    internal func fetchPokemonList() -> [PokemonDetailModel] {
        return viewModel.pokemonList
    }
}

extension HomeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Home")
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PokemonCardTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return cell }
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

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.pokemonList.count - 1 else { return }
        viewModel.fetchPokemonList()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.pokemonList[safe: indexPath.row] else { return }
        navigateToDetailPokemon(with: data)
    }
}
