//
//  ProfileViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import UIKit
import Combine

final class ProfileViewModel: BaseViewModel {
    private let useCase: AuthUseCase
    internal let userData = PassthroughSubject<User, Never>()
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
        loadingState.send(.loading)
        defer { loadingState.send(.idle) }
        guard let user = ActiveUserHelper.shared.user else {
            userData.send(User(name: "Guest"))
            return
        }
        userData.send(user)
    }
    
    internal func logout() {
        loadingState.send(.loading)
        useCase.logout()
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .finished:
                    self.loadingState.send(.finished)
                case .failure:
                    self.loadingState.send(.failed)
                    self.displayAlert.send(("Logout Failed", "Sorry, something went wrong on our end. Please try again later."))
                }
            } receiveValue: { [weak self] in
                guard let _ = self else { return }
            }
            .store(in: &cancellables)
    }
}
