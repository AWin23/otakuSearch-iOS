//
//  AnimeController.swift
//  OtakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/13/25.
//

import UIKit
import Network
import CoreData


class AnimeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // favorite anime array to store the fetched user's favoirte animes
    var favoriteAnime: [FavoriteAnime] = []
    
    // set up UITableView
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(FavoriteAnimeCell.self, forCellReuseIdentifier: "FavoriteAnimeCell")
        return table
    }()
    
    /// Returns the number of rows (anime favorites) to display in the table view.
    /// Each favorite anime will occupy one row.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteAnime.count // 📦 Number of anime favorites retrieved from backend
    }

    /// Returns a fully configured UITableViewCell for a specific row (anime favorite).
    /// This method dequeues a reusable FavoriteAnimeCell and sets its title + image.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Try to dequeue a reusable cell of type FavoriteAnimeCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteAnimeCell", for: indexPath) as? FavoriteAnimeCell else {
            return UITableViewCell() // Fallback to a basic empty cell if casting fails
        }

        // Get the anime for the current row
        let anime = favoriteAnime[indexPath.row]

        // 🔍 Debug log to verify anime title rendering
        print("🎯 Populating cell for: \(anime.title)")

        // Configure the cell with anime data (title + image)
        cell.configure(with: anime)

        // Return the populated cell to be rendered in the table
        return cell
    }
    
    // MARK: - UITableViewDelegate
    // When user taps a favorite anime, push the detail screen with that anime's info
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFavorite = favoriteAnime[indexPath.row]

        // 🧠 Convert FavoriteAnime to Anime model (to reuse AnimeDetailViewController)
        let anime = Anime(
            id: selectedFavorite.animeId,
            title: AnimeTitle(
                romaji: selectedFavorite.title,
                english: selectedFavorite.title // Same here; if you stored separate romaji/english, adjust accordingly
            ),
            episodes: 0, // No episode data stored — use 0 or skip showing in detail
            status: "Unknown", // You can omit status if not needed
            coverImage: AnimeCoverImage(large: selectedFavorite.coverImageUrl)
        )

        // Fetch the full AnimeDetail first, then push
        print("🧭 NavigationController exists:", self.navigationController != nil)
        
        if NetworkMonitor.shared.isConnected {
            // 🌐 Online: Fetch detail from backend
            fetchAnimeDetail(animeID: selectedFavorite.animeId) { animeDetail in
                let detailVC = AnimeDetailViewController(anime: anime, animeID: anime.id, animeDetail: animeDetail)
                self.navigateToDetail(detailVC)
                print("Description: \(animeDetail.description ?? "nil")")
            }
        } else {
            // Offline: Use locally stored detail (from Core Data)
            let detail = AnimeDetail(
                id: selectedFavorite.animeId,
                title: AnimeTitle(romaji: selectedFavorite.title, english: selectedFavorite.title),
                description: selectedFavorite.description,
                episodes: selectedFavorite.episodes,
                status: selectedFavorite.status ?? "Unknown",
                duration: nil,
                season: nil,
                favourites: nil,
                genres: selectedFavorite.genres ?? [],
                studios: AnimeDetail.StudioContainer(edges: []),
                coverImage: CoverImage(medium: nil, large: selectedFavorite.coverImageUrl)
            )

            let detailVC = AnimeDetailViewController(anime: anime, animeID: anime.id, animeDetail: detail)
            self.navigateToDetail(detailVC)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // helper function
    private func navigateToDetail(_ detailVC: AnimeDetailViewController) {
        if let parentVC = self.presentingViewController as? ViewController {
            parentVC.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    
    // MARK: - Swipe to Delete Support
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let animeToDelete = self.favoriteAnime[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { (_, _, completionHandler) in
            print("🗑 Attempting to delete anime with ID: \(animeToDelete.animeId)")

            self.handleFavoriteDeletion(anime: animeToDelete, at: indexPath) {
                completionHandler(true)
            }
        }

        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // Helper Function to handle the deletion of Favorites
    private func handleFavoriteDeletion(anime: FavoriteAnime, at indexPath: IndexPath, completion: @escaping () -> Void) {
        FavoriteAnimeStore.shared.deleteFavorite(favoriteId: anime.favoriteId, animeId: anime.animeId) {
            DispatchQueue.main.async {
                self.favoriteAnime.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completion()
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("✅ AnimeController view loaded")
        
        // 🌟 Create a custom table header label
        let headerLabel = UILabel()
        headerLabel.text = "⭐️ Personal Favorites"
        headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerLabel.textColor = .otakuGray
        headerLabel.textAlignment = .left
        headerLabel.backgroundColor = .clear
        headerLabel.frame = CGRect(x: 16, y: 0, width: view.frame.width - 32, height: 44)

        // 📦 Wrap in a container view (for spacing)
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        headerContainer.backgroundColor = .clear
        headerContainer.addSubview(headerLabel)
        
        // Add constraints for Header of Table(optional but cleaner)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            headerLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -8)
        ])
        
        // 🎯 Assign to tableView header
        tableView.tableHeaderView = headerContainer

        // special dark background
        view.backgroundColor = .otakuDark
        tableView.backgroundColor = .clear // Let background shine through
        tableView.separatorStyle = .none   // Optional: cleaner look
                
        view.addSubview(tableView) // add the table of the populated favoirte anime.
        
        // Setup tableView constraints for the Favorite Anime List
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        // Set delegate & data source
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // runs every time user enters the "Favorites Tab"
    // perfectly checks login state and updates the UI
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      // Enhanced login check
      let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
      let userId = UserDefaults.standard.string(forKey: "userId")
      let userEmail = UserDefaults.standard.string(forKey: "userEmail")

      if !isLoggedIn || userId == nil || userEmail == nil {
        showAlert(title: "Not Logged In", message: "You must be logged in to view your favorites.")
        favoriteAnime = []  // Clear previous data
        tableView.reloadData()
        return
      }

        // logic to check should the backend be online, if offline, call the toast
      checkBackendAvailability { [weak self] isBackendReachable in
        guard let self = self else { return }

        DispatchQueue.main.async {
          if !isBackendReachable {
            // 🔴 Backend reachable = false, show toast
            ToastManager.shared.show(
              message: "Backend unavailable — some features may not work properly.")
          }
        }

        // ✅ Reload favorites every time tab is visited from Backend and/or Core Data
        loadFavoritesDependingOnNetwork()  // 🔁 Fetch from backend or Core Data again

        // TEST ONLY, clear core data on page load. Keep uncommented in production.
        //FavoriteAnimeStore.shared.clearAllCoreDataFavorites()

      }
    }

    
    // show the alert, of user logged in or not
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    
    /// Function to load favorite anime either from backend or local Core Data,
    /// depending on network and backend availability.
    func loadFavoritesDependingOnNetwork() {
        if NetworkMonitor.shared.isConnected {
            print("🌐 Online — checking backend availability")

            // Check if backend is reachable even though we're online
            checkBackendAvailability { [weak self] isBackendReachable in
                guard let self = self else { return }

                if isBackendReachable {
                    print("✅ Backend reachable — fetching from backend")

                    // Safely unwrap user ID from UserDefaults
                    guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                        print("❌ No user ID found in UserDefaults")
                        return
                    }

                    self.fetchFavoritesFromBackend(for: userId)
                } else {
                    print("⚠️ Backend unreachable — falling back to Core Data")
                    self.fetchFavoritesFromCoreDataOnly()
                }
            }
        } else {
            print("🚫 Offline — loading from Core Data")
            fetchFavoritesFromCoreDataOnly()
        }
    }

    /// Function that pings the backend's /health endpoint to confirm it's reachable.
    /// If status code is 200, the backend is considered up.
    func checkBackendAvailability(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:8080/health") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 3 // Fail fast if backend doesn't respond quickly

        // Perform a lightweight health check request
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }


    // function to fetch the favorites from core data only
    func fetchFavoritesFromCoreDataOnly() {
        let allFavorites = FavoriteAnimeStore.shared.loadVisibleFavorites()
        let visibleFavorites = allFavorites.filter { !($0.isDeletedLocally ?? false) }


        print("fetching user's favorites from core data")
        print("📴 Loaded \(allFavorites.count) favorites from Core Data (Offline Mode)")
        
        DispatchQueue.main.async {
            self.favoriteAnime = visibleFavorites
            self.tableView.reloadData()
        }
    }

    
    // Fetches the user's favorite anime from the backend (SQL database via Spring Boot)
    func fetchFavoritesFromBackend(for userId: String) {
        // 1. Construct the backend endpoint using the provided userId
        guard let url = URL(string: "http://localhost:8080/users/\(userId)/favorites") else {
            print("❌ Invalid URL")
            return
        }

        print("🌐 Fetching user's favorites from backend...")

        // 2. Perform a GET request to the backend using URLSession
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {

                do {
                    // 3. Decode the JSON response into [FavoriteAnime] using Codable
                    // - This maps JSON to Swift structs (FavoriteAnime)
                    // - The `isDeletedLocally` field is local-only and won't be affected
                    // - And Triggers the Merging logic from Offline to Backend (Deletion too)
                    let favorites = try JSONDecoder().decode([FavoriteAnime].self, from: data)
                    print("✅ Successfully decoded \(favorites.count) favorites")

                    // 🧠 Add this to trigger sync + deletion logic immediately
                    FavoriteAnimeStore.shared.syncCoreDataWithBackend(favorites)


                    DispatchQueue.main.async {
                        // Reload from Core Data to get locally valid entries (not marked deleted)
                        let visibleFavorites = FavoriteAnimeStore.shared.loadVisibleFavorites()
                        
                        if visibleFavorites.isEmpty {
                            print("📭 Core Data is empty — showing decoded backend results directly")
                            self.favoriteAnime = favorites  // fallback to backend response
                        } else {
                            print("📦 Loaded visible favorites from Core Data")
                            self.favoriteAnime = visibleFavorites
                        }
                        
                        // 📥 Fetch detail for each anime and save to Core Data
                        for favorite in self.favoriteAnime {
                            self.fetchAnimeDetail(animeID: favorite.animeId) { detail in
                                // Optional: print or ignore – saving handled inside fetchAnimeDetail
                                print("🧠 Saved extra detail for animeId \(detail.id)")
                            }
                        }

                        // Reload the UI table
                        self.tableView.reloadData()
                    }


                } catch {
                    // Handle decoding errors, such as mismatched field types
                    print("❌ Decoding error:", error)
                }
            } else if let error = error {
                // Handle connection issues or timeouts
                print("❌ Network error:", error.localizedDescription)
            }
        }.resume()
    }


    
    // fetch the anime detali helper
    func fetchAnimeDetail(animeID: Int, completion: @escaping (AnimeDetail) -> Void) {
        if NetworkMonitor.shared.isConnected {
            checkBackendAvailability { isBackendReachable in
                if isBackendReachable {
                    print("🌐 Backend is reachable — fetching AnimeDetail from backend for ID \(animeID)")

                    let url = URL(string: "http://localhost:8080/anime/\(animeID)")!
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let data = data, error == nil else {
                            DispatchQueue.main.async {
                                print("❌ Network error fetching detail for anime ID \(animeID):", error?.localizedDescription ?? "Unknown")
                            }
                            return
                        }

                        do {
                            let decoded = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
                            let animeDetail = decoded.data.Media

                            let studioName = animeDetail.studios.edges.first?.node.name
                            
                            DispatchQueue.main.async {
                                print("✅ Successfully decoded anime detail for ID \(animeID)")

                                // 💾 Save important fields to Core Data for offline access
                                FavoriteAnimeStore.shared.updateDetailInfo(
                                    animeId: animeDetail.id,
                                    description: animeDetail.description,
                                    episodes: animeDetail.episodes,
                                    status: animeDetail.status,
                                    genres: animeDetail.genres,
                                    studio: studioName,
                                    season: animeDetail.season
                                )

                                completion(animeDetail)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                print("❌ Decoding error for anime detail ID \(animeID):", error)
                            }
                        }
                    }.resume()

                } else {
                    // ⚠️ Backend unreachable — fallback to Core Data
                    DispatchQueue.main.async {
                        print("⚠️ Backend unreachable — falling back to Core Data for anime ID \(animeID)")
                        if let offlineDetail = FavoriteAnimeStore.shared.loadDetailInfo(animeId: animeID) {
                            completion(offlineDetail)
                        } else {
                            print("❌ No offline detail available for anime ID \(animeID)")
                        }
                    }
                }
            }

        } else {
            // 📴 No internet at all
            DispatchQueue.main.async {
                print("📴 Offline mode — loading AnimeDetail from Core Data for ID \(animeID)")
                if let offlineDetail = FavoriteAnimeStore.shared.loadDetailInfo(animeId: animeID) {
                    completion(offlineDetail)
                } else {
                    print("❌ No offline detail available for anime ID \(animeID)")
                }
            }
        }
    }



    // Run this once or every time to delete core data records. 
    func removeDuplicateFavoritesInCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        
        do {
            let all = try context.fetch(request)
            var seenIds = Set<Int>()
            var toDelete: [FavoriteAnimeEntity] = []

            for entity in all {
                let id = Int(entity.animeId)
                if seenIds.contains(id) {
                    toDelete.append(entity)
                } else {
                    seenIds.insert(id)
                }
            }

            for dup in toDelete {
                context.delete(dup)
            }

            try context.save()
            print("🧹 Removed \(toDelete.count) duplicate Core Data records")
        } catch {
            print("❌ Error removing duplicates:", error)
        }
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
