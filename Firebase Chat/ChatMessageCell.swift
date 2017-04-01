//
//  ChatMessageCell.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    fileprivate let bubbleViewWidth: CGFloat = 200
    internal static let textViewFontSize: CGFloat = 16
    internal static let cellWidth: CGFloat = 200
    internal static let cellHeightMinusContents: CGFloat = 20
    fileprivate let contentOffset: CGFloat = 8
    internal static let blueColor: UIColor = .rgb(r: 0, g: 137, b: 249)
    fileprivate let profileImageLength: CGFloat = 32
    fileprivate static let profileImageRadius: CGFloat = 16
    fileprivate let playButtonLength: CGFloat = 50
    fileprivate let aivLength: CGFloat = 50
    
    internal var bubbleWidthConstraint: NSLayoutConstraint?
    internal var bubbleRightConstraint: NSLayoutConstraint?
    internal var bubbleLeftConstraint: NSLayoutConstraint?
    
    weak var delegate: ChatMessageDelegate?
    
    var message: Message?
    
    fileprivate var player: AVPlayer?
    fileprivate var playerLayer: AVPlayerLayer?
    
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.hidesWhenStopped = true
        return aiv
    }()

    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Temp"
        tv.font = .systemFont(ofSize: ChatMessageCell.textViewFontSize)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = profileImageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = { [weak self] in
        guard let this = self else { return UIImageView() }
        let imageView = UIImageView()
        imageView.layer.cornerRadius = profileImageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: this, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    lazy var playButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = .white
        button.addTarget(this, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
    
        messageImageView.fillSuperview()
        playButton.anchorCenterXYSuperview()
        playButton.widthAnchor.constraint(equalToConstant: playButtonLength).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: playButtonLength).isActive = true
        
        activityIndicatorView.anchorCenterXYSuperview()
        activityIndicatorView.widthAnchor.constraint(equalToConstant: aivLength).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: aivLength).isActive = true

        bubbleRightConstraint = bubbleView.anchorAndReturn(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: 0)[1]
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleLeftConstraint = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: contentOffset)
        
        bubbleWidthConstraint = bubbleView.widthAnchor.constraint(equalToConstant: bubbleViewWidth)
        bubbleWidthConstraint?.isActive = true
        
        textView.anchor(top: topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatMessageCell {
    func handlePlay() {
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            player?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        resetPlayer()
        playButton.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPlayer()
    }
    
    fileprivate func resetPlayer() {
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil { return }
        guard let imageView = tapGesture.view as? UIImageView else { return }
        delegate?.performZoomInfoStartingImageView(startingImageView: imageView)
    }
}
