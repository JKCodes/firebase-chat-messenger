//
//  ChatMessageCell.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    private let bubbleViewWidth: CGFloat = 200
    
    internal static let textViewFontSize: CGFloat = 16
    internal static let cellWidth: CGFloat = 200
    internal static let cellHeightMinusContents: CGFloat = 20
    private let contentOffset: CGFloat = 8
    internal var bubbleWidthConstraint: NSLayoutConstraint?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Temp"
        tv.font = .systemFont(ofSize: ChatMessageCell.textViewFontSize)
        tv.backgroundColor = .clear
        tv.textColor = .white
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 0, g: 137, b: 249)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        
        bubbleView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: 0)
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleWidthConstraint = bubbleView.widthAnchor.constraint(equalToConstant: bubbleViewWidth)
        bubbleWidthConstraint?.isActive = true
        
        textView.anchor(top: topAnchor, left: bubbleView.leftAnchor, bottom: nil, right: bubbleView.rightAnchor, topConstant: 0, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
