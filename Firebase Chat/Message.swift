//
//  Message.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var text: String?
    var fromId: String?
    var toId: String?
    var timestamp: String?
    
    func chatPartnerId() -> String? {
        return fromId == AuthenticationService.instance.currentId() ? toId : fromId
    }
}
