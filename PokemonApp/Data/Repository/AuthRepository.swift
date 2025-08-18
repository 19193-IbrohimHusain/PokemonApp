//
//  AuthRepository.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import RxSwift

protocol AuthService {
    func register(_ user: User) -> Single<Void>
    func login(_ user: User) -> Single<Void>
    func currentUser() -> User?
    func logout() -> Single<Void>
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

    func register(_ user: User) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            guard self.db.fetchUser(user.email) == nil else {
                single(.failure(AuthError.userExist))
                return Disposables.create()
            }
            
            do {
                let passwordHash = HashHelper.hashSHA256(user.password)
                let newUser = User(email: user.email, name: user.name, password: passwordHash)
                try self.db.saveUser(newUser)
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func login(_ user: User) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            guard let localUser = self.db.fetchUser(user.email) else {
                single(.failure(AuthError.userNotExist))
                return Disposables.create()
            }
            
            guard HashHelper.hashSHA256(user.password) == localUser.password else {
                single(.failure(AuthError.invalidCredential))
                return Disposables.create()
            }
            
            guard self.keychain.setString(
                user.email,
                for: self.sessionKey,
                accessible: kSecAttrAccessibleAfterFirstUnlock
            ) else {
                single(.failure(AuthError.unknownError))
                return Disposables.create()
            }
            
            ActiveUserHelper.shared.user = User(email: localUser.email, name: localUser.name)
            single(.success(()))
            return Disposables.create()
        }
    }

    func currentUser() -> User? {
        guard let key = keychain.getString(sessionKey), let user = db.fetchUser(key) else { return nil }
        return User(email: user.email, name: user.name)
    }

    func logout() -> Single<Void> {
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            let successDelete = self.keychain.delete(self.sessionKey)
            if successDelete {
                single(.success(()))
            } else {
                single(.failure(AuthError.unknownError))
            }
            
            return Disposables.create()
        }
    }
}
