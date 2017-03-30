//
//  BaseCell.swift
//  FacebookMessengerClone
//
//  Created by Joseph Kim on 3/24/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupViews() {
        
    }
    
}
