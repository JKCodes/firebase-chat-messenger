//
//  MessagesController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController, LoginDelegate {
    
    private let contentHeight: CGFloat = 40
    private static let contentRadius: CGFloat = 20
    
    let titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = MessagesController.contentRadius
        iv.clipsToBounds = true
        return iv
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        DatabaseService.instance.retrieveUser(uid: uid) { [weak self] (_, dict) in
            if let dictionary = dict as? [String: AnyObject] {
                self?.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self?.setupNavBarWithUser(user: user)
            }
        }
    }
    
    func setupNavBarWithUser(user: User) {
        navigationItem.title = user.name
        
        // Width for titleView is arbitrary, and it does not matter
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: contentHeight)
       
        titleView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)

        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCache(urlString: profileImageUrl)
        }

        nameLabel.text = user.name

        containerView.anchorCenterXYSuperview()
        profileImageView.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: contentHeight, heightConstant: contentHeight)
        profileImageView.anchorCenterYToSuperview()
        nameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: contentHeight)
        nameLabel.anchorCenterYToSuperview()
        
        navigationItem.titleView = titleView
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        AuthenticationService.instance.signout { (error, _) in
            if error != nil {
                displayAlert(title: "Error logging out", message: error!)
                return
            }
        }
        
        let loginController = LoginController()
        loginController.delegate = self
        present(loginController, animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

