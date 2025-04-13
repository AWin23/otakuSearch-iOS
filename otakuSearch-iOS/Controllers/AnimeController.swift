//
//  AnimeController.swift
//  OtakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/13/25.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("✅ AnimeController view loaded")

        // special dark background
        view.backgroundColor = .otakuDark
        tableView.backgroundColor = .clear // Let background shine through
        tableView.separatorStyle = .none   // Optional: cleaner look
        
        view.addSubview(tableView) // add the table of the populated favoirte anime.
        
        // Setup tableView constraints
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        // Set delegate & data source
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              UserDefaults.standard.bool(forKey: "isLoggedIn") else {
            showAlert(title: "Not Logged In", message: "You must be logged in to view your favorites.")
            return
        }


        fetchFavorites(for: userId)
    }
    
    // show the alert, of user logged in or not
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    
    // fetches the user's favorite anime
    func fetchFavorites(for userId: String) {
        guard let url = URL(string: "http://localhost:8080/users/\(userId)/favorites") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                
                if let rawString = String(data: data, encoding: .utf8) {
                    print("🧾 Raw JSON:", rawString)
                }
                do {
                    let favorites = try JSONDecoder().decode([FavoriteAnime].self, from: data)
                    print("✅ Decoded \(favorites.count) favorites")
                    DispatchQueue.main.async {
                        self.favoriteAnime = favorites
                        self.tableView.reloadData()
                    }
                } catch {
                    print("❌ Decoding error:", error)
                }
            }
        }.resume()
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
