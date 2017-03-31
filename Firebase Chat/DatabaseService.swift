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
let FIR_CHILD_USER_MESSAGES = "user-messages"

enum DataTypes {
    case user
    case message
    case userMessages
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
    
    var userMessagesRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_USER_MESSAGES)
    }
    
    func saveData(uid: String?, type: DataTypes, data: Dictionary<String, AnyObject>, fan: Bool = false, onComplete: Completion?) {
        if uid == nil && type == .user { fatalError("uid is required if a user is to be saved") }
        
        let uniqueRef: FIRDatabaseReference
        
        switch type {
        case .message, .userMessages: uniqueRef = messagesRef.childByAutoId()
        case .user: uniqueRef = usersRef.child(uid!)
        }
        
        uniqueRef.updateChildValues(data) { [weak self] (error, _) in
            if error != nil {
                onComplete?("Error saving data to the database", nil)
            }
    
            if fan {
                self?.saveFanData(childRef: uniqueRef, data: data, onComplete: onComplete)
            } else {
                onComplete?(nil, nil)
                
            }
        }
    }
    
    func saveFanData(childRef: FIRDatabaseReference, data: Dictionary<String, AnyObject>, onComplete: Completion?) {
        guard let fromId = data["fromId"] as? String, let toId = data["toId"] as? String else { return }
        
        let senderRef = userMessagesRef.child(fromId)
        let receiverRef = userMessagesRef.child(toId)
        
        let typeId = childRef.key
        
        senderRef.updateChildValues([typeId: 1]) { (error, _) in
            if error != nil {
                onComplete?("Error saving data to the database", nil)
            }
        
            receiverRef.updateChildValues([typeId: 1]) { (error, _) in
                if error != nil {
                    onComplete?("Error saving data to the database", nil)
                }
                
                onComplete?(nil, nil)
            }
        }
    }
    
    
    func retrieveSingleObject(queryString: String, type: DataTypes, onComplete: ((_ snapshot: FIRDataSnapshot) -> Void)?) {
        guard let currentId = AuthenticationService.instance.currentId() else { return }
        
        let ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef.child(queryString)
        case .message: ref = messagesRef.child(queryString)
        case .userMessages: ref = userMessagesRef.child(currentId).child(queryString)
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            onComplete?(snapshot)
            
        }, withCancel: nil)
    }
    
    func retrieveMultipleObjects(type: DataTypes, onComplete: ((_ snapshot: FIRDataSnapshot) -> Void)?) {
        guard let currentId = AuthenticationService.instance.currentId() else { return }

        let ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef
        case .message: ref = messagesRef
        case .userMessages: ref = userMessagesRef.child(currentId)
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


