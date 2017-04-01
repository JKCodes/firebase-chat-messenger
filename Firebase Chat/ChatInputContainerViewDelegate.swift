//
//  ChatInputContainerViewDelegate.Swift
//  Firebase Chat
//
//  Created by Joseph Kim on 4/1/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol ChatInputContainerViewDelegate: class {
    func handleSend()
    func handleUploadTap()
}
