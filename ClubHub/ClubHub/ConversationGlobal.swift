//
//  ConversationGlobal.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/6/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import UIKit

// Global variables for conversations
struct GlobalVariables {
    static let blue = UIColor.rbg(r: 20, g: 84, b: 147)
}

extension UIColor{
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
}

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
}

enum MessageType {
    case photo
    case text
}

enum MessageOwner {
    case sender
    case receiver
}
