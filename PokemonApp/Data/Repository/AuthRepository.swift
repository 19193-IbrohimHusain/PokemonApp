//
//  AuthRepository.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Combine
import Security

protocol AuthService {
    func register(_ user: User) -> AnyPublisher<Void, Error>
    func login(_ user: User) -> AnyPublisher<Void, Error>
    func currentUser() -> User?
    func logout() -> AnyPublisher<Void, Error>
}

enum AuthError: Error {
    case userExist
    case userNotExist
    case unknownError
    case invalidCredential
}

final class AuthRepository: AuthService {
    private let db: UserDatabase
    private let keychain: KeychainService
    private let sessionKey = "current_user"
    
    init(db: UserDatabase = DatabaseManager.shared, keychain: KeychainService = KeychainManager.shared) {
        self.db = db
        self.keychain = keychain
    }

    func register(_ user: User) -> AnyPublisher<Void, Error> {
        Publishers.Single<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            guard self.db.fetchUser(user.email) == nil else {
                promise(.failure(AuthError.userExist))
                return
            }
            
            do {
                let passwordHash = HashHelper.hashSHA256(user.password)
                let newUser = User(email: user.email, name: user.name, password: passwordHash)
                try self.db.saveUser(newUser)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func login(_ user: User) -> AnyPublisher<Void, Error> {
        Publishers.Single<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            
            guard let localUser = self.db.fetchUser(user.email) else {
                promise(.failure(AuthError.userNotExist))
                return
            }
            
            guard HashHelper.hashSHA256(user.password) == localUser.password else {
                promise(.failure(AuthError.invalidCredential))
                return
            }
            
            guard self.keychain.setString(
                user.email,
                for: self.sessionKey,
                accessible: kSecAttrAccessibleAfterFirstUnlock
            ) else {
                promise(.failure(AuthError.unknownError))
                return
            }
            
            ActiveUserHelper.shared.user = User(email: localUser.email, name: localUser.name)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func currentUser() -> User? {
        guard let key = keychain.getString(sessionKey), let user = db.fetchUser(key) else { return nil }
        return User(email: user.email, name: user.name)
    }

    func logout() -> AnyPublisher<Void, Error> {
        Publishers.Single<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            let successDelete = self.keychain.delete(self.sessionKey)
            if successDelete {
                promise(.success(()))
            } else {
                promise(.failure(AuthError.unknownError))
            }
        }
        .eraseToAnyPublisher()
    }
}
