//
//  SendEmailViewController.swift
//  ClubHub
//
//  Created by Cindy Hoang on 12/3/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import MessageUI

class SendEmailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBAction func sendEmail(_ sender: Any) {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print("User's device is not supported")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func configureMailController() -> MFMailComposeViewController {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients(["cinhoang@ucdavis.edu"])
        mailComposeViewController.setSubject("ECS 189E")
        mailComposeViewController.setMessageBody("Hello!", isHTML: false)
        
        return mailComposeViewController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
