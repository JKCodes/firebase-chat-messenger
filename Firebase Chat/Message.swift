//
//  Message.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var timestamp: String?

    var text: String?
    var imageUrl: String?
    
    func chatPartnerId() -> String? {
        return fromId == AuthenticationService.instance.currentId() ? toId : fromId
    }
}
