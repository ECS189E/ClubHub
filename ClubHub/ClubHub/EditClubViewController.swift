//
//  EditClubViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Firebase

protocol EditClubDelegate {
    func editClubCompleted()
}

class EditClubViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var detailsTextView: UITextView!
    
    var delegate: EditClubDelegate?

    var club:Club?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // if editing an existing club
        if let club = User.currentUser?.club {
            self.club = club
        // Else creating a new club
        } else {
             navigationController?.popViewController(animated: true) 
        }
        viewInit()
    }
    
    func viewInit() {
        
        // format text views
        detailsTextView.isEditable = true
        
        // init date button labels
        nameTextField.text = club?.name
        detailsTextView.text = club?.details
        
        // init club image
        if let image =  club?.image {
            imageView.image = image
            uploadImageButton.setTitle("", for: .normal)
            imageView.isHidden = false
            deleteImageButton.isHidden = false
        } else {
            uploadImageButton.setTitle("Upload Image", for: .normal)
            imageView.isHidden = true
            deleteImageButton.isHidden = true
        }
    }
    
    
    @IBAction func doneTapped(_ sender: Any) {
        // Update club info
        club?.name =
            nameTextField.text?.trimmingCharacters(in: .whitespaces)
        club?.details = detailsTextView.text?.trimmingCharacters(in: .whitespaces)
        
        
        // Require name and start time
        guard let _ = club?.name else{
            print("Error adding club, must provide a name")
            return
        }
        // check for empyt club name
        if club?.name?.trimmingCharacters(in: .whitespaces) == "" {
            print("Error adding club, must provide a name")
            return
        }
        
        // club must have id
        if let _ = club?.id {
            ClubsApi.updateClub(club: club) { data, err in
                switch(data, err) {
                case(.some(_), nil):
                    print("Club updated")
                    self.delegate?.editClubCompleted()
                case(nil, .some(let err)):
                    print(err)
                default:
                    print("Error: could not update club")
                }
                
            }
        }
    }
    
    @IBAction func uploadImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func deleteImageTapped(_ sender: Any) {
        imageView.image = UIImage()
        club?.image = nil
        uploadImageButton.setTitle("Upload Image", for: .normal)
        imageView.isHidden = true
        deleteImageButton.isHidden = true
        
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        UserApi.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "loginViewController") as! LoginViewController
        self.present(viewController, animated: false, completion: nil)
    }
    
}

// Source: https://www.youtube.com/watch?v=krZzC6abaoE
extension EditClubViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.backgroundColor = UIColor.clear
        imageView.isHidden = false
        uploadImageButton.setTitle("", for: .normal)
        club?.image = imageView.image
        deleteImageButton.isHidden = false
        
        self.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
        
    }
}

extension EditClubViewController {
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
