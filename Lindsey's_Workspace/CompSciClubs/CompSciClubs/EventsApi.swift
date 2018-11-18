//
//  Api.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/12/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import Firebase

struct EventsApi {
    
    typealias ApiCompletion = ((_ data: Any?, _ error: String?) -> Void)

    static func addEvent(event: Event?, completion: @escaping ApiCompletion){
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var ref: DocumentReference? = nil
    
        // Check if name is set (must have name)
        if let name = event?.name {
            
            // Add a new document with a generated ID
            ref = db.collection("Events").addDocument(data: [
                "name": name,
                "startTime": event?.startTime ?? NSNull(),
                "endTime": event?.endTime ?? NSNull(),
                "location": event?.location ?? NSNull(),
                "club": event?.club ?? NSNull(),
                "details": event?.details ?? NSNull()
            ]) { err in
                if let err = err {
                    completion(nil, "Error adding event: \(err)")
                } else {
                    // return event with updated event id as data
                    event?.id = ref?.documentID
                    completion(event, nil)
                }
            }
        } else {
            completion(nil, "Error adding event")
        }
    }

    static func updateEvent(event: Event?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        // FIXME: check if document exists
        
        let ref = db.collection("Events").document(event?.id ?? "")
        let batch = db.batch()
        
        // Add changes to the batch
        if let name = event?.name {
        batch.updateData([
            "name": name
            ], forDocument: ref)
        }
        if let startTime = event?.startTime {
        batch.updateData([
            "startTime": startTime
            ], forDocument: ref)
        }
        if let endTime = event?.endTime {
        batch.updateData([
            "endTime": endTime
            ], forDocument: ref)
        }
        if let location = event?.location {
        batch.updateData([
            "location": location
            ], forDocument: ref)
        }
        if let club = event?.club {
        batch.updateData([
            "club": club
            ], forDocument: ref)
        }
        if let details = event?.details {
        batch.updateData([
            "details": details
            ], forDocument: ref)
        }
        
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                completion(nil, "Error adding event: \(err)")
            } else {
                // return event as data
                completion(event, nil)
            }
        }
    }
    
    static func deleteEvent(id: String, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let ref = db.collection("Events").document(id)
        
        // check if event exists, then delete it
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error deleting event: \(err)")
                } else {
                    ref.delete() { err in
                        if let err = err {
                            completion(nil, "Error deleting event: \(err)")
                        } else {
                            // Return deletion status
                            completion(true, nil)
                        }
                    }
                }
            } else {
                completion(nil, "Error deleting event: does not exits")
            }
        }
    }
    
    static func getEvent(id: String, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var event: Event? = nil
        let ref = db.collection("Events").document(id);
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error getting event: \(err)")
                } else {
                    // Get start time from timestamp
                    let startTime: Date? = (document.data()?["startTime"] as! Timestamp).dateValue()
                    // Get end time from timestamp
                    let endTime: Date? = (document.data()?["endTime"] as! Timestamp).dateValue()
                    
                    // Add event
                    event = Event(id: document.documentID,
                                  name: document.data()?["name"] as? String? ?? nil,
                                  startTime: startTime,
                                  endTime: endTime,
                                  location: document.data()?["location"] as? String? ?? nil,
                                  club: document.data()?["club"] as? String? ?? nil,
                                  details: document.data()?["details"] as? String? ?? nil)
                    // return event as data
                    completion(event, nil)
                }
            } else {
                completion(nil, "Error getting event: does not exist")
            }
        }
    }
    
    static func getEvents(completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var events: [Event]? = []
        
        db.collection("Events").getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(nil, "Error getting events: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // Get start time from timestamp
                    let startTime: Date? = (document.data()["startTime"] as! Timestamp).dateValue()
                    // Get end time from timestamp
                    let endTime: Date? = (document.data()["endTime"] as! Timestamp).dateValue()
                    
                    // Add event
                    events?.append (Event(id: document.documentID,
                                    name: document.data()["name"] as? String? ?? nil,
                                    startTime: startTime,
                                    endTime: endTime,
                                    location: document.data()["location"] as? String? ?? nil,
                                    club: document.data()["club"] as? String? ?? nil,
                                    details: document.data()["details"] as? String? ?? nil)
                }
                // return event as data
                completion(events, nil)
            }
        }
    }
}


/* Firebase warnings
 // old:
 let date: Date = documentSnapshot.get("created_at") as! Date
 // new:
 let timestamp: Timestamp = documentSnapshot.get("created_at") as! Timestamp
 let date: Date = timestamp.dateValue()
 */
