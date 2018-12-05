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
    @IBOutlet weak var aboutClub: UILabel!
    
    var club: Club?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clubImage.image = club?.image ?? UIImage(named: "testImage")
        clubName.text = club?.name
        aboutClub.text = club?.details
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
