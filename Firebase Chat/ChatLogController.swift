//
//  ChatLogController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, Alerter {
    
    private let cellId = "cellId"
    
    private var cellHeight: CGFloat = 80
    private let containerViewHeight: CGFloat = 50
    private let buttonWidth: CGFloat = 80
    private let buttonHeight: CGFloat = 50
    private let inputTextFieldHeight: CGFloat = 50
    private let contentOffset: CGFloat = 8
    private let separatorHeight: CGFloat = 1
    
    private var containerViewBottomConstraint: NSLayoutConstraint?
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
    
    lazy var inputContainerView: UIView = { [weak self] in
        guard let this = self else { return UIView() }
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: this.view.frame.width, height: this.containerViewHeight)
        containerView.backgroundColor = .white
        containerView.addSubview(this.sendButton)
        containerView.addSubview(this.inputTextField)
        containerView.addSubview(this.separatorView)
        
        this.sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: this.buttonWidth, heightConstant: this.buttonHeight)
        this.sendButton.anchorCenterYToSuperview()
        this.inputTextField.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: this.sendButton.leftAnchor, topConstant: 0, leftConstant: this.contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: this.inputTextFieldHeight)
        this.inputTextField.anchorCenterYToSuperview()
        this.separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: this.separatorHeight)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsets(top: contentOffset, left: 0, bottom: contentOffset, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
    }
    
    func observeMessages() {

        DatabaseService.instance.retrieveMultipleObjects(type: .userMessages, fan: true) { (snapshot) in
            
            let messageId = snapshot.key
            
            DatabaseService.instance.retrieveSingleObject(queryString: messageId, type: .message, onComplete: { [weak self] (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                self?.messages.append(message)
                
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            })
        }
    }
    
    func handleSend() {
        if let text = inputTextField.text, let toId = user?.id, let fromId = AuthenticationService.instance.currentId() {
            if text == "" {
                self.present(alertVC(title: "Empty message detected", message: "Please enter something"), animated: true, completion: nil)
                return
            }
            
            let values = ["text": text, "toId": toId, "fromId": fromId, "timestamp": "\(Date().timeIntervalSince1970)"]
        
            DatabaseService.instance.saveData(uid: nil, type: .message, data: values as Dictionary<String, AnyObject>, fan: true) { [weak self] (error, _) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Error saving to database", message: error), animated: true, completion: nil)
                }
                
                this.inputTextField.text = nil
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthConstraint?.constant = estimateFrame(text: text).width + contentOffset * 3
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        guard let urlSting = user?.profileImageUrl else { return }
        cell.profileImageView.loadImageUsingCache(urlString: urlSting)
        
        if message.fromId == AuthenticationService.instance.currentId() {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            
            cell.bubbleRightConstraint?.isActive = true
            cell.bubbleLeftConstraint?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = .rgb(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleRightConstraint?.isActive = false
            cell.bubbleLeftConstraint?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let text = messages[indexPath.item].text {
            cellHeight = estimateFrame(text: text).height + contentOffset * 2
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: cellHeight)
    }
    
    private func estimateFrame(text: String) -> CGRect {
        let size = CGSize(width: ChatMessageCell.cellWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: ChatMessageCell.textViewFontSize)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}
