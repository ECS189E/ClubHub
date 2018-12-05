//
//  EventDetailsViewController.swift
//  CompSciClubs
//
//  Created by Lindsey Gray on 11/18/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

/*
    TODO: Clean up UI, add favorite/saving, edit feature
 */
class EventDetailsViewController: UIViewController, EditEventDelegate {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE MMM dd, yyyy hh:mm a"

        event?.printEvent()
        eventImageView.image = event?.image ?? UIImage(named: "testImage")
        eventNameLabel.text = event?.name ?? "Event Name"
        clubNameLabel.text = event?.club ?? "Club Name"
        dateTimeLabel.text = event?.startTime.map{dateFormatter.string(from: $0)} ?? "Date and Time"
        locationLabel.text = event?.location ?? "Location"
        descriptionLabel.text = event?.details ??  "Description"
    }
    
    @IBAction func testButton(_ sender: Any) {
        // Used only for testing
        let storyboard = UIStoryboard(name: "Cindy", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "sendEmailViewController") as! SendEmailViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func editEventTapped(_ sender: Any) {
        // Used only for testing
        let storyboard = UIStoryboard(name: "Lindsey", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editEventViewController") as! EditEventViewController
        viewController.event = event
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    // EditEventDelegate func
    // Once the backend finished updating event
    // Returns updated event if event updated successfully
    // Returns nil if deleted or an error encountered
    func editEventCompleted(event: Event?) {
        // Cindy finish me!
    }
    
    // EditEventDelegate func
    // Once done is tapped in edit event, but backend not updated yet
    func editEventStarted() {
        // Cindy finish me!
    }
}
