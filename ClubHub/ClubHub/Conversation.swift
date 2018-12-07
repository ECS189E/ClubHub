//
//  Conversation.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/6/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Conversation {
    
    //MARK: Properties
    let user: Profile
    var lastMessage: Message
    
    //MARK: Methods
    class func showConversations(completion: @escaping ([Conversation]) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            var conversations = [Conversation]()
            Database.database().reference().child("users").child(currentUserID).child("conversations").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    let fromID = snapshot.key
                    let values = snapshot.value as! [String: String]
                    let location = values["location"]!
                    Profile.info(forUserID: fromID, completion: { (user) in
                        let emptyMessage = Message.init(type: .text, content: "loading", owner: .sender, timestamp: 0, isRead: true)
                        let conversation = Conversation.init(user: user, lastMessage: emptyMessage)
                        conversations.append(conversation)
                        conversation.lastMessage.downloadLastMessage(forLocation: location, completion: {
                            completion(conversations)
                        })
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(user: Profile, lastMessage: Message) {
        self.user = user
        self.lastMessage = lastMessage
    }
}
