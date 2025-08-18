//
//  ActiveUserHelper.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 18/08/25.
//

final class ActiveUserHelper {
    static let shared = ActiveUserHelper()
    internal var user: User?
    
    private init(useCase: AuthUseCase = AuthUseCaseImpl()) {
        self.user = useCase.currentUser()
    }
}
