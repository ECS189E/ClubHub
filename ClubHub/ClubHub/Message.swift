//
//  Message.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class Message {
    enum MessageOwner {
        case sender
        case receiver
    }
    
    var type: String
    var content: Any
    var owner: MessageOwner
    var timestamp: Int
    var isRead: Bool
    
    init(type: String, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
