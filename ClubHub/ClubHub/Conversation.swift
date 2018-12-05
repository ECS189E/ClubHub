//
//  Conversation.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Firebase
import Foundation
import UIKit

class Conversation {
    var user: User
    var message: Message
    
    init(user: User, message: Message) {
        self.user = user
        self.message = message
    }
}
