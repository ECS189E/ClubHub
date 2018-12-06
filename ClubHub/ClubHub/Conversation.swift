//
//  Conversation.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

class Conversation {
    var profile: Profile
    var message: Message
    
    init(profile: Profile, message: Message) {
        self.profile = profile
        self.message = message
    }
}
