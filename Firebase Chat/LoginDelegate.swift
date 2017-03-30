//
//  LoginDelegate.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/30/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol LoginDelegate: class {
    func fetchUserAndSetupNavBarTitle()
    func setupNavBarWithUser(user: User)
}
