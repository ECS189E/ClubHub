//
//  EditClubViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Firebase

/// A view controller for adding a new club for a club account
class AddClubViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var detailsTextView: UITextView!
    
    var club:Club = Club()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Club keyboard show/hide notification
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        viewInit()
    }
    
    func viewInit() {
        // Hide activitiy indicator
        activityIndicator.alpha = 0

        // format text views
        detailsTextView.isEditable = true
        
        uploadImageButton.setTitle("Upload Image", for: .normal)
        imageView.isHidden = true
        deleteImageButton.isHidden = true
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        self.resignFirstResponder()
        
        // Update club info
        club.name =
            nameTextField.text?.trimmingCharacters(in: .whitespaces)
        club.details = detailsTextView.text?.trimmingCharacters(in: .whitespaces)
        
        
        // Require name and start time
        guard let _ = club.name else{
            print("Error adding club, must provide a name")
            return
        }
        // check for empyt club name
        if club.name?.trimmingCharacters(in: .whitespaces) == "" {
            print("Error adding club, must provide a name")
            return
        }
        
        // Add new club to database
        ClubsApi.addClub(club: club) {data, err in
            switch(data, err) {
            case(.some(let data), nil):
                self.club.id = (data as! Club).id
                
                // Update the users club in the database
                UserApi.initUserData(type: "club",
                                     clubName: self.club.name,
                                     clubId: self.club.id) { data, err in
                    switch(data, err) {
                    case(.some(_), nil):
                        
                        self.activityIndicator.alpha = 0
                        self.activityIndicator.stopAnimating()
                        
                        User.currentUser = data as? User
                        User.currentUser?.club = self.club
                        
                        // move to main screen once data is loaded
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                        self.present(viewController, animated: true, completion: nil)
                    case(nil, .some(let err)):
                        print(err)
                    default:
                        print("Error: could not add club")
                    }
                }
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error: could not add club")
            }
        }
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
    }
    
    @IBAction func uploadImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func deleteImageTapped(_ sender: Any) {
        imageView.image = UIImage()
        club.image = nil
        uploadImageButton.setTitle("Upload Image", for: .normal)
        imageView.isHidden = true
        deleteImageButton.isHidden = true
        
    }
    
}

// Source: https://www.youtube.com/watch?v=krZzC6abaoE
extension AddClubViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.backgroundColor = UIColor.clear
        imageView.isHidden = false
        uploadImageButton.setTitle("", for: .normal)
        club.image = imageView.image
        deleteImageButton.isHidden = false
        
        self.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
        
    }
}

extension AddClubViewController {
    // Change scroll view bottom contriant when keyboard shown
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Change the scroll views bottom constraint
            scrollViewBottomConstraint.constant =  -keyboardHeight  + 50 + 16
            
            // Change scroll view offset
            scrollView.setContentOffset(
                CGPoint(x: scrollView.contentOffset.x,
                        y:scrollView.contentOffset.y + keyboardHeight/2),
                animated: true)
            
        }
    }
    
    // Restore Scroll View Bottom Contraint when keyboard hides
    @objc func keyboardWillHide(notification: Notification) {
        scrollViewBottomConstraint.constant = -16
    }
}
