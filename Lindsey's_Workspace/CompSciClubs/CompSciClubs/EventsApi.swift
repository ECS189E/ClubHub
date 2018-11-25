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
        
        // Add a new document with a generated ID
        ref = db.collection("Events").addDocument(data: [
            "name": event?.name ?? NSNull(),
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
                
                // add event image to storage
                if let image = event?.mainImage, let id = event?.id{
                    let ref = Storage.storage().reference().child("images").child(id)
                    if let data = image.pngData() {
                        ref.putData(data, metadata: nil) {metadata, err in
                            if let err = err {
                                print(err)
                                completion(nil, "Error adding event: \(err)")
                            } else {
                                completion(event, nil)
                            }
                        }
                    }
                } else {
                    completion(event, nil)
                }
            }
        }
    }

    static func updateEvent(event: Event?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let id = event?.id else {
            return completion(nil, "Error updating event")
        }
        
        // Upload event data
        let ref = db.collection("Events").document(id)
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
                completion(nil, "Error updating event: \(err)")
            } else {
                // Store image
                if let image = event?.mainImage{
                    let ref = Storage.storage().reference().child("images").child(id)
                    if let data = image.pngData() {
                        ref.putData(data, metadata: nil) {metadata, err in
                            if let err = err {
                                print(err)
                                completion(nil, "Error updating event: \(err)")
                            } else {
                               completion(event, nil)
                            }
                        }
                    }
                } else {
                    completion(event, nil)
                }
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
                        }
                        
                    } // delete event image to storage  FIXME: do together?
                    let imageRef = Storage.storage().reference().child("images").child(id)
                    imageRef.delete() { err in
                        if let err = err {
                            completion(nil, "Error deleting event image: \(err)")
                        }
                    }
                    completion(true, nil)
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
                    let ref = Storage.storage().reference().child("images").child(id)
                    ref.getData(maxSize: 8192 * 8192) { data, err in
                        switch(data, err){
                        case(.some(let data), nil):
                            let image = UIImage(data: data)
                            
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
                                          details: document.data()?["details"] as? String? ?? nil,
                                          mainImage: image)
                            // return event as data
                            completion(event, nil)
                            
                        case(nil, .some(_)):
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
                                          details: document.data()?["details"] as? String? ?? nil,
                                          mainImage: nil)
                            // return event as data
                            completion(event, nil)
                        default:
                            completion(nil, "Error getting event")
                        }
                    }
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
                    let ref = Storage.storage().reference().child("images").child(document.documentID)
                    ref.getData(maxSize: 8192 * 8192) { data, err in
                        switch(data, err){
                        case(.some(let data), nil):
                            let image = UIImage(data: data)
                            
                            // Get start time from timestamp
                            let startTime: Date? = (document.data()["startTime"] as! Timestamp).dateValue()
                            // Get end time from timestamp
                            let endTime: Date? = (document.data()["endTime"] as! Timestamp).dateValue()
                            
                            // Add event with image
                            events?.append (Event(id: document.documentID,
                                           name: document.data()["name"] as? String? ?? nil,
                                          startTime: startTime,
                                          endTime: endTime,
                                          location: document.data()["location"] as? String? ?? nil,
                                          club: document.data()["club"] as? String? ?? nil,
                                          details: document.data()["details"] as? String? ?? nil,
                                          mainImage: image))
                        case(nil, .some(_)):
                            // Get start time from timestamp
                            let startTime: Date? = (document.data()["startTime"] as! Timestamp).dateValue()
                            // Get end time from timestamp
                            let endTime: Date? = (document.data()["endTime"] as! Timestamp).dateValue()
                            
                            // Add event without image
                            events?.append (Event(id: document.documentID,
                                           name: document.data()["name"] as? String? ?? nil,
                                          startTime: startTime,
                                          endTime: endTime,
                                          location: document.data()["location"] as? String? ?? nil,
                                          club: document.data()["club"] as? String? ?? nil,
                                          details: document.data()["details"] as? String? ?? nil,
                                          mainImage: nil))
                        default:
                            completion(nil, "Error getting event")
                        } // switch
                    completion(events, nil)
                    } // closure
                } // for
            } // else no err
        } // getDocuments
    }
    
}


/* Firebase warnings
 // old:
 let date: Date = documentSnapshot.get("created_at") as! Date
 // new:
 let timestamp: Timestamp = documentSnapshot.get("created_at") as! Timestamp
 let date: Date = timestamp.dateValue()
 */
