//
//  ChatLogController.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatMessageDelegate, ChatInputContainerViewDelegate, Alerter {
    
    fileprivate let cellId = "cellId"
    
    fileprivate var cellHeight: CGFloat = 80
    fileprivate let containerViewHeight: CGFloat = 50
    fileprivate let contentOffset: CGFloat = 8
    fileprivate let messageImageWidth: CGFloat = 200
    
    fileprivate var containerViewBottomConstraint: NSLayoutConstraint?
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    fileprivate var startingFrame: CGRect?
    fileprivate var zoomingImageView: UIImageView?
    fileprivate var blackBackgroundView: UIView?
    fileprivate var startImageView: UIImageView?
    
    lazy var inputContainerView: ChatInputContainerView = { [weak self] in
        guard let this = self else { return ChatInputContainerView() }

        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: this.view.frame.width, height: this.containerViewHeight))
        chatInputContainerView.delegate = this
        return chatInputContainerView
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
        
        setupKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    
    func observeMessages() {
        guard let toId = user?.id else { return }
        
        DatabaseService.instance.retrieveMultipleObjects(type: .userMessages, eventType: .childAdded, fromId: nil, toId: toId, propagate: true) { (snapshot) in
           
            let messageId = snapshot.key
            
            DatabaseService.instance.retrieveSingleObject(queryString: messageId, type: .message, onComplete: { [weak self] (snapshot) in
                guard let this = self, let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                this.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: this.messages.count - 1, section: 0)
                    this.collectionView?.reloadData()
                    this.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelected(url: videoUrl)
        } else {
            handleImageSelected(info: info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    
    }
    
    fileprivate func handleVideoSelected(url: URL) {
        let uploadTask = StorageService.instance.uploadToStorageAndReturn(type: .video, data: nil, url: url) { [weak self] (error, metadata) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "Unexpected upload error", message: error), animated: true, completion: nil)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = this.thumbnailImage(fileUrl: url) {
                    
                    this.uploadToFirebaseStorage(image: thumbnailImage, completion: { (imageUrl) in
                    
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject ]
                        this.sendMessage(properties: properties)
                    })
            
                }
            }
        }
        
        uploadTask.observe(.progress) { [weak self] (snapshot) in
            guard let this = self else { return }
            
            if let current = snapshot.progress?.fractionCompleted {
                let percentage = Int(current * 100)
                this.navigationItem.title = "Uploading Video: \(percentage)%"
            }
        }
        
        uploadTask.observe(.success) { [weak self] (snapshot) in
            guard let this = self else { return }
            this.navigationItem.title = this.user?.name
        }

    }
    
    fileprivate func thumbnailImage(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err.localizedDescription)
        }
        
        return nil
    }
    
    fileprivate func handleImageSelected(info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorage(image: selectedImage, completion: { [weak self] (imageUrl) in
                self?.sendMessage(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func uploadToFirebaseStorage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            StorageService.instance.uploadToStorage(type: .profile, data: uploadData, url: nil, onComplete: { [weak self] (error, metadata) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Unexpected upload Error", message: error), animated: true, completion: nil)
                    return
                }
                                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
            })
        }
    }

    fileprivate func setupCell(cell: ChatMessageCell, message: Message) {
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
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCache(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    fileprivate func sendMessage(imageUrl: String, image: UIImage) {
        
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        sendMessage(properties: properties)
    }
    
    fileprivate func sendMessage(properties: [String: AnyObject]) {
        guard let toId = user?.id, let fromId = AuthenticationService.instance.currentId() else { return }
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": "\(Date().timeIntervalSince1970)" as AnyObject]
        
        properties.forEach({values[$0] = $1 })
        
        DatabaseService.instance.saveData(uid: nil, type: .message, data: values as Dictionary<String, AnyObject>, fan: true) { [weak self] (error, _) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "Error saving to database", message: error), animated: true, completion: nil)
            }
            
            this.inputContainerView.inputTextField.text = nil
        }
    }
    
    func performZoomInfoStartingImageView(startingImageView: UIImageView) {
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        guard let startFrame = startingFrame, let keyWindow = UIApplication.shared.keyWindow else { return }
        
        zoomingImageView = UIImageView(frame: startFrame)
        blackBackgroundView = UIView(frame: keyWindow.frame)
        
        guard let zoomView = zoomingImageView else { return }
        guard let backView = blackBackgroundView else { return }
        
        startImageView = startingImageView
        startImageView?.isHidden = true
        
        zoomView.image = startingImageView.image
        zoomView.isUserInteractionEnabled = true
        zoomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        backView.backgroundColor = .black
        backView.alpha = 0
        
        keyWindow.addSubview(backView)
        keyWindow.addSubview(zoomView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            
            backView.alpha = 1
            self?.inputContainerView.alpha = 0
            
            let height = startFrame.height / startFrame.width * keyWindow.frame.width
            
            zoomView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomView.center = keyWindow.center
            }, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.delegate = self
        
        
        let message = messages[indexPath.item]
        
        cell.message = message

        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthConstraint?.constant = estimateFrame(text: text).width + contentOffset * 3
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthConstraint?.constant = messageImageWidth
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            cellHeight = estimateFrame(text: text).height + contentOffset * 2
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            cellHeight = CGFloat(imageHeight / imageWidth) * messageImageWidth
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: cellHeight)
    }
    
    fileprivate func estimateFrame(text: String) -> CGRect {
        let size = CGSize(width: ChatMessageCell.cellWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: ChatMessageCell.textViewFontSize)]
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}

/// Collection of button selector and Tap Gesture selectors
extension ChatLogController {
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    func handleSend() {
        guard let text = inputContainerView.inputTextField.text else { return }
        
        let properties: [String: AnyObject] = ["text": text as AnyObject]
        
        sendMessage(properties: properties)
    }
    
    func handleUploadTap() {
        let imagePickerConroller = UIImagePickerController()
        
        imagePickerConroller.delegate = self
        imagePickerConroller.allowsEditing = true
        imagePickerConroller.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerConroller, animated: true, completion: nil)
    }

    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        guard let startFrame = startingFrame, let zoomOutImageView = zoomingImageView else { return }
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            guard let this = self else { return }
            
            zoomOutImageView.frame = startFrame
            this.blackBackgroundView?.alpha = 0
            this.inputContainerView.alpha = 1
        }) { [weak self] (completed) in
            guard let this = self else { return }
            
            this.startImageView?.isHidden = false
            zoomOutImageView.removeFromSuperview()
            this.blackBackgroundView?.removeFromSuperview()
        }
    }
}
