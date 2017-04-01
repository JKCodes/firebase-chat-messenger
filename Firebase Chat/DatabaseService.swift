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
    
    private func saveFanData(childRef: FIRDatabaseReference, data: Dictionary<String, AnyObject>, onComplete: Completion?) {
        guard let fromId = data["fromId"] as? String, let toId = data["toId"] as? String else { return }
        
        let senderRef = userMessagesRef.child(fromId).child(toId)
        let receiverRef = userMessagesRef.child(toId).child(fromId)
        
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
    
    /// For simple retrieval such as a single message or a user
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
    
    /// For complex retrievals such as user-messages (one or two level search) and a retrieval of group of users or messages (one level search)
    func retrieveMultipleObjects(type: DataTypes, eventType: FIRDataEventType, fromId: String?, toId: String?, propagate: Bool?, onComplete: ((_ snapshot: FIRDataSnapshot) -> Void)?) {
        let from = fromId ?? ""
        let to = toId ?? ""
        var prop = propagate ?? true  // if the propagation is set to false, one level searching will be used
        
        // Propagation is overriden to false if toId is not nil, for toId automatically assumes a two level search
        if to != "" {
            prop = false
        }
        
        guard let ref = getRef(type: type, fromId: from, toId: to) else { return }
        
        if type == .userMessages && prop {
            retrieveFanObjectsForUnknownToId(childRef: ref, eventType: eventType, onComplete: onComplete)
        } else {
            ref.observe(eventType, with: { (snapshot) in
                onComplete?(snapshot)
            }, withCancel: nil)
        }
    }
    
    // For unknown toId
    private func retrieveFanObjectsForUnknownToId(childRef: FIRDatabaseReference, eventType: FIRDataEventType, onComplete: ((_ snapshot: FIRDataSnapshot) -> Void)?) {
        childRef.observe(.childAdded, with: { (snapshot) in
            let typeId = snapshot.key
            
            childRef.child(typeId).observe(eventType, with: { (snapshot) in
                onComplete?(snapshot)
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    /// For complex removals such as user-message groups
    func removeMultipleObjects(type: DataTypes, fromId: String?, toId: String?, onComplete: Completion?) {
        let from = fromId ?? ""
        let to = toId ?? ""
        
        guard let ref = getRef(type: type, fromId: from, toId: to) else { return }
        
        ref.removeValue { (error, _) in
            if error != nil {
                onComplete?("There was a problem handling the deletion request.  Please try again.", nil)
            }
            
            onComplete?(nil, nil)
        }
    }
    
    // Used to get refs for retrievals and removals
    private func getRef(type: DataTypes, fromId: String, toId: String) -> FIRDatabaseReference? {
        guard var currentId = AuthenticationService.instance.currentId() else { return nil }
        
        if fromId != "" {
            currentId = fromId
        }
        
        var ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef
        case .message: ref = messagesRef
        case .userMessages: ref = userMessagesRef
        }
        
        if type == .userMessages {
            if toId != "" {
                return ref.child(currentId).child(toId)
            } else {
                return ref.child(currentId)
            }
        } else {
            return ref
        }
    }
    
}


