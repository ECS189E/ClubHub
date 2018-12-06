//
//  ConversationApi.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Firebase
import Foundation

struct ConversationApi {
    static func showAll(completion: @escaping ([Conversation]) -> Void) {
        if let userID = Auth.auth().currentUser?.uid {
            var conversations = [Conversation]()
            Database.database().reference().child("users").child(userID).child("conversations").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    let fromID = snapshot.key
                    let values = snapshot.value as! [String: String]
                    let location = values["location"]!
                    ProfileApi.info(forUserID: fromID, completion: { profile, err in
                        let emptyMessage = Message.init(type: .text, content: "loading", owner: .sender, timestamp: 0, isRead: true)
                        let conversation = Conversation.init(profile: profile as! Profile, message: emptyMessage)
                        conversations.append(conversation)
                        MessageApi.downloadLast(forLocation: location, completion: {_ in
                            completion(conversations)
                        })
                    })
                }
            })
        }
    }
}
