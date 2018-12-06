//
//  ClubsApi.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import Foundation
import Firebase

struct ClubsApi {
    
    typealias ApiCompletion = ((_ data: Any?, _ error: String?) -> Void)
    
    static func addClub(club: Club?, completion: @escaping ApiCompletion){
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var ref: DocumentReference? = nil
        
        var hasImage: Bool = false
        // check for club image
        if (club?.image) != nil {
            hasImage = true
        }
        
        // Add a new document with a generated ID
        ref = db.collection("clubs").addDocument(data: [
            "name": club?.name ?? NSNull(),
            "details": club?.details ?? NSNull(),
            "image": hasImage
        ]) { err in
            if let err = err {
                completion(nil, "Error adding club: \(err)")
            } else {
                // return club with updated club id as data
                club?.id = ref?.documentID
                
                // add club image to storage
                if let image = club?.image, let id = club?.id{
                    let ref = Storage.storage().reference().child("clubImages").child(id)
                    if let data = image.jpeg(.lowest) {
                        ref.putData(data, metadata: nil) {metadata, err in
                            if let err = err {
                                print(err)
                                completion(nil, "Error adding club: \(err)")
                            } else {
                                completion(club, nil)
                            }
                        }
                    }
                } else {
                    completion(club, nil)
                }
            }
        }
    }
    
    static func updateClub(club: Club?, imageWasDeleted: Bool,
                           imageWasUpdated: Bool, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        guard let id = club?.id else {
            return completion(nil, "Error updating club")
        }
        
        // Upload club data
        let ref = db.collection("clubs").document(id)
        let batch = db.batch()
        
        // Add changes to the batch
        batch.updateData([
            "name": club?.name ?? NSNull()
            ], forDocument: ref)
        
        batch.updateData([
            "details": club?.details ?? NSNull()
            ], forDocument: ref)

        if (club?.image) != nil {
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
                completion(nil, "Error updating club: \(err)")
            } else {
                // Update image
                if let image = club?.image, imageWasUpdated {
                    let ref = Storage.storage().reference().child("clubImages").child(id)
                    if let data = image.jpeg(.lowest) {
                        ref.putData(data, metadata: nil) {metadata, err in
                            if let err = err {
                                print(err)
                                completion(nil, "Error updating club: \(err)")
                            } else {
                                completion(club, nil)
                            }
                        }
                    // If club had an image, but it was deleted
                    } else if imageWasDeleted {
                        let imageRef = Storage.storage().reference().child("clubImages").child(id)
                        imageRef.delete() { err in
                            if let err = err {
                                completion(nil, "Error deleting event image: \(err)")
                            } else {
                                completion(club, nil)
                            }
                        }
                    }
                // No image to delete or update
                } else {
                    completion(club, nil)
                }
            }
        }
    }
    
    static func deleteClub(club: Club?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let ref = db.collection("clubs").document(club?.id ?? "")
        
        // check if club exists, then delete it
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error deleting club: \(err)")
                } else {
                    ref.delete() { err in
                        if let err = err {
                            completion(nil, "Error deleting club: \(err)")
                        } else {
                            // if deleted sucessfully and has an image, delete image too
                            if (document.data()?["image"] as! Bool) {
                                let imageRef = Storage.storage().reference().child("clubImages").child(ref.documentID)
                                imageRef.delete() { err in
                                    if let err = err {
                                        completion(nil, "Error deleting club image: \(err)")
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
                completion(nil, "Error deleting club: does not exits")
            }
        }
    }
    
    static func getClub(id: String, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var club: Club? = nil
        
        let ref = db.collection("clubs").document(id);
        
        ref.getDocument { (document, err) in
            if let document = document, document.exists {
                if let err = err {
                    completion(nil, "Error getting club: \(err)")
                } else {
                    // if club has an image, get the image and create the club
                    if (document.data()?["image"] as? Bool) ?? false {
                        let ref = Storage.storage().reference().child("clubImages").child(id)
                        ref.getData(maxSize: 8192 * 8192) { data, err in
                            switch(data, err){
                            case(.some(let data), nil):
                                let image = UIImage(data: data)
                                
                                // Add club
                                club = Club(id: document.documentID,
                                              name: document.data()?["name"] as? String? ?? nil,
                                              details: document.data()?["details"] as? String? ?? nil,
                                              image: image)
                                // return club as data
                                completion(club, nil)
                            default:
                                //completion(nil, "Error getting club: could not get image")
                                // Add club without image
                                club = Club(id: document.documentID,
                                            name: document.data()?["name"] as? String? ?? nil,
                                            details: document.data()?["details"] as? String? ?? nil,
                                            image: nil)
                                // return club as data
                                completion(club, "Error getting club: could not get image")
                            }
                        }
                        // else club does not have an image, create club without an image
                    } else {
                        // Add club
                        club = Club(id: document.documentID,
                                      name: document.data()?["name"] as? String? ?? nil,
                                      details: document.data()?["details"] as? String? ?? nil,
                                      image: nil)
                        // return club as data
                        completion(club, nil)
                    }
                }
                // Could not get club, document does not exist
            } else {
                completion(nil, "Error getting club: does not exist")
            }
        }
    }
    
    static func getClubsIDs(start: String?, limit: Int?, completion: @escaping ApiCompletion) {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        var clubIDs: [String]? = []
        
        db.collection("clubs").order(by: "name")
            .whereField("name", isGreaterThan: start ?? "A")
            .limit(to: limit ?? 1000)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    completion(nil, "Error getting clubs: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        clubIDs?.append(document.documentID)
                    }
                    completion(clubIDs, nil)
                }
        }
    }
    
}
