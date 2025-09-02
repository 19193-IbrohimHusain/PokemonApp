//
//  PokemonRepository.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Combine

protocol PokemonDataSource {
    func fetchListPokemon(limit: Int, offset: Int) -> AnyPublisher<[PokemonDetailModel], Error>
    func fetchListPokemonCache() -> [PokemonDetailModel]
    func fetchDetailPokemon(of name: String) -> AnyPublisher<PokemonDetailModel, Error>
    func fetchPokemonSpecies(of name: String) -> AnyPublisher<PokemonSpecies, Error>
    func fetchPokemonType(for type: String) -> AnyPublisher<PokemonType, Error>
    func fetchFavoritePokemon(of user: String) -> [PokemonDetailModel]
    func fetchFavoritePokemon(of user: String, by name: String) -> PokemonDetailModel?
    func saveFavoritePokemon(of user: String, value: PokemonDetailModel) -> Bool
    func deleteFavoritePokemon(of user: String, value: PokemonDetailModel) -> Bool
}

final class PokemonRepository: PokemonDataSource {
    private let manager: NetworkRequest
    private let listDb: PokemonListDatabase
    private let detailDb: PokemonDetailDatabase
    private let favDb: FavoritePokemonDataBase
    
    init(
        manager: NetworkRequest = NetworkManager.shared,
        listDb: PokemonListDatabase = DatabaseManager.shared,
        detailDb: PokemonDetailDatabase = DatabaseManager.shared,
        favDB: FavoritePokemonDataBase = DatabaseManager.shared
    ) {
        self.manager = manager
        self.listDb = listDb
        self.detailDb = detailDb
        self.favDb = favDB
    }
    
    func fetchListPokemon(limit: Int, offset: Int) -> AnyPublisher<[PokemonDetailModel], Error> {
        let list: AnyPublisher<PokemonResponse, Error> = manager.fetchDecodable(.listPokemon(limit: limit, offset: offset), timeout: 60)
        
        var cache = fetchListPokemonCache()
        
        return list
            .map { $0.results.map(\.name) }
            .flatMap { [weak self] names -> AnyPublisher<[PokemonDetailModel], Error> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let detailPublishers = names.map { self.fetchDetailPokemon(of: $0) }
                return Publishers.ZipMany(detailPublishers).eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] in
                guard let self else { return }
                do {
                    cache.append(contentsOf: $0)
                    let uniqueCache = cache.unique()
                    try self.listDb.saveList(of: uniqueCache)
                } catch {}
            })
            .catch { [weak self] error -> AnyPublisher<[PokemonDetailModel], Error> in
                guard let self else { return Fail(error: error).eraseToAnyPublisher() }
                let slice = self.sliceListPokemonCache(for: limit, offset: offset, cache: cache)
                return slice.isEmpty
                ? Fail(error: error).eraseToAnyPublisher()
                : Just(slice).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchListPokemonCache() -> [PokemonDetailModel] {
        listDb.fetchListPokemon()
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
    
    func fetchDetailPokemon(of name: String) -> AnyPublisher<PokemonDetailModel, Error> {
        manager.fetchDecodable(.detailPokemon(name: name), timeout: 60)
    }
    
    func fetchPokemonSpecies(of name: String) -> AnyPublisher<PokemonSpecies, Error> {
        let species: AnyPublisher<PokemonSpecies, Error> = manager.fetchDecodable(
            .speciesPokemon(name: name),
            timeout: 60
        )
        
        return species
            .handleEvents(receiveOutput: { [weak self] in
                guard let self = self else { return }
                do {
                    try self.detailDb.savePokemonSpecies(of: name, value: $0)
                } catch {}
            })
            .catch { [weak self] error -> AnyPublisher<PokemonSpecies, Error> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                guard let cache = self.detailDb.fetchPokemonSpecies(of: name) else { return Fail(error: error).eraseToAnyPublisher() }
                return Just(cache).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchPokemonType(for type: String) -> AnyPublisher<PokemonType, Error> {
        let typePokemon: AnyPublisher<PokemonType, Error> = manager.fetchDecodable(
            .typeElement(name: type),
            timeout: 60
        )
        
        return typePokemon
            .handleEvents(receiveOutput: { [weak self] in
                guard let self = self else { return }
                do {
                    try self.detailDb.savePokemonType(for: type, value: $0)
                } catch {}
            })
            .catch { [weak self] error -> AnyPublisher<PokemonType, Error> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                guard let cache = self.detailDb.fetchPokemonType(for: type) else { return Fail(error: error).eraseToAnyPublisher() }
                return Just(cache).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchFavoritePokemon(of user: String) -> [PokemonDetailModel] {
        favDb.fetchFavoritePokemon(of: user)
    }
    
    func fetchFavoritePokemon(of user: String, by name: String) -> PokemonDetailModel? {
        favDb.fetchFavoritePokemon(of: user, by: name)
    }
    
    func saveFavoritePokemon(of user: String, value: PokemonDetailModel) -> Bool {
        do {
            try favDb.saveFavoritePokemon(of: user, value: value)
            return true
        } catch {
            return false
        }
    }
    
    func deleteFavoritePokemon(of user: String, value: PokemonDetailModel) -> Bool {
        do {
            try favDb.deleteFavoritePokemon(of: user, value: value)
            return true
        } catch {
            return false
        }
    }
}
