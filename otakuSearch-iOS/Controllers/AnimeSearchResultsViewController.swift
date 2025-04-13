//
//  AnimeSearchResultsViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/30/25.
//

import UIKit

// MARK: - Model Conversion Extension

/// Converts an AnimeSearchEntry into a normalized Anime model
extension AnimeSearchEntry {
    func toAnime() -> Anime {
        return Anime(
            id: self.id,
            title: AnimeTitle(
                romaji: self.title.romaji,
                english: self.title.english
            ),
            episodes: self.episodes ?? 0,
            status: self.status ?? "Unknown",
            coverImage: AnimeCoverImage(large: self.coverImage.large)
        )
    }
}


class AnimeSearchResultsViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    var searchTableView: UITableView!  // Make sure this is declared
    var viewModel = DiscoveryViewModel() // Use the same ViewModel for search results
    
    var anime: Anime! // declare the anime model
    
    var searchedAnimeResults: [AnimeSearchEntry] = [] // Array to store the searched anime on search bar

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        
        // Initialize and set up the table view
        searchTableView = UITableView(frame: view.bounds, style: .plain)
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(AnimeTableViewCell.self, forCellReuseIdentifier: AnimeTableViewCell.identifier)
        searchTableView.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        
        // REGISTERS the cell class here
        searchTableView.register(AnimeSearchResultTableViewCell.self, forCellReuseIdentifier: AnimeSearchResultTableViewCell.identifier)


        searchTableView.rowHeight = 60
        searchTableView.estimatedRowHeight = 60
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchTableView)
        
        additionalSafeAreaInsets.top = -50 // ← shift upward
        
        
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Did the view actually appear?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("👀 AnimeSearchResultsViewController appeared.")
        print("🎯 searchTableView.delegate: \(searchTableView.delegate.debugDescription)")
        print("🎯 searchTableView.dataSource: \(searchTableView.dataSource.debugDescription)")
        
        searchTableView.reloadData()
        print("📢 Called reloadData in viewDidAppear")

    }

    
    // MARK: - UITableViewDataSource
    
    // anime grid view
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140 // or 150 depending on padding
    }

    
    // returns the number of cells from the "searchAnimeResults" data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedAnimeResults.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAnime = searchedAnimeResults[indexPath.row]

        if let parentVC = self.presentingViewController as? ViewController {
            // ✅ DO NOT deactivate searchController here anymore
            // Let it stay active so the overlay remains
            
            // Fetch first, push after
            if let parentVC = self.presentingViewController as? ViewController {
                fetchAnimeDetail(animeID: selectedAnime.id) { animeDetail in
                    let anime = self.searchedAnimeResults[indexPath.row].toAnime()
                    let detailVC = AnimeDetailViewController(anime: anime, animeID: anime.id, animeDetail: animeDetail)
                    
                    parentVC.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        // Safety check to avoid index out of range
        guard indexPath.row < searchedAnimeResults.count else {
            print("❌ indexPath.row \(indexPath.row) is out of bounds for searchedAnimeResults count \(searchedAnimeResults.count)")
            return UITableViewCell()
        }

        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AnimeSearchResultTableViewCell.identifier, for: indexPath) as? AnimeSearchResultTableViewCell else {
            return UITableViewCell()
        }

        // Get the anime object from the searchedAnimeResults array at the given index
        let anime = searchedAnimeResults[indexPath.row]
    
        
        // Use the title directly since it's a String (no need for "english" or "romaji")
        let title = anime.title.english ?? anime.title.romaji ?? "Unknown Title"
                
        // Pass the title (a String) to the cell
        let imageURL = anime.coverImage.large
        
        
        // Pass a year into the cell (an Int)
        let seasonYear = anime.seasonYear
        
        cell.configure(with: title, imageURL: imageURL, seasonYear: seasonYear)

        return cell
    }



    // MARK: - UISearchResultsUpdating
    // This is the required method for UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) { 
        DispatchQueue.main.async {
            
            guard self.searchTableView != nil else {
                print("❌ searchTableView in AnimeSearchViewController.swift is nil. Cannot reload data.")
                return
            }
            
            self.searchTableView.reloadData()
        }
    }
    
    /// Function to fetch search results via Search Bar
    private func fetchSearchResults(query: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "http://localhost:8080/anime/search?title=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            print("❌ Invalid search URL")
            completion()
            return
        }

        print("🌍 Fetching from URL: \(url.absoluteString)") // ✅ Debugging URL being called

        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle network errors
            if let error = error {
                print("❌ Error fetching search results: \(error.localizedDescription)")
                DispatchQueue.main.async { completion() }
                return
            }

            // Ensure response is an HTTPURLResponse and check status code
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Server returned an error: \(httpResponse.statusCode)")
                    DispatchQueue.main.async { completion() }
                    return
                }
            }

            // Ensure data is received
            guard let data = data else {
                print("❌ No data received from API")
                DispatchQueue.main.async { completion() }
                return
            }

            // ✅ Log the raw JSON response from backend
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Raw JSON Response: \(jsonString)")
            }

            do {
                // Decode JSON response
                let decoder = JSONDecoder()
                let searchResults = try decoder.decode([AnimeSearchEntry].self, from: data)
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.searchedAnimeResults = searchResults
                    print("✅ Updated searchedAnimeResults: \(self.searchedAnimeResults)")

                    if self.searchedAnimeResults.isEmpty {
                        print("⚠️ searchedAnimeResults is empty! No data was parsed.")
                    }
                    
                    self.searchTableView.reloadData()
                    completion()
                }
            } catch {
                print("❌ Error LOL decoding search results: \(error)")
                DispatchQueue.main.async { completion() }
            }
        }.resume()
    }
    
    func fetchAnimeDetail(animeID: Int, completion: @escaping (AnimeDetail) -> Void) {
        let url = URL(string: "http://localhost:8080/anime/\(animeID)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Invalid URL or network error for: \(url)")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
                DispatchQueue.main.async {
                    print("✅ Successfully decoded AnimeDetail in AnimeSearchResultController")
                    completion(decodedResponse.data.Media)
                }
            } catch {
                print("❌ Error decoding anime details: \(error)")
            }
        }.resume()
    }
}



