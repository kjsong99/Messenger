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
    private let conversationId: String?
    public var isNewConversation = false
    
 
    init(with email: String, id: String?){
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrolltoBottom: true)
        }
    }
    
    required init?(coder: NSCoder){
        fatalError("init(corder: ) has not been implemented")
    }
    
    
    
    private var messages = [Message]()
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        
        
        return Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Me")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id: String, shouldScrolltoBottom: Bool){
        print("conversation id : \(id)")
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case . success(let messages):
                print("success in getting messages : \(messages)")
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrolltoBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                  
                }
                
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
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
        let message = Message(sender: selfSender,
                              messageId:messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        if isNewConversation {
            //create convo in database
          
            DatabaseManager.shared.creteNewConversation(with: otherUserEmail,
                                                        name: self.title ?? "User",
                                                        firstMessage: message,
                                                        completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                }
                
                else{
                    print("failed to send")
                }
                
            })
        }
        else {
            guard let conversationId = conversationId,
            let name = self.title else {
                return
            }
            //append to existing conversation data, randomInt
            DatabaseManager.shared.sendMessage(to: conversationId,
                                               otherUserEmail: otherUserEmail,
                                               newMessage: message,
                                               name: name,
                                               completion: { success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
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
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
