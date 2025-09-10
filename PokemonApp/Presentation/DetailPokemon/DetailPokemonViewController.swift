//
//  DetailPokemonViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import AsyncDisplayKit

enum DetailPokemonSection: Int, CaseIterable {
    case image, trivia, info
}

final class DetailPokemonViewController: BaseASDKViewController {
    private let favoriteIcon = UIBarButtonItem(
        image: SFSymbols.favorite,
        style: .plain,
        target: nil,
        action: nil
    )
    
    private let tableNode = ASTableNode().configure {
        $0.backgroundColor = .systemBackground
        $0.view.separatorStyle = .none
        $0.view.showsVerticalScrollIndicator = false
    }
    
    private let viewModel = DetailPokemonViewModel()
    
    private var isFavorite = false
    
    override func configNode() {
        node.backgroundColor = .systemBackground
        tableNode.dataSource = self
        node.layoutSpecBlock = { [weak self] _,_ in
            guard let self = self else { return ASLayoutSpec() }
            return ASInsetLayoutSpec(insets: .zero, child: tableNode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindEvent()
        viewModel.fetchAdditionalDetail()
    }
    
    private func setupNavigationBar() {
        favoriteIcon.tintColor = .systemRed
        isFavorite = viewModel.isPokemonFavorite()
        favoriteIcon.image = isFavorite ? SFSymbols.favoriteFilled : SFSymbols.favorite
        favoriteIcon.target = self
        favoriteIcon.action = #selector(addFavorite)
        navigationItem.rightBarButtonItem = favoriteIcon
    }
    
    private func bindEvent() {
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    LoadingHUDNode.show(in: self.node)
                case .finished:
                    LoadingHUDNode.hide()
                    self.tableNode.reloadData()
                default:
                    LoadingHUDNode.hide()
                }
            }
            .store(in: &cancellables)
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

extension DetailPokemonViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return DetailPokemonSection.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let section = DetailPokemonSection.allCases[safe: indexPath.section] else { return { .init() } }
        switch section {
        case .image:
            guard let data = viewModel.dataDetail else { return { .init() } }
            let genera = viewModel.pokemonGenera
            return { DetailPokemonImageCellNode(data: data, genera: genera) }
        case .trivia:
            let trivia = viewModel.pokemonTrivia
            return { DetailPokemonTriviaCellNode(trivia) }
        case .info:
            guard let data = viewModel.pokemonInfo[safe: indexPath.row] else { return { .init() } }
            return { DetailPokemonInfoCellNode(title: data.title, desc: data.desc, chipFormat: data.chipFormat) }
        }
    }
}
