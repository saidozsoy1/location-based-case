import Foundation
@testable import Location_Based_Case

class MockStoreDataManager: StoreDataManaging {
    // Test edilen metotları takip etmek için
    var saveObjectCallCount = 0
    var loadObjectCallCount = 0
    var removeObjectCallCount = 0
    
    // Test hatalarını simüle etmek için
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    
    // Metotların çağrılma durumlarını takip etmek için
    var lastSavedKey: StoreKey?
    var lastLoadedKey: StoreKey?
    var lastRemovedKey: StoreKey?
    
    // Test verilerini depolamak için
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
    
    // Test için yardımcı metot - depolama durumunu sıfırlar
    func reset() {
        saveObjectCallCount = 0
        loadObjectCallCount = 0
        removeObjectCallCount = 0
        lastSavedKey = nil
        lastLoadedKey = nil
        lastRemovedKey = nil
        storage.removeAll()
        shouldThrowOnSave = false
        shouldThrowOnLoad = false
    }
} 