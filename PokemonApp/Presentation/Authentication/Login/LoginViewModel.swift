//
//  LoginViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import RxSwift

final class LoginViewModel: BaseViewModel {
    private let useCase: AuthUseCase
    
    init(useCase: AuthUseCase = AuthUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func login(email: String, password: String) {
        useCase.login(User(email: email, password: password))
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.loadingState.onNext(.finished)
            }, onFailure: { [weak self] in
                guard let self = self else { return }
                self.loadingState.onNext(.failed)
                if let error = $0 as? AuthError, error == .invalidCredential {
                    self.displayAlert.onNext(("Sign In Failed", "Your email or password is incorrect. Please try again."))
                } else {
                    self.displayAlert.onNext(("Sign In Failed", "Please double-check your email and password, or sign up if you're new here."))
                }
            })
            .disposed(by: disposeBag)
    }
}
