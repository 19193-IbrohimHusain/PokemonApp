//
//  DetailPokemonViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit
import RxSwift

enum DetailPokemonSection: Int, CaseIterable {
    case image, trivia, info
}

final class DetailPokemonViewController: BaseViewController {
    private let favoriteIcon = UIBarButtonItem(
        image: SFSymbols.favorite,
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let tableView = UITableView().configure {
        $0.separatorStyle = .none
        $0.backgroundColor = .systemBackground
        $0.showsVerticalScrollIndicator = false
    }
    
    private let viewModel = DetailPokemonViewModel()
    
    private var isFavorite = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindEvent()
        viewModel.fetchAdditionalDetail()
    }
    
    private func setupView() {
        favoriteIcon.tintColor = .systemRed
        isFavorite = viewModel.isPokemonFavorite()
        favoriteIcon.image = isFavorite ? SFSymbols.favoriteFilled : SFSymbols.favorite
        favoriteIcon.target = self
        favoriteIcon.action = #selector(addFavorite)
        navigationItem.rightBarButtonItem = favoriteIcon
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(DetailPokemonImageTableViewCell.self)
        tableView.registerCell(DetailPokemonTriviaTableViewCell.self)
        tableView.registerCell(DetailPokemonInfoTableViewCell.self)
    }
    
    private func bindEvent() {
        viewModel.loadingState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    LoadingHUD.show(in: self.view)
                case .finished:
                    LoadingHUD.hide(from: self.view)
                    self.tableView.reloadData()
                default:
                    LoadingHUD.hide(from: self.view)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func addFavorite() {
        if isFavorite {
            viewModel.deleteFavoritePokemon()
        } else {
            viewModel.saveFavoritePokemon()
        }
        isFavorite.toggle()
        favoriteIcon.image = isFavorite ? SFSymbols.favoriteFilled : SFSymbols.favorite
    }
    
    internal func setContent(with pokemon: PokemonDetailModel) {
        viewModel.dataDetail = pokemon
    }
}

extension DetailPokemonViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DetailPokemonSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = DetailPokemonSection.allCases[safe: section] else { return 0 }
        switch section {
        case .image:
            return 1
        case .trivia:
            return viewModel.pokemonTrivia == nil ? 0 : 1
        case .info:
            return viewModel.pokemonInfo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = DetailPokemonSection.allCases[safe: indexPath.section] else { return UITableViewCell() }
        switch section {
        case .image:
            let cell: DetailPokemonImageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            guard let data = viewModel.dataDetail else { return cell }
            cell.setContent(with: data, genera: viewModel.pokemonGenera)
            return cell
        case .trivia:
            let cell: DetailPokemonTriviaTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.triviaLabel.text = viewModel.pokemonTrivia
            return cell
        case .info:
            let cell: DetailPokemonInfoTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            guard let data = viewModel.pokemonInfo[safe: indexPath.row] else { return cell }
            cell.setContent(title: data.title, desc: data.desc, chipFormat: data.chipFormat)
            return cell
        }
    }
}

extension DetailPokemonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
