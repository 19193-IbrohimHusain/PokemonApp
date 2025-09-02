//
//  RegisterViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import Foundation

final class RegisterViewModel: BaseViewModel {
    private let useCase: AuthUseCase
    
    init(useCase: AuthUseCase = AuthUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func register(name: String, email: String, password: String) {
        useCase.register(User(email: email, name: name, password: password))
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .finished:
                    self.loadingState.send(.finished)
                case .failure(let error):
                    self.loadingState.send(.failed)
                    if let error = error as? AuthError, error == .userExist {
                        self.displayAlert.send(("Sign Up Failed", "This email is already registered. Please sign in."))
                    } else {
                        self.displayAlert.send(("Sign Up Failed", "Sorry, something went wrong on our end. Please try again later."))
                    }
                }
            } receiveValue: { [weak self] in
                guard let _ = self else { return }
            }
            .store(in: &cancellables)
    }
}
