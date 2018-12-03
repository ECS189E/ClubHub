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
class EventDetailsViewController: UIViewController {

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
    
}