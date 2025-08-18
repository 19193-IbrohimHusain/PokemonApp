//
//  RegisterViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import RxSwift

final class RegisterViewModel: BaseViewModel {
    private let useCase: AuthUseCase
    
    init(useCase: AuthUseCase = AuthUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func register(name: String, email: String, password: String) {
        useCase.register(User(email: email, name: name, password: password))
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.loadingState.onNext(.finished)
            }, onFailure: { [weak self] in
                guard let self = self else { return }
                self.loadingState.onNext(.failed)
                if let error = $0 as? AuthError, error == .userExist {
                    self.displayAlert.onNext(("Sign In Failed", "This email is already registered. Please sign in."))
                } else {
                    self.displayAlert.onNext(("Sign In Failed", "Sorry, something went wrong on our end. Please try again later."))
                }
            })
            .disposed(by: disposeBag)
    }
}
