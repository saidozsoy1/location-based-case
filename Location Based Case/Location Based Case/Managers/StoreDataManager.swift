//
//  StoreDataManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import Foundation

enum StoreKey: String {
    case routePoints = "savedRoutePoints"
    
    var key: String {
        return self.rawValue
    }
}

protocol StoreDataManaging {
    func saveObject<T: Encodable>(_ object: T, forKey key: StoreKey) throws
    func loadObject<T: Decodable>(forKey key: StoreKey, as type: T.Type) throws -> T?
    func removeObject(forKey key: StoreKey)
}

enum StoreDataError: Error {
    case encodingFailed
    case decodingFailed
    case noDataFound
}

final class StoreDataManager: StoreDataManaging {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveObject<T: Encodable>(_ object: T, forKey key: StoreKey) throws {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key.key)
        } catch {
            print("Error encoding object: \(error)")
            throw StoreDataError.encodingFailed
        }
    }
    
    func loadObject<T: Decodable>(forKey key: StoreKey, as type: T.Type) throws -> T? {
        guard let data = userDefaults.data(forKey: key.key) else {
            return nil
        }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            print("Error decoding object: \(error)")
            throw StoreDataError.decodingFailed
        }
    }
    
    func removeObject(forKey key: StoreKey) {
        userDefaults.removeObject(forKey: key.key)
    }
} 
