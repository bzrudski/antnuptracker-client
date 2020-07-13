//
// Keychain.swift
// AntNupTracker, the ant nuptial flight field database
// Copyright (C) 2020  Abouheif Lab
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

// Singleton class for managing credentials through the iOS Keychain.
// Access the singleton via `Keychain.shared`.
class Keychain{
    
    /// Errors that may arise during the saving and loading of credentials
    /// from the keychain.
    public enum KeychainError:Error {
        case noPassword
        case unexpectedPasswordData
        case unhandeledError(status: OSStatus)
    }
    
    // MARK: - Singleton instance
    
    /// Singleton instance
    static let shared = Keychain()
    
    /// Private initializer to create a keychain. Private access due to singleton nature.
    private init(){}
    
    //MARK: - Keychain methods
    
    ///This function saves the user's credentials to the keychain.  It throws to enable handling of errors
    ///- parameter username: the user's username
    ///- parameter content: the user's authentication information, along with other user info
    ///- throws: `KeychainError` or `JSON`-related error
    public func saveCredentials(username:String, content:[String:Any]) throws {
        let authData:Data
        if (content.count == 0 ){
            throw KeychainError.noPassword
        }
        
        authData = try JSONSerialization.data(withJSONObject: content, options: [])
        
        let query:[String:Any] =
            [kSecClass as String: kSecClassGenericPassword as String,
             kSecAttrAccount as String: username,
             kSecValueData as String: authData]
        SecItemDelete(query as CFDictionary)
        let status=SecItemAdd(query as CFDictionary, nil)
        
//        print("Status is: \(SecCopyErrorMessageString(status, nil))")
        
        guard status == errSecSuccess else{
            //print("Keychain Error: \(KeychainError.unhandeledError(status: status).localizedDescription)")
            throw KeychainError.unhandeledError(status: status)
        }
        
        //print("Successfully added")
    }
    
    ///Read the user's credentials from the keychain and return the username and user info.
    public func loadCredentials() throws -> (String, [String:Any]){
        
        let query: [String: Any] =
            [kSecClass as String: kSecClassGenericPassword as String,
             kSecMatchLimit as String: kSecMatchLimitOne,
             kSecReturnAttributes as String: true,
             kSecReturnData as String: true]
        
        var item:CFTypeRef?
        let status=SecItemCopyMatching(query as CFDictionary, &item)
        
//        print(status.description)
//        print(item as? [String:Any])
        
        guard status != errSecItemNotFound else{
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else{
            throw KeychainError.unhandeledError(status: status)
        }
        
//        print("Status is: \(SecCopyErrorMessageString(status, nil))")
        
        guard let existingItem=item as? [String:Any],
            let authKeyData=existingItem[kSecValueData as String] as? Data,
            let authKeyStored=try JSONSerialization.jsonObject(with: authKeyData, options: []) as? [String:Any],
            let account=existingItem[kSecAttrAccount as String] as? String
            
            else{
                throw KeychainError.unexpectedPasswordData
        }
        
        
        return (account, authKeyStored)
        //print("Loaded credentials: \(account), \(authKeyStored)")
        //return (credentials, deviceID)
    }
    
    ///Clear the stored credentials from the keychain
    public func clearCredentials() throws{
        let query:[String:Any] =
            [kSecClass as String: kSecClassGenericPassword]
        
        let status=SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status==errSecItemNotFound else{
            throw KeychainError.unhandeledError(status: status)
        }
//        print("Clearing status: \(status)")
//        print("Status is: \(SecCopyErrorMessageString(status, nil))")
    }
}
