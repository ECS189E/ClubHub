//
//  EditEventViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/28/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

protocol EditEventDelegate {
    func editEventCompleted(event: Event?)
    func editEventStarted()
}

class EditEventViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var startDateButon: UIButton!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var delegate: EditEventDelegate?
    
    var event: Event?
    var popUpButton: UIButton? = nil // text field that initiated a pop up view
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        
        // Event keyboard show/hide notification
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func viewInit() {
        guard let userClub = User.currentUser?.club?.name else {
            navigationController?.popViewController(animated: true)
            print("Error updating event: user is not a club")
            return
        }
        
        // format text views
        locationTextView.isEditable = true
        detailsTextView.isEditable = true
        
        // format appearence of dates
        dateFormatter.dateFormat = "EE MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
                
        // if editing an existing event
        if let event = event {
            if event.id  == nil { // must have an id to update
                navigationController?.popViewController(animated: true) 
                print("Error updating event: no id")
            }
            // else create a new event and init dates
        } else {
            // disable delete button for new event
            deleteButton.isEnabled = false
            
            event = Event()
            // initialize date start and end times
            event?.startTime =
                Calendar.current.date(bySettingHour: 12,
                                      minute: 0, second: 0,
                                      of: Date())
            event?.endTime =
                event?.startTime?.addingTimeInterval(60 * 60)
            event?.club = userClub
        }
        
        // init date button labels
        nameTextField.text = event?.name
        startDateButon.setTitle(
            dateFormatter.string(from: event?.startTime ?? Date()), for: .normal)
        endDateButton.setTitle(
            dateFormatter.string(from: event?.endTime ?? Date()), for: .normal)
        startTimeButton.setTitle(
            timeFormatter.string(from: event?.startTime ?? Date()), for: .normal)
        endTimeButton.setTitle(
            timeFormatter.string(from: event?.endTime ?? Date()), for: .normal)
        locationTextView.text = event?.location
        detailsTextView.text = event?.details
        
        // init event image
        if let image =  event?.image {
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
        // Update event info
        event?.name =
            nameTextField.text?.trimmingCharacters(in: .whitespaces)
        event?.details = detailsTextView.text?.trimmingCharacters(in: .whitespaces)
        event?.location =
            locationTextView.text?.trimmingCharacters(in: .whitespaces)
        
        // Require name and start time
        guard let _ = event?.name, let _ = event?.startTime else{
            print("Error adding event, must provide a name and start time")
            return
        }
        // check for empyt event name
        if event?.name?.trimmingCharacters(in: .whitespaces) == "" {
            print("Error adding event, must provide a name")
            return
        }
        
        // if updating an existing event
        if let _ = event?.id {
            EventsApi.updateEvent(event: event) { data, err in
                switch(data, err) {
                case(.some(_), nil):
                    print("Event updated")
                    self.delegate?.editEventCompleted(event: self.event)
                case(nil, .some(let err)):
                    print(err)
                default:
                    print("Error: could not update event")
                }
                
            }
            // else add event
        } else {
            EventsApi.addEvent(event: event) {data, err in
                switch(data, err) {
                case(.some(let data), nil):
                    print("Event Added")
                    self.event?.id = (data as! Event).id
                    
                    // Save the clubs new event to its user account
                    UserApi.saveEvent(eventID: self.event?.id){ data, err in
                        switch(data, err) {
                        case(.some(let data), nil):
                            User.currentUser?.events = data as? [String]
                            self.delegate?.editEventCompleted(event: self.event)
                        case(nil, .some(let err)):
                            print(err)
                            self.delegate?.editEventCompleted(event: nil)
                        default:
                            print("Error: could not update event")
                            self.delegate?.editEventCompleted(event: nil)
                        }
                    }
                case(nil, .some(let err)):
                    print(err)
                default:
                    print("Error: could not add event")
                }
            }
        }
        self.delegate?.editEventStarted()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        EventsApi.deleteEvent(event: event) {data, err in
            switch(data, err) {
            case(.some(_), nil):
                print("Event Deleted")
                
                // Delete the clubs new event from its user account
                UserApi.deleteSavedClub(clubID: self.event?.id){ data, err in
                    switch(data, err) {
                    case(.some(let data), nil):
                        User.currentUser?.events = data as? [String]
                        self.delegate?.editEventCompleted(event: nil)
                    case(nil, .some(let err)):
                        print(err)
                        self.delegate?.editEventCompleted(event: nil)
                    default:
                        print("Error: could not update event")
                        self.delegate?.editEventCompleted(event: nil)
                    }
                }
            case(nil, .some(let err)):
                print(err)
            default:
                print("Error: could not add event")
            }
        }
        self.delegate?.editEventStarted()
    }
    
    @IBAction func uploadImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func deleteImageTapped(_ sender: Any) {
        imageView.image = UIImage()
        event?.image = nil
        uploadImageButton.setTitle("Upload Image", for: .normal)
        imageView.isHidden = true
        deleteImageButton.isHidden = true
        
    }
    @IBAction func startDateTapped(_ sender: Any) {
        // Save button that called pop up to update later
        popUpButton = startDateButon
        
        nameTextField.resignFirstResponder()
        locationTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        
        // Init pop up view controller
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dateTimePopUpViewController") as! DateTimePopUpViewController
        vc.delegate = self
        vc.date = event?.startTime
        vc.pickerMode = UIDatePicker.Mode.date

        self.addChild(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    @IBAction func endDateTapped(_ sender: Any) {
        // Save button that called pop up to update later
        popUpButton = endDateButton
        
        nameTextField.resignFirstResponder()
        locationTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        
        // Init pop up view controller
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dateTimePopUpViewController") as! DateTimePopUpViewController
        vc.delegate = self
        vc.date = event?.endTime
        vc.pickerMode = UIDatePicker.Mode.date
        
        self.addChild(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    @IBAction func startTimeTapped(_ sender: Any) {
        // Save button that called pop up to update later
        popUpButton = startTimeButton
        
        nameTextField.resignFirstResponder()
        locationTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        
        // Init pop up view controller
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dateTimePopUpViewController") as! DateTimePopUpViewController
        vc.delegate = self
        vc.date = event?.startTime
        vc.pickerMode = UIDatePicker.Mode.time
        
        self.addChild(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
    }
    
    @IBAction func endTimeTapped(_ sender: Any) {
        // Save button that called pop up to update later
        popUpButton = endTimeButton
        
        nameTextField.resignFirstResponder()
        locationTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        
        // Init pop up view controller
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dateTimePopUpViewController") as! DateTimePopUpViewController
        
        vc.delegate = self
        vc.date = event?.endTime
        vc.pickerMode = UIDatePicker.Mode.time
        
        self.addChild(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
}

// DateTimePopUpDelegate functions
extension EditEventViewController: DateTimePopUpDelegate {
    
    // if a date was selected by the pop up view, set it and update UI
    func dateSelected(date: Date?) {
        if let popUpButton = popUpButton, let date = date{
            
            // update event and defaults
            switch (popUpButton) {
            case (self.startDateButon):
                self.event?.startTime = date
                // update end date
                self.event?.endTime = date.addingTimeInterval(60 * 60)
            case (self.endDateButton):
                self.event?.endTime = date
            case (self.startTimeButton):
                self.event?.startTime = date
                self.event?.endTime = date.addingTimeInterval(60 * 60)
            case (self.endTimeButton):
                self.event?.endTime = date
            default:
                return
            }
            
            // update date button labels
            if let startTime = event?.startTime {
                startDateButon.setTitle(
                    dateFormatter.string(from: startTime), for: .normal)
                startTimeButton.setTitle(
                    timeFormatter.string(from: startTime), for: .normal)
            }
            if let endTime = event?.endTime {
                endDateButton.setTitle(
                    dateFormatter.string(from: endTime), for: .normal)
                endTimeButton.setTitle(
                    timeFormatter.string(from: endTime), for: .normal)
            }
        }
        popUpButton = nil
    }
}

// Source: https://www.youtube.com/watch?v=krZzC6abaoE
extension EditEventViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image =
            info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.backgroundColor = UIColor.clear
        imageView.isHidden = false
        uploadImageButton.setTitle("", for: .normal)
        event?.image = imageView.image
        deleteImageButton.isHidden = false
        
        self.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
        
    }
}



extension EditEventViewController {
    // Change scroll view bottom contriant when keyboard shown
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            // Change the scroll views bottom constraint
            scrollViewBottomContraint.constant =  -keyboardHeight + 50 + 16
            
            // Change scroll view offset
            scrollView.setContentOffset(
                CGPoint(x: scrollView.contentOffset.x,
                        y:scrollView.contentOffset.y + keyboardHeight),
                animated: true)
        }
    }
    
    // Restore Scroll View Bottom Contraint when keyboard hides
    @objc func keyboardWillHide(notification: Notification) {
        scrollViewBottomContraint.constant = -16
    }
}
