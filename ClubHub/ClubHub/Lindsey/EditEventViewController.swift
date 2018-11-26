//
//  EditEventViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/11/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
// View Controller Used for editing events or adding new ones

import UIKit
import Firebase

protocol EditEventDelegate {
    func editEventCompleted()
}

class EditEventViewController: UITableViewController,  UINavigationControllerDelegate{

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var detailsTextView: UITextView!
    
    var delegate: EditEventDelegate?
    
    var event:Event?
    var popUpTextField: UITextField? = nil // text field that initiated a pop up view
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDateTextField.delegate = self
        startTimeTextField.delegate = self
        endDateTextField.delegate = self
        endTimeTextField.delegate = self
        
        viewInit()
    }
    
    
    func viewInit() {
        tableView.keyboardDismissMode = .onDrag
        
        // format text views
        locationTextView.isEditable = true
        detailsTextView.isEditable = true
        
        
        // format appearence of dates
        dateFormatter.dateFormat = "EE MMM dd, yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        
        // if editing an existing event
        if let event = event {
            if event.id  == nil { // must have an id to update
                navigationController?.popViewController(animated: true)  //FIXME: move to view will appear?
                print("Error updating event: no id")
            }
        // else create a new event and init dates
        } else {
            event = Event()
            // initialize date start and end times
            event?.startTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
            event?.endTime = event?.startTime?.addingTimeInterval(60 * 60)
        }
        
        // init text fields
        nameTextField.text = event?.name
        startDateTextField.text = dateFormatter.string(from: event?.startTime ?? Date())
        endDateTextField.text = dateFormatter.string(from: event?.endTime ?? Date())
        startTimeTextField.text = timeFormatter.string(from: event?.startTime ?? Date())
        endTimeTextField.text = timeFormatter.string(from: event?.endTime ?? Date())
        locationTextView.text = event?.location
        detailsTextView.text = event?.details

        // init event image
        if let image =  event?.mainImage {
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
        event?.location = locationTextView.text?.trimmingCharacters(in: .whitespaces)
        
        // Require name and start time
        guard let _ = event?.name, let _ = event?.startTime else{
            print("Error adding event, must provide a name and start time")
            return
        }
        
        // if updating an existing event
        if let _ = event?.id {
            EventsApi.updateEvent(event: event) { data, err in
                switch(data, err) {
                    case(.some(_), nil):
                        print("Event updated")
                        self.delegate?.editEventCompleted()
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
                    self.delegate?.editEventCompleted()
                case(nil, .some(let err)):
                    print(err)
                default:
                    print("Error: could not add event")
                }
            }
        }
        event?.printEvent()
    }
    
    @IBAction func uploadImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func deleteImageTapped(_ sender: Any) {
        imageView.image = UIImage()
        event?.mainImage = nil
        uploadImageButton.setTitle("Upload Image", for: .normal)
        imageView.isHidden = true
        deleteImageButton.isHidden = true
        
    }
    
}


// UITextFieldDelegate functions
extension EditEventViewController {
    
    // Istantiates date/time pop up view if certain text fields are edited
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Call pop up date/time picker
        if textField == startDateTextField || textField == endDateTextField || textField == startTimeTextField || textField == endTimeTextField {
            textField.resignFirstResponder()
            
            // Save text field that called pop up to update later
            popUpTextField = textField
            
            // Init pop up view controller
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dateTimePopUpViewController") as! DateTimePopUpViewController
            vc.delegate = self
            
            // send date to pop up view
            if textField == startDateTextField || textField == startTimeTextField {
                vc.date = event?.startTime
            } else {
               vc.date = event?.endTime
            }
            
            // Set picker mode
            if textField == startDateTextField || textField == endDateTextField {
                vc.pickerMode = UIDatePicker.Mode.date
            } else {
                vc.pickerMode = UIDatePicker.Mode.time
            }
            
            self.addChild(vc)
            vc.view.frame = self.view.frame
            self.view.addSubview(vc.view)
            vc.didMove(toParent: self)
            
        } else {
            popUpTextField = nil
        }
        
    }
}

// DateTimePopUpDelegate functions
extension EditEventViewController: DateTimePopUpDelegate {
    
    // if a date was selected by the pop up view, set it and update UI
    func dateSelected(date: Date?) {
        if let popUpTextField = popUpTextField, let date = date{
            
            // update event and defaults
            switch (popUpTextField) {
            case (self.startDateTextField):
                self.event?.startTime = date
                // update end date
                self.event?.endTime = date.addingTimeInterval(60 * 60)
            case (self.endDateTextField):
                self.event?.endTime = date
            case (self.startTimeTextField):
                self.event?.startTime = date
                
            case (self.endTimeTextField):
                self.event?.endTime = date
            default:
                return
            }
            
            // update UI text field
            if let startTime = event?.startTime, let endTime = event?.endTime {
                startDateTextField.text = dateFormatter.string(from: startTime)
                endDateTextField.text = dateFormatter.string(from: endTime)
                startTimeTextField.text = timeFormatter.string(from: startTime)
                endTimeTextField.text = timeFormatter.string(from: endTime)
            }
        }
    }
}

// Source: https://www.youtube.com/watch?v=krZzC6abaoE
extension EditEventViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.backgroundColor = UIColor.clear
        imageView.isHidden = false
        uploadImageButton.setTitle("", for: .normal)
        event?.mainImage = imageView.image
        deleteImageButton.isHidden = false
        
        self.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)    }
}
