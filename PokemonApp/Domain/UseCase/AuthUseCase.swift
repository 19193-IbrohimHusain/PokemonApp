//
//  AuthUseCase.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Combine

protocol AuthUseCase {
    func register(_ user: User) -> AnyPublisher<Void, Error>
    func login(_ user: User) -> AnyPublisher<Void, Error>
    func currentUser() -> User?
    func logout() -> AnyPublisher<Void, Error>
}

final class AuthUseCaseImpl: AuthUseCase {
    private let repository: AuthService
    
    init(repository: AuthService = AuthRepository()) {
        self.repository = repository
    }
    
    func register(_ user: User) -> AnyPublisher<Void, Error> {
        repository.register(user)
    }
    
    func login(_ user: User) -> AnyPublisher<Void, Error> {
        repository.login(user)
    }
    
    func currentUser() -> User? {
        repository.currentUser()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        repository.logout()
    }
}
