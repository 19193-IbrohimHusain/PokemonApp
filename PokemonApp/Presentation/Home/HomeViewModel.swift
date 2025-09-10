//
//  HomeViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import Foundation
import Combine

final class HomeViewModel: BaseViewModel {
    private let useCase: PokemonUseCase
    private var offset = 0
    internal var pokemonList = [PokemonDetailModel]()
    internal let insertRowSubject = PassthroughSubject<[IndexPath], Never>()
    internal let cachePokemonListSubject = PassthroughSubject<Void, Never>()
    
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
                    self.fetchAndSliceListPokemonCache(limit: limit, offset: offset)
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                self.pokemonList.append(contentsOf: $0)
                self.insertRowToTableView(at: offset)
                self.cachePokemonListSubject.send(())
            }
            .store(in: &cancellables)
    }
    
    private func insertRowToTableView(at offset: Int) {
        let oldOffset = self.offset
        self.offset += offset
        let indexPaths = (oldOffset..<self.offset).map { IndexPath(row: $0, section: 0) }
        self.insertRowSubject.send(indexPaths)
    }
    
    internal func observeCachePokemonList() {
        cachePokemonListSubject
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .flatMap { [weak self] in
                guard let self = self else { return Just(false).eraseToAnyPublisher() }
                return self.useCase.savePokemonList(self.pokemonList)
                    .subscribe(on: backgroundQueue)
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    private func fetchAndSliceListPokemonCache(limit: Int, offset: Int) {
        Just(useCase.fetchListPokemonCache())
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                let slice = sliceListPokemonCache(for: limit, offset: self.offset, cache: $0)
                self.pokemonList.append(contentsOf: slice)
                self.loadingState.send(slice.isEmpty ? .failed : .finished)
                guard !slice.isEmpty else { return }
                self.insertRowToTableView(at: offset)
            }
            .store(in: &cancellables)
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
