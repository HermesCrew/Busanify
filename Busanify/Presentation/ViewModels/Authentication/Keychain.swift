//
//  Keychain.swift
//  Busanify
//
//  Created by 이인호 on 7/16/24.
//

import Foundation
import Security

class Keychain {
    func save(key: String, value: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false) as Any
        ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    func read(key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func delete(key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
