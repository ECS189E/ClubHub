//
//  ConversationViewController.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/6/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Photos
import Firebase

/// A view controller for an individual conversation between two users
class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50
    var currentUser: Profile?
    
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = self.currentUser?.name
        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(self.dismissSelf))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func fetchData() {
        Message.downloadAllMessages(forUserID: self.currentUser!.id, completion: {[weak weakSelf = self] (message) in
            weakSelf?.items.append(message)
            weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
            DispatchQueue.main.async {
                if let state = weakSelf?.items.isEmpty, state == false {
                    weakSelf?.tableView.reloadData()
                    weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
        Message.markMessagesRead(forUserID: self.currentUser!.id)
    }
    
    @objc func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
        Message.send(message: message, toID: self.currentUser!.id, completion: {(_) in
        })
    }
    
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        default:
            self.bottomConstraint.constant = -50
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func showMessage(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func showOptions(_ sender: Any) {
        self.animateExtraButtons(toHide: false)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.count > 0 {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
            }
        }
    }
    
    @objc func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].owner {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as? String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            cell.profilePic.image = self.currentUser?.profilePic
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as? String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        switch self.items[indexPath.row].type {
        case .photo:
            if let photo = self.items[indexPath.row].image {
                let info = ["viewType" : ShowExtraView.preview, "pic": photo] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
                self.inputAccessoryView?.isHidden = true
            }
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.showKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Message.markMessagesRead(forUserID: self.currentUser!.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.customization()
        self.fetchData()
    }
}
