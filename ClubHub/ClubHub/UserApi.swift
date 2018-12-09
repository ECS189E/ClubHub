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

// A struct containing all the functions relating to a particular user's account
struct UserApi {
    
    typealias ApiCompletion = ((_ data: Any?, _ error: String?) -> Void)
    
    static func initUserData(type: String?, clubName: String?, clubId: String?,
                             completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil, "Error initializing user data: could not identify user")
            return
        }
        
        // init user saved clubs list
        var userClubs: [String] = []
        if let clubId = clubId {
            userClubs = [clubId]
        }
        
        // init user data for messaging
        var name = Auth.auth().currentUser?.displayName
        if let clubName = clubName {
            name = clubName
        }
        let email = Auth.auth().currentUser?.email
        let values = ["name": name, "email": email]
        Database.database().reference()
            .child("users").child(userID).child("credentials")
            .updateChildValues(values as [AnyHashable : Any],
                               withCompletionBlock: { (err, _) in
            if err == nil {
                let profile = Profile(name: name!,
                                      email: email!,
                                      id: userID,
                                      profilePic:
                    UIImage(named: "default profile")!)
                completion(profile, nil)
            } else {
                completion(nil, "Error adding profile credentials")
            }
        })
        
        // Add a new document with a generated ID
        db.collection("users").document(userID).setData([
            "events": [],
            "clubs": userClubs,
            "type": type ?? NSNull(),
            "club": clubId ?? NSNull()
        ]){ err in
            if let err = err {
                completion(nil, "Error adding event: \(err)")
            } else {
                let user = User(id: userID, club: nil, events: [], clubs: userClubs)
                completion(user, nil)
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
            completion(nil, "Error getting user data: could not identify user")
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
                    if document.data()?["type"] as? String == "club",
                        let clubID = document.data()?["club"] as? String {
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
    
    static func deleteUser(completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        Database.database().reference()
            .child("users").child(User.currentUser?.id ?? "")
            .removeValue()
        let ref = db.collection("users").document(User.currentUser?.id ?? "")
        // check if club exists, then delete it
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error deleting user: \(err)")
                } else {
                    ref.delete() { err in
                        if let err = err {
                            completion(nil, "Error deleting user: \(err)")
                        } else {
                            
                            // if user is a club account, delete club
                            if let club = User.currentUser?.club{
                                ClubsApi.deleteClub(club: club) { data, err in
                                    switch(data, err) {
                                    case(.some(_), nil):
                                        completion(true, nil)
                                    case(nil, .some(let err)):
                                        completion(nil, "Error deleting user's club: \(err)")
                                    default:
                                        completion(nil, "Error deleting user's club")
                                    }
                                }
                            } else {
                                completion(true, nil)
                            }
                        }
                    }
                }
                
            } else {
                completion(nil, "Error deleting user: does not exits")
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
