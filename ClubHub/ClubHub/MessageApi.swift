//
//  MessageApi.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/5/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Firebase
import Foundation

struct MessageApi {
    
    static func downloadAll(forUserID: String, completion: @escaping (Message) -> Void) {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Database.database()
            db.reference().child("users").child(userID).child("conversations").child(forUserID).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    db.reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let fromID = receivedMessage["fromID"] as! String
                            let type = Message.MessageType.text
                            let content = receivedMessage["content"] as! String
                            let timestamp = receivedMessage["timestamp"] as! Int
                            if fromID == userID {
                                let message = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: true)
                                completion(message)
                            } else {
                                let message = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: true)
                                completion(message)
                            }
                        }
                    })
                }
            })
        }
    }
    
    // Revisit
    static func downloadLast(forLocation: String, completion: @escaping (Message) -> Void) {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Database.database()
            db.reference().child("conversations").child(forLocation).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    for snap in snapshot.children {
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]
                        let fromID = receivedMessage["fromID"] as! String
                        let type = Message.MessageType.text
                        let content = receivedMessage["content"] as! String
                        let timestamp = receivedMessage["timestamp"] as! Int
                        let isRead = receivedMessage["isRead"] as! Bool
                        if fromID == userID {
                            let message = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: isRead)
                            completion(message)
                        } else {
                            let message = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: isRead)
                            completion(message)
                        }
                    }
                }
            })
        }
    }
    
    static func markAsRead(forUserID: String) {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Database.database()
            db.reference().child("users").child(userID).child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    
                    db.reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            for item in snap.children {
                                let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                                let fromID = receivedMessage["fromID"] as! String
                                if fromID != userID {
                                    db.reference().child("conversations").child(location).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    static func upload(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Void) {
        if let userID = Auth.auth().currentUser?.uid {
            let db = Database.database()
            db.reference().child("users").child(userID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    
                    db.reference().child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    db.reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent!.key]
                        db.reference().child("users").child(userID).child("conversations").child(toID).updateChildValues(data as [AnyHashable : Any])
                        db.reference().child("users").child(toID).child("conversations").child(userID).updateChildValues(data as [AnyHashable : Any])
                        completion(true)
                    })
                }
            })
        }
    }
    static func send(message: Message, toID: String, completion: @escaping (Bool) -> Void) {
        if let userID = Auth.auth().currentUser?.uid {
            let values = ["type": "text", "content": message.content, "fromID": userID, "toID": toID, "timestamp": message.timestamp, "isRead": false]
            upload(withValues: values, toID: toID, completion: { (status) in completion(status)})
        }
    }
}
