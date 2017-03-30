//
//  DatabaseService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

let FIR_CHILD_USERS = "users"
let FIR_CHILD_PROFILE = "profile"

class DatabaseService {
    private static let _instance = DatabaseService()
    
    static var instance: DatabaseService {
        return _instance
    }
    
    var rootRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var usersRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_USERS)
    }
    
    
    func saveUser(uid: String, data: Dictionary<String, AnyObject>, onComplete: Completion?) {
        
        let userReference = usersRef.child(uid)
        
        userReference.updateChildValues(data) { (error, ref) in
            if error != nil {
                onComplete?("Error saving user to the database", nil)
            }
            
            onComplete?(nil, nil)
            
        }
    }
    
    func retrieveUser(uid: String, onComplete: Completion?) {
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            onComplete?(nil, snapshot.value as AnyObject?)
            
        }, withCancel: nil)
    }
    
}


