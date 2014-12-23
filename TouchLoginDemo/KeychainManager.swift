//
//  KeychainManager.swift
//  TouchLoginDemo
//
//  Created by Ale on 10/12/14.
//  Copyright (c) 2014 Alessandro Sisto, Marco Donati. All rights reserved.
//

import UIKit
import Security

class KeychainManager: NSObject {
    
    private let serviceName = "cc.sisto.touchLoginDemo.loginData"
    
    func add(username: String, password : String) -> Bool {
        let query = queryDictionary()
        query[kSecAttrAccount as NSString] = username
        query[kSecValueData as NSString] = password.dataUsingEncoding(NSUTF8StringEncoding)!
        let status = SecItemAdd(query, nil)
        println("Keychain add result: \(status)")
        return status == errSecSuccess
    }
    
    func update(username: String, password : String) -> Bool {
        return delete() && add(username, password: password)
    }
    
    func delete() -> Bool {
        let status = SecItemDelete(queryDictionary())
        println("Keychain delete result: \(status)")
        return  status == errSecSuccess
    }
    
    func accountAndPassword() -> (String, String)? {
        if let user = account() {
            if let pass = password() {
                return (user, pass)
            }
        }
        return nil
    }
    
    func password() -> String? {

        var result : Unmanaged<AnyObject>?
        
        let query = queryDictionary()
        query[kSecReturnData as NSString] = true

        let status : OSStatus = SecItemCopyMatching(query, &result)
        println("Keychain query password result: \(status)")
        if status == errSecSuccess && result?.toOpaque() != nil {
            let retrievedData = Unmanaged<NSData>.fromOpaque(result!.toOpaque()).takeUnretainedValue()
            return NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
    func account() -> String? {
        
        var result : Unmanaged<AnyObject>?
        
        let query = queryDictionary()
        query[kSecReturnAttributes as NSString] = true
        
        let status : OSStatus = SecItemCopyMatching(query, &result)
        println("Keychain query account result: \(status)")
        if status == errSecSuccess && result?.toOpaque() != nil {
            let retrievedData = Unmanaged<NSDictionary>.fromOpaque(result!.toOpaque()).takeUnretainedValue()
            return retrievedData[kSecAttrAccount as NSString] as? NSString
        }
        return nil
    }
    
    //MARK: Utils
    
    private func queryDictionary() -> NSMutableDictionary {
        let query = NSMutableDictionary()
        query[kSecClass as NSString] = kSecClassGenericPassword
        query[kSecAttrService as NSString] = serviceName
        return query
    }

}
