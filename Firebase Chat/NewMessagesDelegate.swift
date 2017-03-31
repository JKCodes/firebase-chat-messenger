//
//  NewMessagesDelegate.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol NewMessagesDelegate: class {
    func showChatController(user: User)
}
