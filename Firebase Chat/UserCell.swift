//
//  UserCell.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    private let profileImageLength: CGFloat = 48
    private static let profileImageRadius: CGFloat = 24
    private let timeLabelWidth: CGFloat = 100
    private let contentOffset: CGFloat = 8
    
    var message: Message? {
        didSet {
            if let toId = message?.toId {
                DatabaseService.instance.retrieveSingleObject(queryString: toId, type: .user, onComplete: { [weak self] (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self?.textLabel?.text = dictionary["name"] as? String
                        
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self?.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
                        }
                        
                    }
                })
            }
            
            detailTextLabel?.text = message?.text
            
            if let timeStamp = message?.timestamp, let seconds = Double(timeStamp) {
                let timestampeDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
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
        label.text = "HH:MM:SS"
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let textLabel = textLabel, let detailTextLabel = detailTextLabel else { return }
        
        textLabel.frame = CGRect(x: 64, y: textLabel.frame.origin.y - 2, width: textLabel.frame.width, height: textLabel.frame.height)
        
        detailTextLabel.frame = CGRect(x: 64, y: detailTextLabel.frame.origin.y + 2, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
