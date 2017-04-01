//
//  Alerter.swift
//  Firebase Chat
//
//  Created by Joseph Kim on 3/31/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol Alerter {}

extension Alerter {
    func alertVC(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
}
