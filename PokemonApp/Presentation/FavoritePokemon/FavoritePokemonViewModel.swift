//
//  FavoritePokemonViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 18/08/25.
//

import RxSwift

final class FavoritePokemonViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    private var offset = 0
    internal var pokemonList = [PokemonDetailModel]()
    
    init(useCase: PokemonUseCase = PokemonUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func fetchPokemonList() {
        loadingState.onNext(.loading)
        pokemonList = useCase.fetchFavoritePokemon()
        loadingState.onNext(.idle)
    }
    
    @discardableResult
    internal func deleteFavoritePokemon(at index: Int) -> Bool {
        let data = pokemonList.remove(at: index)
        return useCase.deleteFavoritePokemon(data)
    }
}
