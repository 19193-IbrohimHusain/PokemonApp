//
//  LoginViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import Foundation

final class LoginViewModel: BaseViewModel {
    private let useCase: AuthUseCase
    
    init(useCase: AuthUseCase = AuthUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func login(email: String, password: String) {
        useCase.login(User(email: email, password: password))
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .finished:
                    self.loadingState.send(.finished)
                case .failure(let error):
                    self.loadingState.send(.failed)
                    if let error = error as? AuthError, error == .invalidCredential {
                        self.displayAlert.send(("Sign In Failed", "Your email or password is incorrect. Please try again."))
                    } else {
                        self.displayAlert.send(("Sign In Failed", "Please double-check your email and password, or sign up if you're new here."))
                    }
                }
            } receiveValue: { [weak self] in
                guard let _ = self else { return }
            }
            .store(in: &cancellables)
    }
}
