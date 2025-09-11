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
    internal let cachePokemonListSubject = PublishSubject<Void>()
    
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
                self.pokemonList.append(contentsOf: $0)
                self.insertRowToTableView(at: offset)
                self.loadingState.onNext(.finished)
                self.cachePokemonListSubject.onNext(())
            }, onFailure: { [weak self] _ in
                guard let self = self else { return }
                self.fetchAndSliceListPokemonCache(limit: limit, offset: offset)
            })
            .disposed(by: disposeBag)
    }
    
    private func insertRowToTableView(at offset: Int) {
        let oldOffset = self.offset
        self.offset += offset
        let indexPaths = (oldOffset..<self.offset).map { IndexPath(row: $0, section: 0) }
        self.insertRowSubject.onNext(indexPaths)
    }
    
    internal func observeCachePokemonList() {
        cachePokemonListSubject
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.savePokemonCache()
            })
            .disposed(by: disposeBag)
    }
    
    private func savePokemonCache() {
        useCase.savePokemonList(pokemonList)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func fetchAndSliceListPokemonCache(limit: Int, offset: Int) {
        Single.just(useCase.fetchListPokemonCache())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                let slice = sliceListPokemonCache(for: limit, offset: self.offset, cache: $0)
                self.pokemonList.append(contentsOf: slice)
                self.loadingState.onNext(slice.isEmpty ? .failed : .finished)
                guard !slice.isEmpty else { return }
                self.insertRowToTableView(at: offset)
            })
            .disposed(by: disposeBag)
    }
    
    private func sliceListPokemonCache(
        for limit: Int,
        offset: Int,
        cache: [PokemonDetailModel]
    ) -> [PokemonDetailModel] {
        guard limit > 0, !cache.isEmpty else { return [] }
        guard offset < cache.count else { return [] }
        
        let endExclusive = min(cache.count, offset + limit)
        return Array(cache[offset..<endExclusive])
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
