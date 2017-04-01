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
let FIR_CHILD_VIDEO = "message_videos"

enum StorageTypes {
    case profile
    case image
    case video
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
        return rootRef.child(FIR_CHILD_IMAGE)
    }
    
    var messageVideoRef: FIRStorageReference {
        return rootRef.child(FIR_CHILD_VIDEO)
    }
    
    func uploadToStorageAndReturn(type: StorageTypes, data: Data?, url: URL?, onComplete: ((_ error: String?, _ metadata: FIRStorageMetadata?) -> Void)?) -> FIRStorageUploadTask {
        
        let uploadTask: FIRStorageUploadTask?
        
        if type != .video && data == nil { fatalError("data must be present if the upload type is not video") }
        if type == .video && url == nil { fatalError("url must be present if the upload type is video") }
        
        let ref: FIRStorageReference
        
        switch type {
        case .profile: ref = profileRef.child("\(NSUUID().uuidString).jpg")
        case .image: ref = messageImgRef.child("\(NSUUID().uuidString).jpg")
        case .video: ref = messageVideoRef.child("\(NSUUID().uuidString).mov")
        }
        
        if type != .video {
            uploadTask = ref.put(data!, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    onComplete?("An error has occurred while trying to save data", nil)
                }
                
                onComplete?(nil, metadata)
            }
        } else {
            uploadTask = ref.putFile(url!, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    onComplete?("An error has occurred while trying to upload video", nil)
                }
                
                onComplete?(nil, metadata)
            })
        }
        
        return uploadTask!
    }
    
    func uploadToStorage(type: StorageTypes, data: Data?, url: URL?, onComplete: ((_ error: String?, _ metadata: FIRStorageMetadata?) -> Void)?) {
        _ = uploadToStorageAndReturn(type: type, data: data, url: url, onComplete: onComplete)
    }
    
}

