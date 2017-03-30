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
    private let segmentedControlHeight: CGFloat = 36
    
    private var inputsContainerViewHeightConstraint: NSLayoutConstraint?
    private var nameTextFieldHeightConstraint: NSLayoutConstraint?
    private var emailTextFieldHeightConstraint: NSLayoutConstraint?
    private var passwordTextFieldHeightConstraint: NSLayoutConstraint?
    
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
        button.addTarget(this, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.layer.masksToBounds = true
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
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = { [weak self] in
        guard let this = self else { return UISegmentedControl() }
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(this, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .rgb(r: 61, g: 91, b: 151)
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            // Error message insert later
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            self?.dismiss(animated: true, completion: nil)
        })
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
                
                self.dismiss(animated: true, completion: nil)
            })
            
        })
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
    
    func setupLoginRegisterSegmentedControl() {
        loginRegisterSegmentedControl.anchorCenterXToSuperview()
        loginRegisterSegmentedControl.anchor(top: nil, left: nil, bottom: inputContainerView.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: contentOffset, rightConstant: 0, widthConstant: 0, heightConstant: segmentedControlHeight)
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
    }
    
    func setupProfileImageView() {
        profileImageView.anchorCenterXToSuperview()
        profileImageView.anchor(top: nil, left: nil, bottom: loginRegisterSegmentedControl.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: contentOffset, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
    }
    
    func setupInputsContainerView() {
        inputContainerView.anchorCenterXYSuperview()
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -contentOffset * 2).isActive = true
        inputsContainerViewHeightConstraint = inputContainerView.heightAnchor.constraint(equalToConstant: containerViewHeight)
        inputsContainerViewHeightConstraint?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailSeparatorView)
        inputContainerView.addSubview(passwordTextField)

        nameTextField.anchor(top: inputContainerView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightConstraint?.isActive = true
        
        nameSeparatorView.anchor(top: nameTextField.bottomAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        emailTextField.anchor(top: nameSeparatorView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightConstraint?.isActive = true
        
        emailSeparatorView.anchor(top: emailTextField.bottomAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        passwordTextField.anchor(top: emailSeparatorView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightConstraint?.isActive = true

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
