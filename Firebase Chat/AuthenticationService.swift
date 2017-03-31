//
//  AuthenticationService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationService {
    
    private static let _instance = AuthenticationService()
    
    static var instance: AuthenticationService {
        return _instance
    }
    
    func currentId() -> String? {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            return id
        }
        
        return nil
    }
    
    func createUser(email: String, password: String, onComplete: Completion?) {
    
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            }
            
            onComplete?(nil, user)
            
        })
    }
 
    
    func signin(email: String, password: String, onComplete: Completion?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, user)
            }
        })
    }
    
    func signout(onCompletion: Completion) {
        do {
            try FIRAuth.auth()?.signOut()
            onCompletion(nil, nil)
        } catch {
            onCompletion("There was an error while logging you out. Please try again.", nil)
        }
    }
    
    private func processFirebaseErrors(error: NSError, onComplete: Completion?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .errorCodeUserNotFound:
                onComplete?("No account exists with the provided email.", nil)
            case .errorCodeInvalidEmail:
                onComplete?("Invalid Email Address Format", nil)
            case .errorCodeWeakPassword:
                onComplete?("Password must be at least 6 characters", nil)
            case .errorCodeWrongPassword:
                onComplete?("Invalid Email Address/Password Combination", nil)
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Email is already in use", nil)
            default:
                onComplete?("There was a problem authenticating. Please try again", nil)
            }
        }
    }
    
}
