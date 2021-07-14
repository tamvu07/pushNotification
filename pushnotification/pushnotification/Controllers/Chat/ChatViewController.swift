//
//  ChatViewController.swift
//  pushnotification
//
//  Created by Vu Minh Tam on 7/12/21.
//

import UIKit

class ChatViewController: UIViewController {

    var message: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 200, height: 21))
          label.text = message
          self.view.addSubview(label)
    }
}
