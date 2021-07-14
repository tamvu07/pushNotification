//
//  ChatsViewController.swift
//  pushnotification
//
//  Created by Vu Minh Tam on 7/14/21.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    var sender: SenderType
}

struct Sender: SenderType {
    var senderId: String
    
    var displayName: String
    
    var photURL: String
}

class ChatsViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private let selfSender = Sender(senderId: "1",
                                    displayName: "Joe Smith",
                                    photURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        messages.append(Message(messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello word message"),
                                sender: selfSender))
        
        messages.append(Message(messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello word message 2"),
                                sender: selfSender))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }


}

extension ChatsViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
