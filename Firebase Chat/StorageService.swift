//
//  StorageService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseStorage

let FIR_CHILD_PROFILEIMG = "profile_images"
let FIR_CHILD_IMAGE = "message_images"

enum StorageTypes {
    case profile
    case image
}


class StorageService {

    private static let _instance = StorageService()
    
    static var instance: StorageService {
        return _instance
    }
    
    var rootRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var profileRef: FIRStorageReference {
        return rootRef.child(FIR_CHILD_PROFILEIMG)
    }
    
    var messageImgRef: FIRStorageReference {
        return rootRef.child(FIR_CHILD_PROFILEIMG)
    }
    
    func uploadToStorage(type: StorageTypes, data: Data, onComplete: ((_ error: String?, _ metadata: FIRStorageMetadata?) -> Void)?) {
        
        let ref: FIRStorageReference
        
        switch type {
        case .profile: ref = profileRef.child("\(NSUUID().uuidString).jpg")
        case .image: ref = messageImgRef.child("\(NSUUID().uuidString).jpg")
        }
                
        ref.put(data, metadata: nil) { (metadata, error) in
            
            if error != nil {
                onComplete?("An error has occurred while trying to save data to Firebase storage", nil)
            }
            
            onComplete?(nil, metadata)
        }
    }
    
}

