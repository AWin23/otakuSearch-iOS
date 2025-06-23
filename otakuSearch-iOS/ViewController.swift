//
//  ViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/13/25.
//
import UIKit

// a protocol DisplayableAnime that both Anime and FilteredAnime conform to
protocol DisplayableAnime {
    var titleRomaji: String { get }
    var titleEnglish: String? { get }
}

extension Anime: DisplayableAnime {
    var titleRomaji: String { title.romaji ?? "" }
    var titleEnglish: String? { title.english }
}

extension FilteredAnime: DisplayableAnime {
    var titleRomaji: String { title.romaji }
    var titleEnglish: String? { title.english }
}

// extension that enables logic for the FilterView Delegate
extension ViewController: FilterViewControllerDelegate {
    func didApplyFilters(_ filteredAnime: [FilteredAnime]) {
        
        // toggles no results if there is no filtered anime
        toggleNoResultsLabel(show: filteredAnime.isEmpty)

        self.isFiltering = true
        self.filteredAnime = filteredAnime
        self.table.reloadData()
        self.showToast(message: "🎯 Filters Applied")
        self.clearFiltersButton.alpha = 1
    }

    
    // clears the filters
    func didClearFilters() {
        
        // toggles the boolean filtering to false
        // empties the filteredAnime array
        // reloads the table and displays the filters clearned
        // along with reseting "no anime filtered" message, if there was no anime
        self.isFiltering = false
        self.filteredAnime = []
        self.table.reloadData()
        toggleNoResultsLabel(show: false)
        self.showToast(message: "🧼 Filters Cleared")
        self.clearFiltersButton.alpha = 0
    }
}


class ViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {

    var searchResultsController: AnimeSearchResultsViewController! // Declare it as an optional, you’ll initialize it in viewDidLoad
    
    var searchController: UISearchController! // Declare the searchController as a class-level property
    
    let viewModel = DiscoveryViewModel() // Declare the viewModel here to call the fetching method
    
    // Declration of Search debouncer and Search Bar's results
    var searchTimer: Timer?
    var searchTableView: UITableView!
    
    // table that stores all the anime grids and cells
    // declares as a UITableView
    var table: UITableView!
    
    var wasSearching = false
    
    // Stores filtered results from FilterViewController
    var filteredAnime: [FilteredAnime] = []

    // Tracks if filtering mode is enabled
    var isFiltering: Bool = false
    
    // tracks if a filter has been applied or not
    var hasAppliedFilter: Bool = false
    
    // tracks the state of the clear filters button
    var clearFiltersButton: UIButton!
    
    // declaration of the Label for NO Results
    var noResultsLabel: UILabel!


    //  logic for if the Profile is tapped, it will say whether user is logged in or not
    @objc func profileTapped() {
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? "Unknown"
        
        // 🧪 Debug print
        print("👤 User tapped profile icon. Loaded email: \(email)")
        
        
        let alert = UIAlertController(title: "Logged In", message: "Welcome back, \(email)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // logic for the filter button, once tapped, an action sheet will select filter options
    @objc func filterTapped() {
        
        let filterVC = FilterViewController()
        filterVC.delegate = self
        
        
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }

    
    // handles the filter applied to here
    @objc func handleFilterApplied(_ notification: Notification) {
        guard hasAppliedFilter else { return }

        print("📬 Filter was applied, reloading table view")
        table.reloadData()
        hasAppliedFilter = false

        // Show the clear filters button
        UIView.animate(withDuration: 0.3) {
            self.clearFiltersButton.alpha = 1
        }
    }

    // helper function handles the clear filters button being tapped
    // empties the filteredAnime array
    @objc func clearFiltersTapped() {
        
        isFiltering = false //  isFiltering is declared as false
        filteredAnime = []  //  filteredAnime array is emptied
        table.reloadData()  //  table data is reloaded to have the "default fetch" work.
        showToast(message: "🔄 Filters cleared")

        UIView.animate(withDuration: 0.3) {
            self.clearFiltersButton.alpha = 0
        }
    }
    
    // toggles the no results to show up
    func toggleNoResultsLabel(show: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.noResultsLabel.alpha = show ? 1 : 0
            self.noResultsLabel.isHidden = !show
        }
    }
    
    /// Called every time the view is about to appear.
    /// Ensures the navigation bar reflects the current login state.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBarForLoginState() // 🔄 Re-evaluate nav bar visibility each time the view appears
    }

    /// Updates the navigation bar to show or hide the profile icon based on login state.
    func updateNavBarForLoginState() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // ✅ User is logged in → show profile icon
            
            let profileButton = UIButton(type: .custom)
            profileButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            profileButton.tintColor = .otakuPink // 🎨 Accent color from theme
            profileButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)

            let profileBarItem = UIBarButtonItem(customView: profileButton)
            navigationItem.rightBarButtonItems = [profileBarItem]
        } else {
            // ❌ User is logged out → remove profile icon
            navigationItem.rightBarButtonItems = []
        }
    }

    
    override func viewDidLoad() {
        
        // check if user is logged in, if so, show a profile icon
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // Create a profile button
            let profileButton = UIButton(type: .custom)
            profileButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal) // Use SF Symbol
            profileButton.tintColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0)
            profileButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            // Optionally: Add action to tap on the profile
            profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
            
            // Embed it in a UIBarButtonItem
            let profileBarItem = UIBarButtonItem(customView: profileButton)
            
            // Add both buttons to right side of nav bar
            navigationItem.rightBarButtonItems = [profileBarItem]
        }
        
        // Filter button
        let filterButtonBelow = UIButton(type: .system)
        filterButtonBelow.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), for: .normal)
        filterButtonBelow.tintColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0)
        filterButtonBelow.layer.cornerRadius = 28 // Rounded to make it a circle
        filterButtonBelow.translatesAutoresizingMaskIntoConstraints = false
        filterButtonBelow.addTarget(self, action: #selector(self.filterTapped), for: .touchUpInside)
        
        DispatchQueue.main.async {
            // adding the filter button into the subview handler
            self.view.addSubview(filterButtonBelow)
            
            // constraints for the filter button
            NSLayoutConstraint.activate([
                filterButtonBelow.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 6),
                filterButtonBelow.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                filterButtonBelow.widthAnchor.constraint(equalToConstant: 56),
                filterButtonBelow.heightAnchor.constraint(equalToConstant: 56)
            ])
        }
        
        
        // shows the clear filters button
        func setupClearFiltersButton() {
            clearFiltersButton = UIButton(type: .system)
            clearFiltersButton.setTitle("Clear Filters", for: .normal)
            clearFiltersButton.setTitleColor(.white, for: .normal)
            clearFiltersButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            clearFiltersButton.backgroundColor = .otakuRed
            clearFiltersButton.layer.cornerRadius = 10
            clearFiltersButton.alpha = 0 // start hidden
            clearFiltersButton.translatesAutoresizingMaskIntoConstraints = false
            clearFiltersButton.addTarget(self, action: #selector(clearFiltersTapped), for: .touchUpInside)

            //  adds to the clearFiltersButton
            view.addSubview(clearFiltersButton)

            NSLayoutConstraint.activate([
                clearFiltersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                clearFiltersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                clearFiltersButton.widthAnchor.constraint(equalToConstant: 160),
                clearFiltersButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
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
        table.register(UITableViewCell.self, forCellReuseIdentifier: "EmptyCell") // registering a basic UTTableViewCell for Empty Cells
        table.backgroundColor = .otakuDark // 1B1919 color
        
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
        
        // declares the filter button 
        setupClearFiltersButton()
        
        // call the no label button
        setupNoResultsLabel()
    }
    
    // updates the search results that the search bar is querying
    // populates the menu "as you type"
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            return
        }
                
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
        //return 5 // One section for each category (Trending, Upcoming, Current Popular, All-Time Popular)
        return isFiltering ? 1 : 5 // IF there is filtering, return 1 cell, otherwise 5 for the other sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Only one row per section, but it will hold a collection view
    }

    
    // the Header's in each of the grids
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If filtering is active, hide section headers
        if isFiltering { return nil }

        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor(red: 239/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        // Set the section title
        switch section {
        case 0: titleLabel.text = "Trending Anime"
        case 1: titleLabel.text = "Upcoming Anime"
        case 2: titleLabel.text = "Current Popular Anime"
        case 3: titleLabel.text = "All-Time Popular Anime"
        case 4: titleLabel.text = "Top 100 Anime"
        default: titleLabel.text = ""
        }

        // addds the title label into the header view
        headerView.addSubview(titleLabel)
        
        // constraints, for, the title label itself
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

        
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 🧠 Step 1: Determine the list of anime for this cell (either filtered or by section)
        let animeList: [Anime]

        if isFiltering {
            // 🎯 Filtering is active — convert FilteredAnime objects into the shared Anime model
            animeList = filteredAnime.map {
                Anime(
                    id: $0.id,
                    title: AnimeTitle(romaji: $0.title.romaji, english: $0.title.english),
                    episodes: $0.episodes ?? 0,        // Default to 0 if nil
                    status: $0.status ?? "Unknown",    // Default to "Unknown" if nil
                    coverImage: AnimeCoverImage(large: $0.coverImage.large)
                )
            }
        } else {
            // 📦 No filtering — fetch anime list by category based on section index
            switch indexPath.section {
            case 0: animeList = viewModel.trendingAnime
            case 1: animeList = viewModel.upcomingAnime
            case 2: animeList = viewModel.currentPopularAnime
            case 3: animeList = viewModel.allTimePopularAnime
            case 4: animeList = viewModel.top100Anime
            default: animeList = [] // Fail-safe: empty list for any unknown section
            }
        }

        // 🚫 Step 2: Show empty fallback cell if there’s no data OR the user is offline
        if animeList.isEmpty || !NetworkMonitor.shared.isConnected {
            // 🪪 Reuse a basic system cell with a placeholder message
            // 🎨 Background color and border
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            emptyCell.backgroundColor = UIColor.otakuDark
            emptyCell.layer.borderColor = UIColor.otakuPink.cgColor
            emptyCell.layer.borderWidth = 1.5
            emptyCell.layer.cornerRadius = 8
            emptyCell.layer.masksToBounds = true

            // 📝 Label styling
            emptyCell.textLabel?.text = "No data, please go online"
            emptyCell.textLabel?.textColor = UIColor.otakuGray
            emptyCell.textLabel?.textAlignment = .center
            emptyCell.textLabel?.numberOfLines = 0
            emptyCell.selectionStyle = .none
            return emptyCell
        }

        // ✅ Step 3: Data is available — configure and return a proper AnimeTableViewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeTableViewCell", for: indexPath) as? AnimeTableViewCell else {
            // 🔒 Return a blank fallback if the custom cell cast fails
            return UITableViewCell()
        }

        cell.delegate = self // Assign delegate for user interactions
        cell.configure(with: animeList) // Pass the anime data to the cell's internal collection view
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
            let detailVC = AnimeDetailViewController(anime: anime, animeID: anime.id, animeDetail: animeDetail)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func didTapAnime(_ anime: Anime) {
        // Handle anime cell tap here
        print("🎬 Tapped anime: \(anime.title.romaji ?? "Unknown")")
        
    }
    
    // function that displays a banner once the filters are tapped
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])

        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
    
    // set up not results label
    func setupNoResultsLabel() {
        noResultsLabel = UILabel()
        noResultsLabel.text = "😕 No anime found.\nTry adjusting your filters."
        noResultsLabel.textColor = .lightGray
        noResultsLabel.numberOfLines = 0
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noResultsLabel.isHidden = true
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noResultsLabel)
        
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    
    // Helper function to fetch AnimeDetail from your API or backend
    func fetchAnimeDetail(animeID: Int, completion: @escaping (AnimeDetail) -> Void) {
        let url = URL(string: "http://localhost:8080/anime/\(animeID)")! // Adjust the URL as needed
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ No data returned from: \(url)")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📝 Raw JSON Response:\n\(jsonString)")
            } else {
                print("⚠️ Could not convert data to UTF-8 string.")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)

                DispatchQueue.main.async {
                    print("✅ Successfully decoded AnimeDetail")
                    completion(decodedResponse.data.Media)
                }
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }.resume()

    }
}
