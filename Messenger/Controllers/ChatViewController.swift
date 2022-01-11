//
//  ChatViewController.swift
//  Messenger
//
//  Created by 송경진 on 2022/01/10.
//

import UIKit
import MessageKit
import InputBarAccessoryView


struct Message : MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
    
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return"photo"
        case .video(_):
            return"video"
        case .location(_):
            return"location"
        case  .emoji(_):
            return"emoji"
        case .audio(_):
            return"audio"
        case  .contact(_):
            return"contact"
        case .custom(_):
            return"custom"
        case .linkPreview(_):
            return "link_preview"
        }
    }
}

struct Sender : SenderType{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    
    public let otherUserEmail: String
    public var isNewConversation = false
    
    init(with email: String){
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError("init(corder: ) has not been implemented")
    }
    
    
    
    private var messages = [Message]()
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return Sender(photoURL: " ",
               senderId: email,
               displayName: "정하늬")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
                  return
              }
        print("Sending: \(text)")
        
        //Send Message
        
        if isNewConversation {
            //create convo in database
            let message = Message(sender: selfSender,
                                  messageId:messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.creteNewConversation(with: otherUserEmail,
                                                        name: self.title ?? "User",
                                                        firstMessage: message,
                                                        completion: { success in
                if success {
                    print("message sent")
                }
                
                else{
                    print("failed to send")
                }
                
            })
        }
        else {
            //append to existing conversation data, randomInt
        }
    }
    
    private func createMessageId() -> String? {
        //date, otherUserEmail, senderEmail
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                  return nil
              }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
//        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)"

        print("created message id : \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "123", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
