//
//  ClubListViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit
import Firebase

/// A view controller for displaying all clubs in a feed
class ClubListViewController: UIViewController {
    @IBOutlet weak var clubsTableView: UITableView!
    @IBOutlet weak var allClubsButton: UIButton!
    @IBOutlet weak var myClubButton: UIButton!
    
    var clubs: [Club]?  // Clubs curretly loaded into table
    var filteredClubs = [Club]() // Clubs filtered by search bar
    var userClubsDisplayed: Bool = false // True if "My Clubs" tapped

    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var profileButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(profileTapped))
        return button
    }()
    
    lazy var logo: UIBarButtonItem = {
        let image = UIImage.init(named: "computer-workers-group-ocean-25")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: nil)
        return button
    }()
    
    lazy var reloadButton: UIBarButtonItem = {
        let image = UIImage.init(named: "icons8-synchronize-filled-25")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(getClubs))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubsTableView.delegate = self
        clubsTableView.dataSource = self
        getClubs()
        viewInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filterClubs()
        clubsTableView.reloadData()
    }
    
    func viewInit() {
        // add logo to bar
        logo.isEnabled = false
        navigationItem.leftBarButtonItem = logo
        
        // Init selected clubs view buttons
        allClubsButton.alpha = 1.0
        allClubsButton.layer.cornerRadius =
            allClubsButton.frame.size.height/7
        myClubButton.alpha = 0.5
        myClubButton.layer.cornerRadius
            = myClubButton.frame.size.height/7
        
        // If user is a club, hide "Saved" and "All" button
        if User.currentUser?.club != nil {
            myClubButton.isHidden = true
            allClubsButton.isHidden = true
            navigationItem.rightBarButtonItem = profileButton
        // otherwise change add button to reload button
        } else {
            navigationItem.rightBarButtonItem = reloadButton
        }
        
        // Source: https://www.raywenderlich.com/472-uisearchcontroller-tutorial-getting-started
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // load all clubs into table and set button appearence
    @IBAction func allClubsButtonTapped(_ sender: Any) {
        searchController.isActive = false // cancel serach
        allClubsButton.alpha = 1.0
        myClubButton.alpha = 0.5
        clubs = Club.allClubs
        userClubsDisplayed = false
        clubsTableView.reloadData()
    }
    
    // load user clubs into table and set button appearence
    @IBAction func myClubsButtonTapped(_ sender: Any) {
        if let userClubs = User.currentUser?.clubs {
            searchController.isActive = false // cancel search
            allClubsButton.alpha = 0.5
            myClubButton.alpha = 1.0
            clubs = Club.allClubs?.filter{ club in
                userClubs.contains(club.id ?? "") }
            userClubsDisplayed = true
            clubsTableView.reloadData()
        }
    }
    
    @objc func profileTapped() {
        if let club = User.currentUser?.club {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ClubViewController") as! ClubViewController
            viewController.club = club
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // Get clubs loadLimit number of clubs from database starting from clubLoadNext
    @objc func getClubs() {
        DispatchQueue.global(qos: .default).async {
            Club.loadLock.wait()
            
            // reset club list
            Club.allClubs = []
            var addedClubs = 0
            
            ClubsApi.getClubsIDs(start: nil, limit: nil) { data, error in
                switch(data, error){
                case(nil, .some(let error)):
                    print(error)
                case(.some(let data), nil):
                    if let clubIds = data as? [String?] {
                        // add each club to the club list and reload table view
                        
                        // if no clubs, clear table view
                        if clubIds.count  <= 0 {
                            self.clubs = []
                            self.filteredClubs = []
                            self.clubsTableView.reloadData()
                        }
                        
                        for id in clubIds {
                            ClubsApi.getClub(id: id ?? "") { data, error in
                                switch(data, error){
                                case(nil, .some(let error)):
                                    print(error)
                                case(.some(let data), nil):
                                    let club = data as! Club
                                    addedClubs = addedClubs + 1
                                    Club.allClubs?.append(club)
                                    
                                     DispatchQueue.main.async {
                                        self.filterClubs()
                                        self.clubsTableView.reloadData()
                                     }
                                    if addedClubs == clubIds.count {
                                        Event.loadLock.signal()
                                    }
                                    
                                default:
                                    print("Error getting club \(id ?? "")")
                                }
                            }
                        }
                    }
                default:
                    print("Error getting clubs")
                    
                }
            }
        }
    }
    
    func filterClubs() {
        // sort clubs by name
        Club.allClubs
            = Club.allClubs?.sorted(by: { $0.name ?? "" < $1.name ?? ""})
        
        // Set clubs to display
        self.clubs = Club.allClubs
        
        // Filter if currenlty displayin user clubs
        if self.userClubsDisplayed,
            let userClubs = User.currentUser?.clubs {
            self.clubs = Club.allClubs?.filter{ club in
                userClubs.contains(club.id ?? "") }
        }
    }
}

// TableView funtions
extension ClubListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredClubs.count
        }
        return self.clubs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let clubs = self.clubs else {
            return UITableViewCell()
        }
        
        let club: Club
        if isFiltering() {
            club = filteredClubs[indexPath.row]
        } else {
            club = clubs[indexPath.row]
        }
        
        // the identifier is like the type of the cell
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "clubCell", for: indexPath) as! ClubCell
        
        cell.initClubCell(name: club.name,
                          image: club.image ?? UIImage(named: "defaultImage")) // FIXME: for testing
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ClubViewController") as! ClubViewController
        viewController.club = self.clubs.map { $0[indexPath.row] }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// Search bar
extension ClubListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // Private instance methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        guard let clubs = clubs else {
            return
        }
        
        // filter clubs by names and clubs matching the serach text
        filteredClubs = clubs.filter{ club in
            club.name?.lowercased().contains(searchText.lowercased()) ?? false
        }
        
        // sort filtered clubs  FIXME: ??
        filteredClubs =
            filteredClubs.sorted(by:{UIContentSizeCategory(rawValue: $0.name!) > UIContentSizeCategory(rawValue: $1.name!) })
        
        clubsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
