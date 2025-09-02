//
//  SearchViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 17/08/25.
//

import Foundation
import Combine

final class SearchViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    internal var pokemonList = [PokemonDetailModel]()
    internal var searchResult = [PokemonDetailModel]()
    internal let searchQuery = PassthroughSubject<String?, Never>()
    
    init(useCase: PokemonUseCase = PokemonUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func fetchPokemonListFromCache() {
        let cache = useCase.fetchListPokemonCache()
        pokemonList = cache
        searchResult = cache
    }
    
    internal func bindSearchSubject() {
        searchQuery
            .receive(on: RunLoop.main)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] query -> [PokemonDetailModel] in
                guard let self else { return [] }
                guard let q = query, !q.isEmpty else { return self.pokemonList }
                return self.pokemonList.filter { $0.name.lowercased().contains(q.lowercased()) }
            }
            .sink { [weak self] in
                guard let self = self else { return }
                self.searchResult = $0
                self.loadingState.send(.finished)
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
