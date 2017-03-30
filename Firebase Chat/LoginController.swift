//
//  LoginController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    private let contentOffset: CGFloat = 12
    private let containerViewHeight: CGFloat = 150
    private let loginButtonHeight: CGFloat = 50
    private let profileImageLength: CGFloat = 150
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = { [weak self] in
        guard let this = self else {return UIButton() }
        let button = UIButton(type: .system)
        button.backgroundColor = .rgb(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(this, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 220, g: 220, b: 220)
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.placeholder = "Email"
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 220, g: 220, b: 220)
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        return tf
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "gameofthrones_splash")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .rgb(r: 61, g: 91, b: 151)
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)

        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            // Error message insert later
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            let ref = FIRDatabase.database().reference()
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err.debugDescription)
                }
                
                
            })
            
        })
    }
    
    func setupProfileImageView() {
        profileImageView.anchorCenterXToSuperview()
        profileImageView.anchor(top: nil, left: nil, bottom: inputContainerView.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: contentOffset, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
    }
    
    func setupInputsContainerView() {
        inputContainerView.anchorCenterXYSuperview()
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -contentOffset * 2).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: containerViewHeight).isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)

        nameTextField.anchor(top: inputContainerView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        nameSeparatorView.anchor(top: nameTextField.bottomAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        emailTextField.anchor(top: nameSeparatorView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        emailSeparatorView.anchor(top: emailTextField.bottomAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        passwordTextField.anchor(top: emailSeparatorView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3).isActive = true

    }
    
    func setupLoginRegisterButton() {
        loginRegisterButton.anchorCenterXToSuperview()
        loginRegisterButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -contentOffset * 2).isActive = true
        loginRegisterButton.anchor(top: inputContainerView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: contentOffset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: loginButtonHeight)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
