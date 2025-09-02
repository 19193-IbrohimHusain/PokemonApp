//
//  PokemonUseCase.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Combine

protocol PokemonUseCase {
    func fetchListPokemon(limit: Int, offset: Int) -> AnyPublisher<[PokemonDetailModel], Error>
    func fetchListPokemonCache() -> [PokemonDetailModel]
    func fetchDetailPokemon(of name: String) -> AnyPublisher<PokemonDetailModel, Error>
    func fetchPokemonSpecies(of name: String) -> AnyPublisher<PokemonSpecies, Error>
    func fetchPokemonType(for type: String) -> AnyPublisher<PokemonType, Error>
    func fetchFavoritePokemon() -> [PokemonDetailModel]
    func fetchFavoritePokemon(by name: String) -> PokemonDetailModel?
    func saveFavoritePokemon(_ pokemon: PokemonDetailModel) -> Bool
    func deleteFavoritePokemon(_ pokemon: PokemonDetailModel) -> Bool
}

final class PokemonUseCaseImpl: PokemonUseCase {
    private let repository: PokemonDataSource
    
    init(repository: PokemonDataSource = PokemonRepository()) {
        self.repository = repository
    }
    
    func fetchListPokemon(limit: Int, offset: Int) -> AnyPublisher<[PokemonDetailModel], Error> {
        repository.fetchListPokemon(limit: limit, offset: offset)
    }
    
    func fetchListPokemonCache() -> [PokemonDetailModel] {
        repository.fetchListPokemonCache()
    }
    
    func fetchDetailPokemon(of name: String) -> AnyPublisher<PokemonDetailModel, Error> {
        repository.fetchDetailPokemon(of: name)
    }
    
    func fetchPokemonSpecies(of name: String) -> AnyPublisher<PokemonSpecies, Error> {
        repository.fetchPokemonSpecies(of: name)
    }
    
    func fetchPokemonType(for type: String) -> AnyPublisher<PokemonType, Error> {
        repository.fetchPokemonType(for: type)
    }
    
    func fetchFavoritePokemon() -> [PokemonDetailModel] {
        guard let user = ActiveUserHelper.shared.user else { return [] }
        return repository.fetchFavoritePokemon(of: user.email)
    }
    
    func fetchFavoritePokemon(by name: String) -> PokemonDetailModel? {
        guard let user = ActiveUserHelper.shared.user else { return nil }
        return repository.fetchFavoritePokemon(of: user.email, by: name)
    }
    
    func saveFavoritePokemon(_ pokemon: PokemonDetailModel) -> Bool {
        guard let user = ActiveUserHelper.shared.user else { return false }
        return repository.saveFavoritePokemon(of: user.email, value: pokemon)
    }
    
    func deleteFavoritePokemon(_ pokemon: PokemonDetailModel) -> Bool {
        guard let user = ActiveUserHelper.shared.user else { return false }
        return repository.deleteFavoritePokemon(of: user.email, value: pokemon)
    }
}
