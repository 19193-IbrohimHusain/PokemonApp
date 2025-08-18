//
//  Database.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import CouchbaseLiteSwift

protocol UserDatabase {
    func fetchUser(_ email: String) -> User?
    func saveUser(_ user: User) throws
    func deleteUser(_ email: String) throws
}

protocol PokemonListDatabase {
    func saveList(of pokemon: [PokemonDetailModel]) throws
    func fetchListPokemon() -> [PokemonDetailModel]
}

protocol PokemonDetailDatabase {
    func savePokemonSpecies(of name: String, value: PokemonSpecies) throws
    func savePokemonType(for type: String, value: PokemonType) throws
    func fetchPokemonSpecies(of name: String) -> PokemonSpecies?
    func fetchPokemonType(for type: String) -> PokemonType?
}

protocol FavoritePokemonDataBase {
    func saveFavoritePokemon(of user: String, value: PokemonDetailModel) throws
    func deleteFavoritePokemon(of user: String, value: PokemonDetailModel) throws
    func fetchFavoritePokemon(of user: String, by name: String) -> PokemonDetailModel?
    func fetchFavoritePokemon(of user: String) -> [PokemonDetailModel]
}

fileprivate enum Key: String {
    case dbName = "pokemonapp"
    case json
    case email, username, password
    case pokemonList = "pokemon::list"
    case pokemonAbilities, pokemonName, pokemonImage
}

enum DBError: Error {
    case invalidEncoding
    case iOError
}

final class DatabaseManager: UserDatabase {
    static let shared = DatabaseManager()
    private let db: Database
    
    private init() {
        do {
            db = try Database(name: .dbName)
        } catch {
            fatalError("Failed to create database")
        }
    }
    
    deinit {
        try? db.close()
    }
    
    // MARK: - Users
    func userDocID(_ email: String) -> String {
        "user::\(email.lowercased())"
    }
    
    func saveUser(_ user: User) throws {
        let doc = MutableDocument(id: userDocID(user.email))
            .setString(user.name, forKey: .username)
            .setString(user.email, forKey: .email)
            .setString(user.password, forKey: .password)
        try db.defaultCollection().save(document: doc)
    }
    
    func fetchUser(_ email: String) -> User? {
        guard let user = try? db.defaultCollection().document(
            id: userDocID(email)
        ), let email = user.string(
            forKey: .email
        ), let name = user.string(
            forKey: .username
        ), let pass = user.string(
            forKey: .password
        ) else {
            return nil
        }
        
        return User(email: email, name: name, password: pass)
    }
    
    func deleteUser(_ email: String) throws {
        guard let user = try? db.defaultCollection().document(
            id: userDocID(email)
        ) else {
            throw AuthError.unknownError
        }
        
        try db.defaultCollection().delete(document: user)
    }
}
    
// MARK: - Pokemon List
extension DatabaseManager: PokemonListDatabase {
    func saveList(of pokemon: [PokemonDetailModel]) throws {
        let data = try JSONEncoder().encode(pokemon)
        guard let jsonString = String(data: data, encoding: .utf8) else { throw DBError.invalidEncoding }
        
        let doc = MutableDocument(id: Key.pokemonList.rawValue)
        doc.setString(jsonString, forKey: .json)
        try db.defaultCollection().save(document: doc)
    }
    
    func fetchListPokemon() -> [PokemonDetailModel] {
        guard let doc = try? db.defaultCollection().document(id: Key.pokemonList.rawValue),
              let jsonString = doc.string(forKey: .json),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        
        guard let list = try? JSONDecoder().decode([PokemonDetailModel].self, from: data) else {
            return []
        }
        
        return list
    }
}

extension DatabaseManager: PokemonDetailDatabase {
    // MARK: - Pokemon Detail
    func speciesDocID(_ name: String) -> String {
        "species::\(name.lowercased())"
    }
    
    func savePokemonSpecies(of name: String, value: PokemonSpecies) throws {
        let dict = try value.toDictionary()
        let doc  = MutableDocument(id: speciesDocID(name), data: dict)
        try db.defaultCollection().save(document: doc)
    }
    
    func fetchPokemonSpecies(of name: String) -> PokemonSpecies? {
        guard let doc = try? db.defaultCollection().document(id: speciesDocID(name)) else { return nil }
        return try? PokemonSpecies.toSelf(doc.toDictionary())
    }
    
    func typeDocID(_ type: String) -> String {
        "type::\(type.lowercased())"
    }
    
    func savePokemonType(for type: String, value: PokemonType) throws {
        let dict = try value.toDictionary()
        let doc  = MutableDocument(id: typeDocID(type), data: dict)
        try db.defaultCollection().save(document: doc)
    }
    
    func fetchPokemonType(for type: String) -> PokemonType? {
        guard let doc = try? db.defaultCollection().document(id: typeDocID(type)) else { return nil }
        return try? PokemonType.toSelf(doc.toDictionary())
    }
}

extension DatabaseManager: FavoritePokemonDataBase {
    func favDocID(for user: String, pokemonName: String) -> String {
        "favorite::\(user)::\(pokemonName)"
    }
    
    func saveFavoritePokemon(of user: String, value: PokemonDetailModel) throws {
        let dict = try value.toDictionary()
        let doc  = MutableDocument(id: favDocID(for: user, pokemonName: value.name.lowercased()), data: dict)
        try db.defaultCollection().save(document: doc)
    }
    
    func deleteFavoritePokemon(of user: String, value: PokemonDetailModel) throws {
        guard let pokemon = try? db.defaultCollection().document(
            id: favDocID(for: user, pokemonName: value.name.lowercased())
        ) else {
            throw DBError.iOError
        }
        
        try db.defaultCollection().delete(document: pokemon)
    }
    
    func fetchFavoritePokemon(of user: String, by name: String) -> PokemonDetailModel? {
        guard let doc = try? db.defaultCollection().document(
            id: favDocID(for: user, pokemonName: name)
        ) else { return nil }
        
        return try? PokemonDetailModel.toSelf(doc.toDictionary())
    }
    
    func fetchFavoritePokemon(of user: String) -> [PokemonDetailModel] {
       guard let query = try? QueryBuilder
            .select(SelectResult.all())
            .from(DataSource.collection(db.defaultCollection()))
            .where(Meta.id.like(Expression.string("favorite::\(user)::%")))
            .orderBy(Ordering.property("createdAt").descending()) else {
           return []
       }
        
        var results = [PokemonDetailModel]()
        do {
            for row in try query.execute() {
                if let dict = row.dictionary(forKey: Database.defaultCollectionName)?.toDictionary(),
                   let pokemon = dict.decode(PokemonDetailModel.self) {
                    results.append(pokemon)
                }
            }
        } catch {}
        
        return results
    }
}

extension Database {
    fileprivate convenience init(name: Key) throws {
        try self.init(name: name.rawValue)
    }
}

extension MutableDocument {
    @discardableResult
    final fileprivate func setString(_ value: String, forKey key: Key) -> Self {
        setString(value, forKey: key.rawValue)
    }
    
    @discardableResult
    final fileprivate func setArray(_ value: CouchbaseLiteSwift.ArrayObject?, forKey key: Key) -> Self {
        setArray(value, forKey: key.rawValue)
    }
    
    @discardableResult
    final fileprivate func setInt(_ value: Int, forKey key: Key) -> Self {
        setInt(value, forKey: key.rawValue)
    }
}

extension Document {
    fileprivate func string(forKey key: Key) -> String? {
        string(forKey: key.rawValue)
    }
    
    fileprivate func int(forKey key: Key) -> Int? {
        int(forKey: key.rawValue)
    }
    
    fileprivate func array(forKey key: Key) -> CouchbaseLiteSwift.ArrayObject? {
        array(forKey: key.rawValue)
    }
}
