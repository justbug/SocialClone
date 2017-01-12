//
//  DataService.swift
//  SocialClone
//
//  Created by Mark Chen on 2016/12/7.
//  Copyright © 2016年 Mark Chen. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()
class DataService {
    static let dataservice = DataService()
    
    //DB reference
    private let _REF_BASE = DB_BASE
    private let _REF_POST = DB_BASE.child("post")
    private let _REF_USER = DB_BASE.child("user")
    
    //Storage reference
    private var _REF_POST_IMAGE = STORAGE_BASE.child("post-images")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POST: FIRDatabaseReference {
        return _REF_POST
    }
    
    var REF_USER: FIRDatabaseReference {
        return _REF_USER
    }
    
    var REF_POST_IMAGE: FIRStorageReference {
        return _REF_POST_IMAGE
    }
    
    var REF_CURRENT_USER: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_USER_ID)
        let user = REF_USER.child(uid!)
        return user
    }
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        _REF_USER.child(uid).updateChildValues(userData)
    }
}
