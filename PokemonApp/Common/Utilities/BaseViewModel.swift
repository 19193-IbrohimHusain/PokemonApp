//
//  BaseViewModel.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 15/08/25.
//

import RxSwift

enum LoadingState {
    case idle
    case loading
    case finished
    case failed
}

class BaseViewModel {
    internal let loadingState = PublishSubject<LoadingState>()
    internal let displayAlert = PublishSubject<(title: String, message: String)>()
    internal let disposeBag = DisposeBag()
    
    internal func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    internal func validatePassword(candidate: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }
}
