//
//  UserApi.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/30/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

struct UserApi {
    
    typealias ApiCompletion = ((_ data: Any?, _ error: String?) -> Void)
    
    static func initUserData(type: String?, club: String?, completion: @escaping ApiCompletion) {
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
            "type": type ?? NSNull(),
            "club": club ?? NSNull()
        ]){ err in
            if let err = err {
                completion(nil, "Error adding event: \(err)")
            } else {
                completion(true, nil)
            }
        }
    }
    
    static func setAccountClub(club: String?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // make sure event has an id
        guard let club = club else {
            completion(nil, "Error setting event: no club provided")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error setting event: could not get user data")
            return
        }
        
        let ref = db.collection("users").document(userID)
        ref.updateData(["club" : club])
        { err in
            if let err = err {
                completion(nil, "Error saving event: \(err)")
            } else {
                completion(true, nil)
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

    
    static func getUserData(completion: @escaping ApiCompletion) {
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
                    let events = document.data()?["events"] as? [String]
                    let clubs = document.data()?["clubs"] as? [String]
                    // if user is a club, get club data
                    if document.data()?["type"] as? String == "club", let clubID = document.data()?["club"] as? String {
                        ClubsApi.getClub(id: clubID) { data, err in
                            let user = User(id: userID,
                                            club: data as? Club,
                                            events: events,
                                            clubs: clubs)
                            completion(user, nil)
                        }
                    } else {
                        let user = User(id: userID,
                                        club: nil,
                                        events: events,
                                        clubs: clubs)
                        completion(user, nil)
                    }
                }
            } else {
                completion(nil, "Error getting user data: could not authenticate user")
            }
        }
    }
    
    static func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        User.currentUser = nil
    }
 }
