//
//  MessagesController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class MessagesController: UITableViewController, LoginDelegate, NewMessagesDelegate, Alerter {
    
    private let cellId = "cellId"
    private let contentHeight: CGFloat = 40
    private static let contentRadius: CGFloat = 20
    
    var messages = [Message]()
    
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
        
        observeMessages()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func observeMessages() {
        DatabaseService.instance.retrieveMultipleObjects(type: .message) { [weak self] (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                self?.messages.append(message)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    
    func checkIfUserIsLoggedIn() {
        if AuthenticationService.instance.currentId() == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = AuthenticationService.instance.currentId() else {
            return
        }
        
        DatabaseService.instance.retrieveSingleObject(queryString: uid, type: .user) { [weak self] (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
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
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatController(user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.delegate = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        AuthenticationService.instance.signout { (error, _) in
            if let error = error {
                self.present(alertVC(title: "Error logging out", message: error), animated: true, completion: nil)
                return
            }
        }
        
        let loginController = LoginController()
        loginController.delegate = self
        present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
}

