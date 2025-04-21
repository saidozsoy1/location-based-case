import Foundation
@testable import Location_Based_Case

class MockStoreDataManager: StoreDataManaging {
    // Counters to track tested methods
    var saveObjectCallCount = 0
    var loadObjectCallCount = 0
    var removeObjectCallCount = 0
    
    // For simulating test errors
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    
    // To track method calls
    var lastSavedKey: StoreKey?
    var lastLoadedKey: StoreKey?
    var lastRemovedKey: StoreKey?
    
    // For storing test data
    private var storage: [String: Data] = [:]
    
    func saveObject<T: Encodable>(_ object: T, forKey key: StoreKey) throws {
        saveObjectCallCount += 1
        lastSavedKey = key
        
        if shouldThrowOnSave {
            throw StoreDataError.encodingFailed
        }
        
        do {
            let data = try JSONEncoder().encode(object)
            storage[key.key] = data
        } catch {
            throw StoreDataError.encodingFailed
        }
    }
    
    func loadObject<T: Decodable>(forKey key: StoreKey, as type: T.Type) throws -> T? {
        loadObjectCallCount += 1
        lastLoadedKey = key
        
        if shouldThrowOnLoad {
            throw StoreDataError.decodingFailed
        }
        
        guard let data = storage[key.key] else {
            return nil
        }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            throw StoreDataError.decodingFailed
        }
    }
    
    func removeObject(forKey key: StoreKey) {
        removeObjectCallCount += 1
        lastRemovedKey = key
        storage.removeValue(forKey: key.key)
    }
    
    // Only resets counters and status flags, preserves stored data
    func resetCounters() {
        saveObjectCallCount = 0
        loadObjectCallCount = 0
        removeObjectCallCount = 0
        lastSavedKey = nil
        lastLoadedKey = nil
        lastRemovedKey = nil
        shouldThrowOnSave = false
        shouldThrowOnLoad = false
    }
    
    // Helper method for testing - resets entire storage state
    func reset() {
        resetCounters() // Reset counters and flags
        storage.removeAll() // Clear all storage
    }
} 