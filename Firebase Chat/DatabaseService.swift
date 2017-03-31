//
//  DatabaseService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase

let FIR_CHILD_USERS = "users"
let FIR_CHILD_PROFILE = "profile"
let FIR_CHILD_MESSAGES = "messages"

enum DataTypes {
    case user
    case message
}


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
    
    var messagesRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_MESSAGES)
    }
    
    func saveData(uid: String?, type: DataTypes, data: Dictionary<String, AnyObject>, onComplete: Completion?) {
        if uid == nil && type == .user { fatalError("uid is required if a user is to be saved") }
        
        let uniqueRef: FIRDatabaseReference
        
        switch type {
        case .message: uniqueRef = messagesRef.childByAutoId()
        case .user: uniqueRef = usersRef.child(uid!)
        }
        
        uniqueRef.updateChildValues(data) { (error, _) in
            if error != nil {
                onComplete?("Error saving data to the database", nil)
            }
            onComplete?(nil, nil)
        }
    }
    
    
    func retrieveSingleObject(queryString: String, type: DataTypes, onComplete: ((_ snapshot: FIRDataSnapshot) -> Void)?) {
        
        let ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef.child(queryString)
        case .message: ref = messagesRef.child(queryString)
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            onComplete?(snapshot)
            
        }, withCancel: nil)
    }
    
    func retrieveMultipleObjects(type: DataTypes, onComplete: ((_ snapshot: FIRDataSnapshot) -> Void)?) {
        
        let ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef
        case .message: ref = messagesRef
        }
        
        ref.observe(.childAdded, with: { (snapshot) in
            onComplete?(snapshot)
        }, withCancel: nil)
    }
    
    private func retrieveOne() {
        
    }
    
    private func retrieveMany() {
        
    }
    
}


