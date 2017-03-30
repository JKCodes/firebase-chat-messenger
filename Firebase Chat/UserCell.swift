//
//  UserCell.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    private let profileImageLength: CGFloat = 48
    private static let profileImageRadius: CGFloat = 24
    private let contentOffset: CGFloat = 8
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let textLabel = textLabel, let detailTextLabel = detailTextLabel else { return }
        
        textLabel.frame = CGRect(x: 64, y: textLabel.frame.origin.y - 2, width: textLabel.frame.width, height: textLabel.frame.height)
        
        detailTextLabel.frame = CGRect(x: 64, y: detailTextLabel.frame.origin.y + 2, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = UserCell.profileImageRadius
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
        profileImageView.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
