//
//  ClubViewController.swift
//  ClubHub
//
//  Created by Srivarshini Ananta on 12/4/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//
import UIKit

class ClubViewController: UIViewController {
    
    @IBOutlet weak var clubName: UILabel!
    @IBOutlet weak var clubImage: UIImageView!
    @IBOutlet weak var aboutClub: UITextView!
    
    var club: Club?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clubImage.image = club?.image ?? UIImage(named: "testImage")
        clubName.text = club?.name
        aboutClub.text = club?.details
        
        print(aboutClub.fs_height)
    }
    
}
