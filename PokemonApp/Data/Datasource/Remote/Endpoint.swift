//
//  Endpoint.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Alamofire

enum Endpoint {
    case listPokemon(limit: Int, offset: Int)
    case detailPokemon(name: String)
    case speciesPokemon(name: String)
    case typeElement(name: String)
    
    private var path: String {
        switch self {
        case .listPokemon:
            return "pokemon"
        case .detailPokemon(let name):
            return "pokemon/\(name)"
        case .speciesPokemon(let name):
            return "pokemon-species/\(name)"
        case .typeElement(let name):
            return "type/\(name)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .listPokemon, .detailPokemon, .speciesPokemon, .typeElement:
            return .get
        }
    }
    
    public var parameter: [String: Any]? {
        switch self {
        case .listPokemon(let limit, let offset):
            return ["limit": limit, "offset": offset]
        case .detailPokemon, .speciesPokemon, .typeElement:
            return nil
        }
    }
    
    public var header: HTTPHeaders? {
        switch self {
        case .listPokemon, .detailPokemon, .speciesPokemon, .typeElement:
            return HTTPHeaders(["Content-Type": "application/json"])
        }
    }
    
    public var fullPath: String {
        return BaseConstant.baseURL.appending(path)
    }
}
