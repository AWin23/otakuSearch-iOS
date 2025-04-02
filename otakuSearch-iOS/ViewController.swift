//
//  ViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/13/25.
//
import UIKit

class ViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    var searchResultsController: AnimeSearchResultsViewController! // Declare it as an optional, you’ll initialize it in viewDidLoad
    
    var searchController: UISearchController! // Declare the searchController as a class-level property


    let viewModel = DiscoveryViewModel() // Declare the viewModel here to call the fetching method
    
    // Declration of Search debouncer and Search Bar's results
    var searchTimer: Timer?
    var searchTableView: UITableView!
    
    var table: UITableView!
    
    var wasSearching = false

    override func viewDidLoad() {
        // Initialize the searchResultsController
        searchResultsController = AnimeSearchResultsViewController()

        // Embed it in a navigation controller
        let navSearchResultsController = UINavigationController(rootViewController: searchResultsController)

        // Initialize the search controller with the embedded search results controller
        searchController = UISearchController(searchResultsController: navSearchResultsController)

        // Set the search results updater to the parent (self)
        searchController.searchResultsUpdater = self

        
        // Example of a custom dark color using RGB values
        view.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        
        // Assign the search controller to the navigation bar
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false  // Keeps it fixed

        // Center the title of the navigation bar
        let titleLabel = UILabel()
        titleLabel.text = "Discovery"
        titleLabel.textColor = .white  // Set your desired color
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)  // Adjust the font size as necessary
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel  // This centers the title
            
        // Set up the search controller appearance
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        // Configure the search bar appearance (placeholder, text color, etc.)
        let searchBar = searchController.searchBar
        let placeholderText = "Search Anime"
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)]
        )
        
        // cancel button color
        searchBar.tintColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0)
        
        // Set input text color to #efecec
        searchBar.searchTextField.textColor = UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0)

        
        // Initialize the UITableView programmatically
        table = UITableView(frame: self.view.bounds, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(AnimeTableViewCell.self, forCellReuseIdentifier: AnimeTableViewCell.identifier)
        table.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0) // 1B1919 color

        // Add the table view to the view hierarchy
        view.addSubview(table)
        
        // Fetch anime data
        viewModel.fetchTrendingAnime {
            DispatchQueue.main.async {
                self.table.reloadData() // Ensures the data is loaded before configuring the data
            }
        }
        
        viewModel.fetchUpcomingAnime {
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
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        
        viewModel.fetchTop100Anime {
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Anime"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // updates the search results that the search bar is querying
    // populates the menu "as you type"
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            print("🔴 Search query is empty or nil.")
            return
        }

        print("🔎 User is searching for: \(query)")

        // Cancel previous timer
        searchTimer?.invalidate()

        // Start new debounced fetch
        searchTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.viewModel.fetchSearchResults(query: query) {
                DispatchQueue.main.async {
                    print("🔄 Reloading searchTableView in VIEWCONTROLLER...")

                    // 🔥 This MUST be inside the callback AFTER results are updated
                    if let navVC = self.searchController.searchResultsController as? UINavigationController,
                       let searchVC = navVC.viewControllers.first as? AnimeSearchResultsViewController {

                        _ = searchVC.view  // This forces viewDidLoad() to run if it hasn’t yet
                        searchVC.searchedAnimeResults = self.viewModel.searchedAnimeResults
                        print("✅ Passed \(self.viewModel.searchedAnimeResults.count) anime to searchVC")
                        searchVC.searchTableView.reloadData()
                    }
                }
            }
        }
    }

    
    // MARK: - UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5 // One section for each category (Trending, Upcoming, Current Popular, All-Time Popular)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Only one row per section, but it will hold a collection view
    }
    
    // the Header's in each of the grids
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        // Optional: Set background color of the Title Cell if needed
        headerView.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set title text based on section
        switch section {
        case 0:
            titleLabel.text = "Trending Anime"
        case 1:
            titleLabel.text = "Upcoming Anime"
        case 2:
            titleLabel.text = "Current Popular Anime"
        case 3:
            titleLabel.text = "All-Time Popular Anime"
        case 4:
            titleLabel.text = "Top 100 Anime"
        default:
            titleLabel.text = ""
        }
        
        // Set the text color using RGB values instead of hex
        titleLabel.textColor = UIColor(red: 239/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // Add the titleLabel to the header view
        headerView.addSubview(titleLabel)
        
        // Add constraints to keep the label aligned to the left with padding
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16), // Left padding of 16
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor) // Keep it vertically centered
        ])
        return headerView
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeTableViewCell", for: indexPath) as? AnimeTableViewCell else {
            return UITableViewCell()
        }
        
        
        //cell.animeData = animeSection.animeList  // Assign anime data
        cell.delegate = self  // Set delegate
        
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
        case 4:
            animeList = viewModel.top100Anime // Fetch Top 100 anime from ViewModel
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
}


// MARK: - AnimeTableViewCellDelegate
extension ViewController: AnimeTableViewCellDelegate {
    
    func animeTableViewCell(_ cell: AnimeTableViewCell, didSelectAnime anime: Anime) {
        
        // Fetch the AnimeDetail for the selected anime
        fetchAnimeDetail(animeID: anime.id) { animeDetail in
            
            // Step 2: Pass the fetched AnimeDetail instance to the detail view controller
            let detailVC = AnimeDetailViewController(animeID: anime.id, animeDetail: animeDetail)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // Helper function to fetch AnimeDetail from your API or backend
    func fetchAnimeDetail(animeID: Int, completion: @escaping (AnimeDetail) -> Void) {
        let url = URL(string: "http://localhost:8080/anime/\(animeID)")! // Adjust the URL as needed
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Invalid URL: \(url)")
                return
            }
    
            
            do {
                // Decode the fetched data into an AnimeDetail object
                let decodedResponse = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📝 JSON Response: \(jsonString)")
                }


                DispatchQueue.main.async {
                    // Call the completion handler with the AnimeDetail instance
                    print("✅ Successfully decoded AnimeDetail")
                    completion(decodedResponse.data.Media)
                }
            } catch {
                print("❌ Error decoding anime details: \(error)")
            }
        }.resume()
    }
}
