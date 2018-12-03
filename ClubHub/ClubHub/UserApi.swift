//
//  UserApi.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/30/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import Firebase

struct UserApi {
    
    typealias ApiCompletion = ((_ data: Any?, _ error: String?) -> Void)
    
    static func initUserData(isClub: Bool, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error initializing user data: could not identify user")
            return
        }
        
        // Add a new document with a generated ID
        db.collection("users").document(userID).setData([
            "events": [],
            "clubs": [],
            "isCLub": isClub
        ]){ err in
            if let err = err {
                completion(nil, "Error adding event: \(err)")
            } else {
                completion(true, nil)
            }
        }
    }
    
    static func userIsClub(completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error saving event: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error saving event: \(err)")
                } else {
                    var isClub = document.data()?["isClub"] as! [Bool]
                    completion(isClub, nil)
                }
            }  else {
                completion(nil, "Error checking user status: could not get user data")
            }
        }
    }
    

    static func saveEvent(eventID: String?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // make sure event has an id
        guard let eventID = eventID else {
            completion(nil, "Error saving event: could not identify user")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error saving event: could not get user data")
            return
        }
            
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error saving event: \(err)")
                } else {
                    var userEvents = document.data()?["events"] as! [String]
                    userEvents.append(eventID)
                    
                    // update saved events with new event
                    ref.updateData(["events" : userEvents])
                    { err in
                        if let err = err {
                            completion(nil, "Error saving event: \(err)")
                        } else {
                            completion(userEvents, nil)
                        }
                    }
                }
            } else {
                completion(nil, "Error saving event: could not get user data")
            }
        }
    }
    
    static func deleteSavedEvent(eventID: String?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // make sure event has an id
        guard let eventID = eventID else {
            completion(nil, "Error deleting saved event: could not identify user")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error deleting saved event: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error deleting saved event: \(err)")
                } else {
                    var userEvents = document.data()?["events"] as! [String]
                    userEvents = userEvents.filter{ $0 != eventID }
                    
                    // update saved events with new event
                    ref.updateData(["events" : userEvents])
                    { err in
                        if let err = err {
                            completion(nil, "Error deleting saved event: \(err)")
                        } else {
                            completion(userEvents, nil)
                        }
                    }
                }
            } else {
                completion(nil, "Error deleting saved event: could not get user data")
            }
        }
    }

    static func saveClub(clubID: String?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // make sure club has an id
        guard let clubID = clubID else {
            completion(nil, "Error saving club: could not identify user")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error saving club: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error saving club: \(err)")
                } else {
                    var userClubs = document.data()?["clubs"] as! [String]
                    userClubs.append(clubID)
                    
                    // update saved clubs with new club
                    ref.updateData(["clubs" : userClubs])
                    { err in
                        if let err = err {
                            completion(nil, "Error saving club: \(err)")
                        } else {
                            completion(userClubs, nil)
                        }
                    }
                }
            } else {
                completion(nil, "Error saving club: could not get user data")
            }
        }
    }
    
    static func deleteSavedClub(clubID: String?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // make sure club has an id
        guard let clubID = clubID else {
            completion(nil, "Error deleting saved club: could not identify user")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error deleting saved club: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error deleting saved club: \(err)")
                } else {
                    var userClubs = document.data()?["clubs"] as! [String]
                    userClubs = userClubs.filter{ $0 != clubID }
                    
                    // update saved clubs with new club
                    ref.updateData(["clubs" : userClubs])
                    { err in
                        if let err = err {
                            completion(nil, "Error deleting saved club: \(err)")
                        } else {
                            completion(userClubs, nil)
                        }
                    }
                }
            } else {
                completion(nil, "Error deleting saved club: could not get user data")
            }
        }
    }

    
    static func getUserEvents(completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error deleting saved event: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error getting event: \(err)")
                } else {
                    let events =  document.data()?["events"]
                    completion(events, nil)
                }
            } else {
                completion(nil, "Error getting user events: could not find user data")
            }
        }
    }
    
    static func getUserClubs(completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error deleting saved club: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error getting club: \(err)")
                } else {
                    let clubs =  document.data()?["clubs"]
                    completion(clubs, nil)
                }
            } else {
                completion(nil, "Error getting user clubs: could not find user data")
            }
        }
    }
}
