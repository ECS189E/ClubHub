//
//  EventsApi.swift
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
        
        var hasImage: Bool = false
        // check for event image
        if (event?.image) != nil {
            hasImage = true
        }

        // Add a new document with a generated ID
        ref = db.collection("events").addDocument(data: [
            "name": event?.name ?? NSNull(),
            "startTime": event?.startTime ?? NSNull(),
            "endTime": event?.endTime ?? NSNull(),
            "location": event?.location ?? NSNull(),
            "club": event?.club ?? NSNull(),
            "details": event?.details ?? NSNull(),
            "image": hasImage
        ]) { err in
            if let err = err {
                completion(nil, "Error adding event: \(err)")
            } else {
                // return event with updated event id as data
                event?.id = ref?.documentID
                
                // add event image to storage
                if let image = event?.image, let id = event?.id{
                    let ref = Storage.storage().reference().child("eventImages").child(id)
                    if let data = image.jpeg(.lowest) {
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

    static func updateEvent(event: Event?, imageWasDeleted: Bool,
                            imageWasUpdated: Bool, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let id = event?.id else {
            return completion(nil, "Error updating event")
        }
        
        // Upload event data
        let ref = db.collection("events").document(id)
        let batch = db.batch()
        
        
        batch.updateData([
            "name": event?.name ?? NSNull()
            ], forDocument: ref)
        
        batch.updateData([
            "startTime": event?.startTime ?? NSNull()
            ], forDocument: ref)

        
        batch.updateData([
            "endTime": event?.endTime ?? NSNull()
            ], forDocument: ref)


        batch.updateData([
            "location": event?.location ?? NSNull()
            ], forDocument: ref)


        batch.updateData([
            "club": event?.club ?? NSNull()
            ], forDocument: ref)


        batch.updateData([
            "details": event?.details ?? NSNull()
            ], forDocument: ref)

        if (event?.image) != nil {
            batch.updateData([
                "image": true
                ], forDocument: ref)
        } else {
            batch.updateData([
                "image": false
                ], forDocument: ref)
        }
        
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                completion(nil, "Error updating event: \(err)")
            } else {
                // Update image
                if let image = event?.image{
                    let ref = Storage.storage().reference().child("eventImages").child(id)
                    if let data = image.jpeg(.lowest) {
                        ref.putData(data, metadata: nil) {metadata, err in
                            if let err = err {
                                print(err)
                                completion(nil, "Error updating event: \(err)")
                            } else {
                               completion(event, nil)
                            }
                        }
                    }
                // If event had an image, but it was deleted
                } else if imageWasDeleted {
                    let imageRef = Storage.storage().reference().child("eventImages").child(id)
                    imageRef.delete() { err in
                        if let err = err {
                            completion(nil, "Error deleting event image: \(err)")
                        } else {
                            completion(event, nil)
                        }
                    }
                // No image to delete or update
                }else {
                    completion(event, nil)
                }
            }
        }
    }
    
    static func deleteEvent(event: Event?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let ref = db.collection("events").document(event?.id ?? "")
        
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
                            // if deleted sucessfully and has an image, delete image too
                            if (document.data()?["image"] as! Bool) {
                                let imageRef = Storage.storage().reference().child("eventImages").child(ref.documentID)
                                imageRef.delete() { err in
                                    if let err = err {
                                        completion(nil, "Error deleting event image: \(err)")
                                    } else {
                                        completion(true, nil)
                                    }
                                }
                            } else {
                                completion(true, nil)
                            }
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
        
        let ref = db.collection("events").document(id);
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error getting event: \(err)")
                } else {
                    // Get start time from timestamp
                    let startTime: Date? =
                        (document.data()?["startTime"] as! Timestamp).dateValue()
                    // Get end time from timestamp
                    let endTime: Date? = (
                        document.data()?["endTime"] as! Timestamp).dateValue()
                    
                    // if event has an image, get the image and create the event
                    if (document.data()?["image"] as? Bool) ?? false {
                        let ref = Storage.storage().reference().child("eventImages").child(id)
                        ref.getData(maxSize: 8192 * 8192) { data, err in
                            switch(data, err){
                            case(.some(let data), nil):
                                let image = UIImage(data: data)

                                // Add event
                                event = Event(id: document.documentID,
                                              name: document.data()?["name"] as? String? ?? nil,
                                              startTime: startTime,
                                              endTime: endTime,
                                              location: document.data()?["location"] as? String? ?? nil,
                                              club: document.data()?["club"] as? String? ?? nil,
                                              details: document.data()?["details"] as? String? ?? nil,
                                              image: image)
                                // return event as data
                                completion(event, nil)
                            default:
                                completion(nil, "Error getting event: could not get image")
                            }
                        }
                    // else event does not have an image, create event without an image
                    } else {
                        // Add event
                        event = Event(id: document.documentID,
                                      name: document.data()?["name"] as? String? ?? nil,
                                      startTime: startTime,
                                      endTime: endTime,
                                      location: document.data()?["location"] as? String? ?? nil,
                                      club: document.data()?["club"] as? String? ?? nil,
                                      details: document.data()?["details"] as? String? ?? nil,
                                      image: nil)
                        // return event as data
                        completion(event, nil)
                    }
                }
            // Could not get event, document does not exist
            } else {
                completion(nil, "Error getting event: does not exist")
            }
        }
    }
    
    static func getEventsIDs(startDate: Date?, limit: Int?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var eventIDs: [String]? = []
        
        db.collection("events").order(by: "startTime")
                               .whereField("startTime", isGreaterThan: startDate ?? Date())
                               .limit(to: limit ?? 1000)
                               .getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(nil, "Error getting events: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    eventIDs?.append(document.documentID)
                }
                completion(eventIDs, nil)
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
