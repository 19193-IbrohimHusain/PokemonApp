//
//  ProfileViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import RxSwift

final class ProfileViewModel: BaseViewModel {
    private let useCase: AuthUseCase
    internal let userData = PublishSubject<User>()
    internal let defaultCellIdentifier = "defaultCellIdentifier"
    internal let menuData = [
        (icon: SFSymbols.editProfile, title: "Edit Profile", tint: UIColor.systemBlue),
        (icon: SFSymbols.favorite, title: "Favorites", tint: UIColor.systemRed),
        (icon: SFSymbols.logout, title: "Logout", tint: UIColor.systemRed)
    ]
    
    init(useCase: AuthUseCase = AuthUseCaseImpl()) {
        self.useCase = useCase
    }
    
    internal func fetchCurrentUser() {
        loadingState.onNext(.loading)
        defer { loadingState.onNext(.idle) }
        guard let user = ActiveUserHelper.shared.user else {
            userData.onNext(User(name: "Guest"))
            return
        }
        userData.onNext(user)
    }
    
    internal func logout() {
        loadingState.onNext(.loading)
        useCase.logout()
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
