//
//  ClubListViewController.swift
//  ClubHub
//
//  Created by Lindsey Gray on 11/29/18.
//  Copyright © 2018 Lindsey Gray. All rights reserved.
//

import UIKit

class ClubListViewController: UIViewController {
    @IBOutlet weak var clubsTableView: UITableView!
    @IBOutlet weak var allClubsButton: UIButton!
    @IBOutlet weak var myClubButton: UIButton!
    
    var userClubs: [String]? // Array of user saved club ids
    var clubs: [Club]?  // Clubs curretly loaded into table
    var allClubs: [Club]? = [] // All unfilterd clubs
    var filteredClubs = [Club]() // Clubs filtered by search bar
    var clubLoadNext = "A" // Date to load next set of clubs form
    //FIXME: update for deployment
    var loadLimit: Int = 2 // Number of clubs to load at time (MUST BE > 1)
    var loadedClubs: Int = 0 // Number of clubs that have been loaded
    var userClubsDisplayed: Bool = false // True if "My Clubs" tapped
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubsTableView.delegate = self
        clubsTableView.dataSource = self
        viewInit()
    }
    
    func viewInit() {
        // Init selected clubs view buttons
        allClubsButton.alpha = 1.0
        myClubButton.alpha = 0.5
        
        getClubs()
        
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
        clubs = allClubs
        userClubsDisplayed = false
        clubsTableView.reloadData()
    }
    
    // load user clubs into table and set button appearence
    @IBAction func myClubsButtonTapped(_ sender: Any) {
        searchController.isActive = false // cancel search
        allClubsButton.alpha = 0.5
        myClubButton.alpha = 1.0
        clubs = allClubs?.filter{ club in
            userClubs?.contains(club.id ?? "") ?? false }
        userClubsDisplayed = true
        clubsTableView.reloadData()
    }
    
    // Get clubs loadLimit number of clubs from database starting from clubLoadNext
    func getClubs() {
        ClubsApi.getClubsIDs(start: clubLoadNext, limit: loadLimit) { data, error in
            switch(data, error){
            case(nil, .some(let error)):
                print(error)
            case(.some(let data), nil):
                if let clubIds = data as? [String?] {
                    self.loadedClubs += clubIds.count
                    
                    for id in clubIds {
                        ClubsApi.getClub(id: id ?? "") { data, error in
                            switch(data, error){
                            case(nil, .some(let error)):
                                print(error)
                            case(.some(let data), nil):
                                let club = data as! Club
                                self.allClubs?.append(club)
                                
                                // sort clubs by name
                                self.allClubs
                                    = self.allClubs?.sorted(by: { $0.name ?? "" < $1.name ?? ""})
                                self.clubs = self.allClubs
                                
                                // Filter if currenlty displayin user clubs
                                if self.userClubsDisplayed {
                                    self.clubs = self.allClubs?.filter{ club in
                                        self.userClubs?.contains(club.id ?? "") ?? false }
                                }
                                
                                self.clubsTableView.reloadData()
                                
                                // set the next date to load based on last loaded
                                if id == clubIds[clubIds.count - 1],
                                    let name = club.name{
                                    self.clubLoadNext = name
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
                          image: club.image ?? UIImage(named: "testImage")) // FIXME: for testing
        return cell
    }
/*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // FIXME: change "Cindy" to "Main"
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let storyboard = UIStoryboard(name: "Cindy", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "clubDetailsViewController") as! ClubDetailsViewController
        viewController.club = self.clubs.map { $0[indexPath.row] }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
 */
    // Load more clubs when the bottom of the table is scrolled to
    // Source: https://stackoverflow.com/questions/20269474/uitableview-load-more-when-scrolling-to-bottom-like-facebook-application
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.getClubs()
        }
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
