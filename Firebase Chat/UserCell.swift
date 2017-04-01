//
//  UserCell.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    fileprivate let profileImageLength: CGFloat = 48
    fileprivate static let profileImageRadius: CGFloat = 24
    fileprivate let timeLabelWidth: CGFloat = 100
    fileprivate let contentOffset: CGFloat = 8
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            
            if let chatPartnerId = message?.toId {
                
                var displayText = ""
                
                if let text = message?.text {
                    displayText = text
                } else if let _ = message?.videoUrl {
                    displayText = "Sent a video"
                } else {
                    displayText = "Sent an image"
                }
                
                detailTextLabel?.text = chatPartnerId == AuthenticationService.instance.currentId() ? displayText : "You: \(displayText)"
                
            }
            
            if let timeStamp = message?.timestamp, let seconds = Double(timeStamp) {
                let timestampeDate = Date(timeIntervalSince1970: seconds)
                let elapsedTimeInSeconds = Date().timeIntervalSince(timestampeDate)
                let secondsInADay: TimeInterval = 60 * 60 * 24
                
                let dateFormatter = DateFormatter()
                
                if elapsedTimeInSeconds > 7 * secondsInADay {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondsInADay {
                    dateFormatter.dateFormat = "EEE"
                } else {
                    dateFormatter.dateFormat = "hh:mm:ss a"
                }
                
                timeLabel.text = dateFormatter.string(from: timestampeDate)
            }
            
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = UserCell.profileImageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
        profileImageView.anchorCenterYToSuperview()
        timeLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: contentOffset * 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: timeLabelWidth, heightConstant: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UserCell {
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            DatabaseService.instance.retrieveSingleObject(queryString: id, type: .user, onComplete: { [weak self] (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self?.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self?.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
                    }
                    
                }
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let textLabel = textLabel, let detailTextLabel = detailTextLabel else { return }
        
        textLabel.frame = CGRect(x: 64, y: textLabel.frame.origin.y - 2, width: textLabel.frame.width, height: textLabel.frame.height)
        
        detailTextLabel.frame = CGRect(x: 64, y: detailTextLabel.frame.origin.y + 2, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
    }
}
