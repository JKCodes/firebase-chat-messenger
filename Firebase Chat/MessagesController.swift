//
//  MessagesController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class MessagesController: UITableViewController, LoginDelegate, NewMessagesDelegate, Alerter {
    
    fileprivate let cellId = "cellId"
    fileprivate let contentHeight: CGFloat = 40
    fileprivate static let contentRadius: CGFloat = 20
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
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
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func observeUserMessages() {
        
        DatabaseService.instance.retrieveMultipleObjects(type: .userMessages, eventType: .childAdded, fromId: nil, toId: nil, propagate: true) { [weak self] (snapshot) in
            
            let messageId = snapshot.key
            
            self?.fetchMessage(messageId: messageId)
            self?.attemptReloadOfTable()
        }
        
        DatabaseService.instance.retrieveMultipleObjects(type: .userMessages, eventType: .childRemoved, fromId: nil, toId: nil, propagate: false) { [weak self] (snapshot) in
            
            self?.messagesDictionary.removeValue(forKey: snapshot.key)
            self?.attemptReloadOfTable()
        }
    }
    
    fileprivate func fetchMessage(messageId: String) {
        DatabaseService.instance.retrieveSingleObject(queryString: messageId, type: .message, onComplete: { [weak self] (snapshot) in
            guard let this = self else { return }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    this.messagesDictionary[chatPartnerId] = message
                }
                
                self?.attemptReloadOfTable()
            }
        })
    }
    
    fileprivate func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
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
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()

        
        navigationItem.title = user.name
        
        navigationItem.titleView = titleView
        
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
        
    }
    
    func showChatController(user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let uid = AuthenticationService.instance.currentId(), let toId = message.chatPartnerId() else { return }
        
        DatabaseService.instance.removeMultipleObjects(type: .userMessages, fromId: uid, toId: toId) { [weak self] (error, _) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "Deletion request failed", message: error), animated: true, completion: nil)
                return
            }
            
            self?.messagesDictionary.removeValue(forKey: toId)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        DatabaseService.instance.retrieveSingleObject(queryString: chatPartnerId, type: .user) { [weak self] (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self?.showChatController(user: user)
        }
    }
}

extension MessagesController {
    
    func handleReloadTable() {
        messages = Array(messagesDictionary.values)
        messages.sort { (message1, message2) -> Bool in
            guard let m1 = message1.timestamp, let m2 = message2.timestamp, let time1 = Double(m1), let time2 = Double(m2) else { return true }
            
            return Int(time1) > Int(time2)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.delegate = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        AuthenticationService.instance.signout { [weak self] (error, _) in
            guard let this = self else { return }
            if let error = error {
                this.present(this.alertVC(title: "Error logging out", message: error), animated: true, completion: nil)
                return
            }
        }
        
        let loginController = LoginController()
        loginController.delegate = self
        present(loginController, animated: true, completion: nil)
    }
}

