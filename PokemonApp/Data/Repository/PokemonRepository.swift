//
//  PokemonRepository.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import RxSwift

protocol PokemonDataSource {
    func fetchListPokemon(limit: Int, offset: Int) -> Single<[PokemonDetailModel]>
    func fetchListPokemonCache() -> [PokemonDetailModel]
    func fetchDetailPokemon(of name: String) -> Single<PokemonDetailModel>
    func fetchPokemonSpecies(of name: String) -> Single<PokemonSpecies>
    func fetchPokemonType(for type: String) -> Single<PokemonType>
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
    
    func fetchListPokemon(limit: Int, offset: Int) -> Single<[PokemonDetailModel]> {
        let list: Single<PokemonResponse> = manager.fetchDecodable(
            .listPokemon(limit: limit, offset: offset),
            timeout: 60
        )
        
        var cache = fetchListPokemonCache()
        
        return list.map { $0.results.map(\.name) }
            .flatMap { [weak self] names -> Single<[PokemonDetailModel]> in
                guard let self = self else { return Single.never() }
                let detailSingles = names.map { self.fetchDetailPokemon(of: $0) }
                return Single.zip(detailSingles)
            }
            .do(onSuccess: { [weak self] in
                guard let self = self else { return }
                do {
                    cache.append(contentsOf: $0)
                    let uniqueCache = cache.unique()
                    try self.listDb.saveList(of: uniqueCache)
                } catch {}
            })
            .catch { [weak self] in
                guard let self = self else { return .error($0) }
                let slice = sliceListPokemonCache(for: limit, offset: offset, cache: cache)
                return slice.isEmpty ? .error($0) : .just(slice)
            }
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
    
    func fetchDetailPokemon(of name: String) -> Single<PokemonDetailModel> {
        manager.fetchDecodable(.detailPokemon(name: name), timeout: 60)
    }
    
    func fetchPokemonSpecies(of name: String) -> Single<PokemonSpecies> {
        let species: Single<PokemonSpecies> = manager.fetchDecodable(
            .speciesPokemon(name: name),
            timeout: 60
        )
        return species.do(onSuccess: { [weak self] in
            guard let self = self else { return }
            do {
                try self.detailDb.savePokemonSpecies(of: name, value: $0)
            } catch {}
        })
        .catch { [weak self] in
            guard let self = self else { return .error($0) }
            guard let cache = self.detailDb.fetchPokemonSpecies(of: name) else { return .error($0) }
            return .just(cache)
        }
    }
    
    func fetchPokemonType(for type: String) -> Single<PokemonType> {
        let typePokemon: Single<PokemonType> = manager.fetchDecodable(
            .typeElement(name: type),
            timeout: 60
        )
        return typePokemon.do(onSuccess: { [weak self] in
            guard let self = self else { return }
            do {
                try self.detailDb.savePokemonType(for: type, value: $0)
            } catch {}
        })
        .catch { [weak self] in
            guard let self = self else { return .error($0) }
            guard let cache = self.detailDb.fetchPokemonType(for: type) else { return .error($0) }
            return .just(cache)
        }
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
