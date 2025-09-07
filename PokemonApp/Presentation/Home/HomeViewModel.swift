//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import RxSwift

final class HomeViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    private var offset = 0
    internal var pokemonList = [PokemonDetailModel]()
    internal let insertRowSubject = PublishSubject<[IndexPath]>()
    
    init(useCase: PokemonUseCase = PokemonUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func fetchPokemonList(limit: Int = 10, offset: Int = 10) {
        loadingState.onNext(.loading)
        useCase.fetchListPokemon(limit: limit, offset: self.offset)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                let oldOffset = self.offset
                self.pokemonList.append(contentsOf: $0)
                self.offset += offset
                let indexPaths = (oldOffset..<self.offset).map { IndexPath(row: $0, section: 0) }
                self.insertRowSubject.onNext(indexPaths)
                self.loadingState.onNext(.finished)
            }, onFailure: { [weak self] _ in
                guard let self = self else { return }
                self.loadingState.onNext(.failed)
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
