//
//  AnimeDetailViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/24/25.
//

import UIKit

// AnimeDetailViewController displays detailed information for a specific anime.
class AnimeDetailViewController: UIViewController {
    
    var anime: Anime! // anime variable to allow for Anime types
    
    var animeID: Int  // Store the anime ID
    
    // The anime object passed to this view controller, containing all necessary anime data.
    var animeDetail: AnimeDetail

// Custom initializer to receive the anime ID
    init(anime: Anime, animeID: Int, animeDetail: AnimeDetail) {
        self.anime = anime
        self.animeID = animeID
        self.animeDetail = animeDetail
        super.init(nibName: nil, bundle: nil)
    }

    // Required initializer (not implemented) for the case when the view controller is loaded from a storyboard.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This method is called when the view is loaded into memory.
    // this is like the react "render" function, where you load stuff into the DOM
    // this is where the contents are injected into the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AnimeDetailViewController loaded for animeID: \(animeID)")
        
        // Set background color
        view.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)

        // Scroll View (To allow scrolling if content is large)
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Content View (holds all content inside the scroll view)
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    

        // Anime Image
        let animeImageView = UIImageView()
        animeImageView.contentMode = .scaleAspectFit
        animeImageView.clipsToBounds = true
        animeImageView.translatesAutoresizingMaskIntoConstraints = false
        animeImageView.image = UIImage(named: "placeholder") // Default placeholder

        // Ensure `coverImage?.large` exists before setting the image.
        if let imageUrlString = animeDetail.coverImage?.large, let imageUrl = URL(string: imageUrlString) {
            print("Cover Image URL: \(animeDetail.coverImage?.large ?? "No image found")")
            animeImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }

        // Add the imageView to the view hierarchy
        contentView.addSubview(animeImageView)

        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = animeDetail.title.english ?? animeDetail.title.romaji
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0 // Allow multiple lines of text
        titleLabel.lineBreakMode = .byWordWrapping // Make sure text wraps instead of truncating
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Studio Label (Header 2)
        let studioLabel = UILabel()
        studioLabel.text = animeDetail.studios.edges.first?.node.name ?? "Unknown Studio"
        studioLabel.textColor = .white
        studioLabel.font = UIFont.boldSystemFont(ofSize: 18)
        studioLabel.textAlignment = .center
        studioLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(studioLabel)

        // Mini Sections (Season & Episodes)
        let seasonLabel = UILabel()
        seasonLabel.text = "Season: \(animeDetail.season ?? "Unknown")"
        seasonLabel.textColor = .white
        seasonLabel.font = UIFont.systemFont(ofSize: 16)
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false

        let episodesLabel = UILabel()
        episodesLabel.text = "Episodes: \(animeDetail.episodes ?? 0)"
        episodesLabel.textColor = .white
        episodesLabel.font = UIFont.systemFont(ofSize: 16)
        episodesLabel.textAlignment = .right
        episodesLabel.translatesAutoresizingMaskIntoConstraints = false

        let miniStackView = UIStackView(arrangedSubviews: [seasonLabel, episodesLabel])
        miniStackView.axis = .horizontal
        miniStackView.distribution = .fillEqually
        miniStackView.spacing = 20
        miniStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(miniStackView)

        // "Add to List" Button
        let addToListButton = UIButton(type: .system)
        addToListButton.setTitle("Add to List", for: .normal)
        addToListButton.setTitleColor(.white, for: .normal)
        addToListButton.backgroundColor = .red
        addToListButton.layer.cornerRadius = 8
        addToListButton.isEnabled = false // Later enable when authentication is implemented
        addToListButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addToListButton)
        
        // checks the login state of the user
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        addToListButton.isEnabled = isLoggedIn


        // Summary Label
        let summaryLabel = UILabel()
        summaryLabel.text = "Summary"
        summaryLabel.textColor = .white
        summaryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryLabel)

        let descriptionLabel = UILabel()
        descriptionLabel.text = animeDetail.description
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        
        // Solid Horizontal Line
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray // Adjust color as needed
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        
        // LEFT SECTION
        let leftLabels = [
            "Series Info",
            "Season: \(animeDetail.season ?? "Unknown")",
            "Favorites: \(animeDetail.favourites.map { "\($0)" } ?? "0")",
        ]

        let leftStackView = UIStackView(arrangedSubviews: leftLabels.map { text in
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 1
            return label
        })
        leftStackView.axis = .vertical
        leftStackView.alignment = .leading
        leftStackView.spacing = 5
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // RIGHT SECTION
        let rightLabels = [
            "Airing: \(animeDetail.status ?? "Unknown")",
            "Minutes per Episode: \(animeDetail.duration ?? 0)",

        ]

        let rightStackView = UIStackView(arrangedSubviews: rightLabels.map { text in
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 1
            return label
        })
        rightStackView.axis = .vertical
        rightStackView.alignment = .leading
        rightStackView.spacing = 5
        rightStackView.translatesAutoresizingMaskIntoConstraints = false

        //  HORIZONTAL STACK (Holds Left & Right Columns)
        let bottomStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 20
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomStackView)
        
        // Anime Titles (Romaji & English)
        let romajiTitleLabel = UILabel()
        romajiTitleLabel.text = "Romaji: \(animeDetail.title.romaji ?? "N/A")"
        romajiTitleLabel.textColor = .white
        romajiTitleLabel.font = UIFont.systemFont(ofSize: 14)
        romajiTitleLabel.numberOfLines = 0 // Allow for multiple lines
        romajiTitleLabel.lineBreakMode = .byWordWrapping // Word wrapping
        romajiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(romajiTitleLabel)

        let englishTitleLabel = UILabel()
        englishTitleLabel.text = "English: \(animeDetail.title.english ?? "N/A")"
        englishTitleLabel.textColor = .white
        englishTitleLabel.font = UIFont.systemFont(ofSize: 14)
        englishTitleLabel.numberOfLines = 0 // Allow for multiple lines
        englishTitleLabel.lineBreakMode = .byWordWrapping // Word wrapping
        englishTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(englishTitleLabel)


        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View Constraints (width should match the scroll view's width)
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),  // This is important for scrolling to work

            // Anime Image
            // Set width and height limits for the image
            // Anime Image Constraints
            animeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10), // Some space at the top
            animeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20), // Some space on the left
            animeImageView.widthAnchor.constraint(equalToConstant: 170), // Set fixed width to 100
            animeImageView.heightAnchor.constraint(equalToConstant: 200), // Set fixed height to 150
            animeImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor), // Center the image horizontally

            // Title
            titleLabel.topAnchor.constraint(equalTo: animeImageView.bottomAnchor, constant: 10),
            
            // Keeps the title aligned to theleft
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Keeps the title within the screen bounds
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Studio Label
            studioLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            studioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            studioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Mini Stack View (Season & Episodes)
            miniStackView.topAnchor.constraint(equalTo: studioLabel.bottomAnchor, constant: 15),
            miniStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            miniStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // "Add to List" Button
            addToListButton.topAnchor.constraint(equalTo: miniStackView.bottomAnchor, constant: 20),
            addToListButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addToListButton.widthAnchor.constraint(equalToConstant: 150),
            addToListButton.heightAnchor.constraint(equalToConstant: 44),

            // Summary Label
            summaryLabel.topAnchor.constraint(equalTo: addToListButton.bottomAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: separatorLine.topAnchor, constant: -20),

            // Separator Line
            separatorLine.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separatorLine.heightAnchor.constraint(equalToConstant: 1), // Thin line
            
            
            // Bottom Stack View
            bottomStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            
            // Title for constraints
            romajiTitleLabel.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 30),
            romajiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            romajiTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            englishTitleLabel.topAnchor.constraint(equalTo: romajiTitleLabel.bottomAnchor, constant: 30),
            englishTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            englishTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            englishTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

        ])
        
        // Fetch additional details about the anime from the backend when the view is loaded.
        fetchAnimeDetails()
        
        // wire up the "Add to favorites"
        addToListButton.addTarget(self, action: #selector(addToFavoritesTapped), for: .touchUpInside)
    }
    
    // funtion to handle the favorites anime
    @objc func addToFavoritesTapped() {
        print("🟥 Add to List button tapped!")
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let userId = UserDefaults.standard.string(forKey: "userId")

        print("🧪 isLoggedIn:", isLoggedIn)
        print("🧪 userId:", userId ?? "nil")
        
        guard UserDefaults.standard.bool(forKey: "isLoggedIn"),
              let userId = UserDefaults.standard.string(forKey: "userId") else {
            showAlert(title: "Not Logged In", message: "You must be logged in to add anime to your list.")
            return
        }


        // Create the favorite anime data payload to store into User's DB
        let favoriteAnime: [String: Any] = [
            "animeId": anime.id,
            "title": anime.title.romaji ?? anime.title.english ?? "Unknown Title",
            "coverImageUrl": anime.coverImage.large ?? ""
        ]
        
        print("📦 Payload being sent:", favoriteAnime)

        // Convert to JSON and send POST
        guard let url = URL(string: "http://localhost:8080/users/\(userId)/favorites"),
              let jsonData = try? JSONSerialization.data(withJSONObject: favoriteAnime) else {
            print("Invalid URL or JSON data")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to add to list: \(error.localizedDescription)")
                    return
                }

                self.showAlert(title: "Success", message: "Anime added to your list!")
            }
        }.resume()
    }
    
    
    // display the alert
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    // This function fetches additional details about the anime by calling a backend API.
    private func fetchAnimeDetails() {
        print("Fetching details for anime with ID: \(animeID)")

        // Construct the URL to call the backend API using the anime's ID.
        let url = URL(string: "http://localhost:8080/anime/\(animeID)")!
        
        // Perform a network request to fetch anime details.
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for data and ensure there is no error.
            guard let data = data, error == nil else {
                return
            }
            

            do {
                // Decode the response data into an Anime object.
                let decodedResponse = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
                
                // Update the anime details on the main thread after decoding.
                DispatchQueue.main.async {
                    self.animeDetail = decodedResponse.data.Media // Correctly access the `AnimeDetail`
                    self.title = self.animeDetail.title.english ?? self.animeDetail.title.romaji // Update the navigation bar title
                }
            } catch {
                // Print any errors that occurred during decoding.
                print("Error decoding anime details: \(error)")
            }
        }.resume() // Start the data task
    }
}


