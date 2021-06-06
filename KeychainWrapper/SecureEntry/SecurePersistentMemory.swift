//
//  SecurePersistentMemory.swift
//  KeychainWrapper
//
//  Created by Emilio Parra on 05/06/21.
//

import Foundation
import Security

enum SecurePersistentMemoryError: Error {
    case invalidData
    case failure(OSStatus)
    case unretrievable
}

/// # SecurePersistentMemory
/// This is a wrapper for the keychain system for iOS:
class SecurePersistentMemory {
    
    private static let serviceName = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "com.SecurePersistentMemory"
    
    /// Builds a query dictionary
    /// - parameters:
    ///     - key: The key to build the query dictionary.
    /// - returns:
    ///     - A query dictionary to build Keychain entries.
    private func buildQueryDictionary(forKey key: String) throws -> [CFString: Any] {
        guard let keyData = key.data(using: .utf8) else {
            print("Invalid content")
            throw SecurePersistentMemoryError.invalidData
        }
        
        let queryDictionary: [CFString: Any] = [
            kSecAttrService: SecurePersistentMemory.serviceName,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyData
        ]
        
        return queryDictionary
    }
    
    /// List all exiting keys in the current service
    /// - returns:
    ///     - A list of stored keys.
    func listKeys() throws -> Set<String>{
        let queryDictionary: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: SecurePersistentMemory.serviceName,
            kSecReturnAttributes: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitAll,
        ]
        
        var data: AnyObject?
        
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &data)
        guard status == errSecSuccess else {
            throw SecurePersistentMemoryError.failure(status)
        }
        
        var keys = Set<String>()
        if let results = data as? [[AnyHashable: Any]] {
            for attributes in results {
                if let accountData = attributes[kSecAttrAccount] as? Data,
                    let account = String(data: accountData, encoding: String.Encoding.utf8) {
                    keys.insert(account)
                }
            }
        }
        
        return keys
    }
    
    /// Adds or updates a new entry with an asssociated key.
    /// - parameters:
    ///     - entry: The entry data to be stored.
    ///     - key: The key to save the entry.
    func set(entry: String, forKey key: String) throws {
        guard !entry.isEmpty && !key.isEmpty  else {
            print("Entro or key params should have content.")
            throw SecurePersistentMemoryError.invalidData
        }
        
        try remove(forKey: key)
        
        var queryDictionary = try buildQueryDictionary(forKey: key)
        queryDictionary[kSecValueData] = entry.data(using: .utf8)
        
        let status = SecItemAdd(queryDictionary as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecurePersistentMemoryError.failure(status)
        }
    }
    
    /// Retrieves an entry for specified key.
    /// - parameters:
    ///     - key:The key to retrieve the entry data.
    /// - returns:
    ///     - The entry associated to the specified key.
    func entry(forKey key: String) throws -> String? {
        guard !key.isEmpty  else {
            print("Key param should have content.")
            throw SecurePersistentMemoryError.invalidData
        }
        
        var queryDictionary = try buildQueryDictionary(forKey: key)
        queryDictionary[kSecReturnData] = kCFBooleanTrue
        queryDictionary[kSecMatchLimit] = kSecMatchLimitOne
        
        var data: AnyObject?
        
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &data)
        guard status == errSecSuccess else {
            throw SecurePersistentMemoryError.failure(status)
        }
        
        guard let itemData = data as? Data,
              let item = String(data: itemData, encoding: .utf8) else {
            throw SecurePersistentMemoryError.unretrievable
        }
        return item
    }
    
    /// Removes an entry for specified key.
    /// - parameters:
    ///     - key:The key to remove the entry data.
    func remove(forKey key: String) throws {
        guard !key.isEmpty  else {
            print("Key param should have content.")
            throw SecurePersistentMemoryError.invalidData
        }
        
        let queryDictionary = try buildQueryDictionary(forKey: key)
        SecItemDelete(queryDictionary as CFDictionary)
    }
}
