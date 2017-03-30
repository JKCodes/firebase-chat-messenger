//
//  LoginController+handlers.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        if email == "" || password == "" {
            displayAlert(title: "Incomplete form", message: "Both fields are required")
            return
        }
        
        AuthenticationService.instance.signin(email: email, password: password) { [weak self] (error, user) in
            
            if error != nil {
                self?.displayAlert(title: "Unable to login", message: error!)
                return
            }
            
            self?.delegate?.fetchUserAndSetupNavBarTitle()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputsContainerViewHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightConstraint?.isActive = false
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightConstraint?.isActive = true
        
        emailTextFieldHeightConstraint?.isActive = false
        emailTextFieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightConstraint?.isActive = true
        
        passwordTextFieldHeightConstraint?.isActive = false
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightConstraint?.isActive = true
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            return
        }
        
        if email == "" || password == "" || name == "" {
            displayAlert(title: "Invalid Form", message: "All fields are required")
            return
        }
        
        AuthenticationService.instance.createUser(email: email, password: password) { [weak self] (error, user) in
            guard let this = self else { return }
            
            if error != nil {
                this.displayAlert(title: "Authentication Error", message: error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            
            if let profileImage = this.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                StorageService.instance.uploadToStorage(type: .profile, data: uploadData, onComplete: { (error, metadata) in
                    if error != nil {
                        this.displayAlert(title: "Unexpected Storage Error", message: error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        this.registerUserIntoDatabase(uid: uid, values: values as [String : AnyObject])
                    }
                    
                })
            }
        }
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        DatabaseService.instance.saveUser(uid: uid, data: values) { [weak self] (error, data) in
            guard let this = self else { return }
            if error != nil {
                this.displayAlert(title: "Unexpected Database Error", message: error!)
            }
            
            let user = User()
            user.setValuesForKeys(values)
            self?.delegate?.setupNavBarWithUser(user: user)
            this.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
