//
//  SearchViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 17/08/25.
//

import RxSwift

final class SearchViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    internal var pokemonList = [PokemonDetailModel]()
    internal var searchResult = [PokemonDetailModel]()
    internal let searchQuery = PublishSubject<String?>()
    
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
            .observe(on: MainScheduler.instance)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] query -> Observable<[PokemonDetailModel]> in
                guard let self = self else { return .just([]) }
                
                guard let query = query, !query.isEmpty else { return .just(self.pokemonList) }
                let result = self.pokemonList.filter { $0.name.lowercased().contains(query.lowercased()) }

                return .just(result)
            }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.searchResult = $0
                self.loadingState.onNext(.finished)
            })
            .disposed(by: disposeBag)
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
