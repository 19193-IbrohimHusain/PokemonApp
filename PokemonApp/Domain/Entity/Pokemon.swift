//
//  Pokemon.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

// MARK: - PokemonModel
struct PokemonResponse: Codable {
    var count: Int?
    var next: String?
    var previous: String?
    var results: [PokemonResult]
    
    enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }
}

// MARK: - Result
struct PokemonResult: Codable {
    var name: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}

// MARK: - PokemonDetail
struct PokemonDetailModel: Codable {
    var abilities: [Ability]
    var height: Int
    var id: Int
    var moves: [Move]
    var name: String
    var order: Int
    var species: Species
    var sprites: Sprites
    var types: [TypeElement]
    var weight: Int
    
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, height, abilities
        case moves, name, order
        case species, sprites, types, weight
    }
}

extension PokemonDetailModel: Hashable {
    static func == (lhs: PokemonDetailModel, rhs: PokemonDetailModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


// MARK: - Ability
struct Ability: Codable {
    var ability: Species
    var isHidden: Bool
    var slot: Int
    
    enum CodingKeys: String, CodingKey {
        case ability, slot
        case isHidden = "is_hidden"
    }
}

// MARK: - Species
struct Species: Codable {
    var name: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

// MARK: - Move
struct Move: Codable {
    var move: Species
    
    enum CodingKeys: String, CodingKey {
        case move
    }
}

// MARK: - Sprites
class Sprites: Codable {
    var frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault  = "front_default"
    }
}

// MARK: - TypeElement
struct TypeElement: Codable {
    var slot: Int
    var type: Species
    
    enum CodingKeys: String, CodingKey {
        case slot
        case type
    }
}

// MARK: - Species Detail
struct PokemonSpecies: Codable {
    let id: Int
    let name: String
    let flavorTextEntries: [FlavorText]
    let genera: [Genus]
    
    var englishFlavorText: String? {
        flavorTextEntries
            .first { $0.language.name == "en" }?
            .flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000C}", with: " ")
    }
    
    var englishGenus: String? {
        genera.first { $0.language.name == "en" }?.genus
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, genera
        case flavorTextEntries = "flavor_text_entries"
    }
}

struct FlavorText: Codable {
    let flavorText: String
    let language: Species
    let version: Species
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
        case version
    }
}

struct Genus: Codable {
    let genus: String
    let language: Species
    
    enum CodingKeys: String, CodingKey {
        case language, genus
    }
}

// MARK: - Type Detail
struct PokemonType: Codable {
    let id: Int
    let name: String
    let damageRelations: DamageRelations
    
    var weakness: String? {
        return damageRelations.doubleDamageFrom.first?.name
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case damageRelations = "damage_relations"
    }
}

struct DamageRelations: Codable {
    let doubleDamageFrom: [Species]
    let doubleDamageTo: [Species]
    
    enum CodingKeys: String, CodingKey {
        case doubleDamageFrom = "double_damage_from"
        case doubleDamageTo   = "double_damage_to"
    }
}
