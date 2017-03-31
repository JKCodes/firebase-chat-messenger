//
//  ChatLogController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, UITextFieldDelegate, Alerter {
    
    private let containerViewHeight: CGFloat = 50
    private let buttonWidth: CGFloat = 80
    private let buttonHeight: CGFloat = 50
    private let inputTextFieldHeight: CGFloat = 50
    private let contentOffset: CGFloat = 8
    private let separatorHeight: CGFloat = 1
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var sendButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(this, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    lazy var inputTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Enter message..."
        tf.delegate = this
        return tf
    }()
    
    let separatorView: UIView = {
        let sv = UIView()
        sv.backgroundColor = .rgb(r: 220, g: 220, b: 220)
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        
        setupInputComponents()
    }
    
    func setupInputComponents() {
        
        view.addSubview(containerView)
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextField)
        containerView.addSubview(separatorView)
        
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerViewHeight)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonWidth, heightConstant: buttonHeight)
        sendButton.anchorCenterYToSuperview()
        inputTextField.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: sendButton.leftAnchor, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: inputTextFieldHeight)
        inputTextField.anchorCenterYToSuperview()
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: separatorHeight)
    
    }
    
    func handleSend() {
        if let text = inputTextField.text, let toId = user?.id, let fromId = AuthenticationService.instance.currentId() {
            let values = ["text": text, "toId": toId, "fromId": fromId, "timestamp": "\(Date().timeIntervalSince1970)"]
        
            DatabaseService.instance.saveData(uid: nil, type: .message, data: values as Dictionary<String, AnyObject>) { [weak self] (error, _) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Error saving to database", message: error), animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
