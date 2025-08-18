//
//  DetailPokemonViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import RxSwift

final class DetailPokemonViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    internal var dataDetail: PokemonDetailModel?
    internal var pokemonTrivia: String?
    internal var pokemonGenera: String?
    internal var pokemonInfo = [(title: String, desc: String, chipFormat: Bool)]()
    
    init(useCase: PokemonUseCase = PokemonUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func fetchAdditionalDetail() {
        guard let data = dataDetail, let type = data.types.first?.type.name else { return }
        loadingState.onNext(.loading)
        Single.zip(
            useCase.fetchPokemonSpecies(of: data.name),
            useCase.fetchPokemonType(for: type)
        )
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { [weak self]  in
            guard let self = self else { return }
            self.pokemonTrivia = $0.0.englishFlavorText
            self.pokemonGenera = $0.0.englishGenus
            let height = data.height / 10
            let weight = data.weight / 10
            let abilities = data.abilities.map { $0.ability.name.capitalized }.joined(separator: ", ")
            let moves = data.moves.map { $0.move.name.capitalized }.prefix(2).joined(separator: ", ")
            let weakness = $0.1.weakness?.capitalized
            self.pokemonInfo = [
                ("Height", "\(height) m", false),
                ("Weight", "\(weight) kg", false),
                ("Abilities", abilities, false),
                ("Moves", moves, false),
            ]
            if let weakness = weakness {
                self.pokemonInfo.append(("Weakness", weakness, true))
            }
            self.loadingState.onNext(.finished)
        }, onFailure: { [weak self] _ in
            guard let self = self else { return }
            self.loadingState.onNext(.failed)
        })
        .disposed(by: disposeBag)
    }
    
    internal func isPokemonFavorite() -> Bool {
        guard let data = dataDetail else { return false }
        return useCase.fetchFavoritePokemon(by: data.name) != nil
    }
    
    @discardableResult
    internal func saveFavoritePokemon() -> Bool {
        guard let data = dataDetail else { return false }
        return useCase.saveFavoritePokemon(data)
    }
    
    @discardableResult
    internal func deleteFavoritePokemon() -> Bool {
        guard let data = dataDetail else { return false }
        return useCase.deleteFavoritePokemon(data)
    }
}
