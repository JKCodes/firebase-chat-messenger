//
//  NewMessageController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController {
    
    private let cellId = "cellId"
    private let cellHeight: CGFloat = 72
    
    var users = [User]()
    
    weak var delegate: NewMessagesDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        
        DatabaseService.instance.retrieveMultipleObjects(type: .user, eventType: .childAdded, fromId: nil, toId: nil, propagate: nil) { [weak self] (snapshot) in
           
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                
                user.setValuesForKeys(dictionary)
                self?.users.append(user)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
                
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
        }

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            if let user = self?.users[indexPath.row] {
                self?.delegate?.showChatController(user: user)
            }
        }
    }
}

extension NewMessageController {
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}








