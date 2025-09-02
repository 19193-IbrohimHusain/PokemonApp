//
//  DetailPokemonViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 16/08/25.
//

import Foundation
import Combine

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
        loadingState.send(.loading)
        
        Publishers.Zip(
            useCase.fetchPokemonSpecies(of: data.name),
            useCase.fetchPokemonType(for: type)
        )
        .subscribe(on: backgroundQueue)
        .receive(on: RunLoop.main)
        .sink { [weak self] in
            guard let self else { return }
            switch $0 {
            case .finished:
                self.loadingState.send(.finished)
            case .failure:
                self.loadingState.send(.failed)
            }
        } receiveValue: { [weak self] in
            guard let self else { return }
            self.pokemonTrivia = $0.englishFlavorText
            self.pokemonGenera = $0.englishGenus
            
            let height = data.height / 10
            let weight = data.weight / 10
            let abilities = data.abilities.map { $0.ability.name.capitalized }.joined(separator: ", ")
            let moves = data.moves.map { $0.move.name.capitalized }.prefix(2).joined(separator: ", ")
            let weakness = $1.weakness?.capitalized
            
            self.pokemonInfo = [
                ("Height", "\(height) m", false),
                ("Weight", "\(weight) kg", false),
                ("Abilities", abilities, false),
                ("Moves", moves, false)
            ]
            
            guard let weakness else { return }
            self.pokemonInfo.append(("Weakness", weakness, true))
        }
        .store(in: &cancellables)
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
