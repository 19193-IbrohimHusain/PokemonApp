//
//  AnyObject + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Foundation

public protocol Configurable {}

extension NSObject: Configurable {}

public extension Configurable where Self: AnyObject {
    @discardableResult
    func configure(_ transform: (Self) -> Void) -> Self {
        transform(self)
        return self
    }
}
