//
//  ViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/13/25.
//
import UIKit

class ViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    let searchController = UISearchController() // Declaration of UISearchController component
    let viewModel = DiscoveryViewModel() // Declare the viewModel here to call the fetching method
    
    // Arrays to store the fetched anime
    var trendingAnime: [Anime] = []
    var upcomingAnime: [Anime] = []
    var currentPopularAnime: [Anime] = []
    
    var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Example of a custom dark color using RGB values
        view.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        
        // Assign the search controller to the navigation bar
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false  // Keeps it fixed
        
        // Manually adjust the position of the search bar
        positionSearchBarAtStart()

        // Center the title of the navigation bar
        let titleLabel = UILabel()
        titleLabel.text = "Discovery"
        titleLabel.textColor = .white  // Set your desired color
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)  // Adjust the font size as necessary
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel  // This centers the title
            
        // Sets placeholder text for the search bar
        let searchBar = searchController.searchBar
        let placeholderText = "Search Anime"

        // Set placeholder with custom color
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)]
        )

        
        // Initialize the UITableView programmatically
        table = UITableView(frame: self.view.bounds, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(AnimeTableViewCell.self, forCellReuseIdentifier: AnimeTableViewCell.identifier)
        table.backgroundColor = .clear


        // Add the table view to the view hierarchy
        view.addSubview(table)
        
        // Fetch anime data
        viewModel.fetchTrendingAnime {
            print("Fetch completed, trending anime count: \(self.viewModel.trendingAnime.count)")
            DispatchQueue.main.async {
                self.table.reloadData() // Ensures the data is loaded before configuring the data
            }
        }
        
        viewModel.fetchUpcomingAnime {
            print("Fetch completed, upcoming anime count: \(self.viewModel.upcomingAnime.count)")
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        
        viewModel.fetchCurrentPopularAnime {
            print("Fetch completed, current popular anime count: \(self.viewModel.currentPopularAnime.count)")
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        
        viewModel.fetchAllTimePopularAnime {
            print("Fetch completed, all-time popular anime count: \(self.viewModel.allTimePopularAnime.count)")
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
    }

    // MARK: - Custom Positioning for Search Bar
    
    func positionSearchBarAtStart() {
        // Access the search bar directly (no need for guard let since it's not optional)
        let searchBar = searchController.searchBar
        
        // Set the frame or adjust constraints for the search bar
        var searchBarFrame = searchBar.frame
        searchBarFrame.origin.y = 100  // Change 100 to whatever Y position you want
        searchBar.frame = searchBarFrame
        
        // Optional: Customize other properties of the search bar here (like size)
    }

    
    // MARK: - UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // One section for each category (Trending, Upcoming, Current Popular, All-Time Popular)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Only one row per section, but it will hold a collection view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Trending Anime"
        case 1:
            return "Upcoming Anime"
        case 2:
            return "Current Popular Anime"
        case 3:
            return "All-Time Popular Anime"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeTableViewCell", for: indexPath) as? AnimeTableViewCell else {
            return UITableViewCell()
        }
        
        // Choose the appropriate anime data based on section
        let animeList: [Anime]
        switch indexPath.section {
        case 0:
            animeList = viewModel.trendingAnime // Fetch Trending anime from ViewModel
        case 1:
            animeList = viewModel.upcomingAnime // Fetch Upcoming anime from ViewModel
        case 2:
            animeList = viewModel.currentPopularAnime // Fetch Current popular anime from ViewModel
        case 3:
            animeList = viewModel.allTimePopularAnime // Fetch All-Time anime from ViewModel
        default:
            animeList = []
        }
        
        // Configure the cell with the correct anime data for the section
        cell.configure(with: animeList)
        
        return cell
    }

    // Adjust the height of each row for the collection view
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220 // Adjust the height based on the size of the collection view
    }

    // Handle search bar input
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        print("User is searching for: \(text)")
    }
}
