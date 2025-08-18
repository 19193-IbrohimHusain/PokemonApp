//
//  AuthUseCase.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import RxSwift

protocol AuthUseCase {
    func register(_ user: User) -> Single<Void>
    func login(_ user: User) -> Single<Void>
    func currentUser() -> User?
    func logout() -> Single<Void>
}

final class AuthUseCaseImpl: AuthUseCase {
    private let repository: AuthService
    
    init(repository: AuthService = AuthRepository()) {
        self.repository = repository
    }
    
    func register(_ user: User) -> Single<Void> {
        repository.register(user)
    }
    
    func login(_ user: User) -> Single<Void> {
        repository.login(user)
    }
    
    func currentUser() -> User? {
        repository.currentUser()
    }
    
    func logout() -> Single<Void> {
        repository.logout()
    }
}
