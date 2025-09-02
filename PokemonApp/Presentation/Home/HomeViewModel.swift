//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import Foundation

final class HomeViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    private var offset = 0
    internal var pokemonList = [PokemonDetailModel]()
    
    init(useCase: PokemonUseCase = PokemonUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func fetchPokemonList(limit: Int = 10, offset: Int = 10) {
        loadingState.send(.loading)
        useCase.fetchListPokemon(limit: limit, offset: self.offset)
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.loadingState.send(.finished)
                case .failure:
                    self.loadingState.send(.failed)
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                self.pokemonList.append(contentsOf: $0)
                self.offset += offset
            }
            .store(in: &cancellables)
    }
    
    internal func isPokemonFavorite(_ data: PokemonDetailModel) -> Bool {
        useCase.fetchFavoritePokemon(by: data.name) != nil
    }
    
    @discardableResult
    internal func saveFavoritePokemon(_ data: PokemonDetailModel) -> Bool {
        useCase.saveFavoritePokemon(data)
    }
    
    @discardableResult
    internal func deleteFavoritePokemon(_ data: PokemonDetailModel) -> Bool {
        useCase.deleteFavoritePokemon(data)
    }
}
