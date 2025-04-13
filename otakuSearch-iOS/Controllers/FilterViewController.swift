//
//  FilterViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/4/25.
//
import UIKit

// protocol to avoid navigation stack guessing
protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(_ filteredAnime: [FilteredAnime])
    func didClearFilters()
}



extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Just 1 column of years
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let yearText = "\(years[row])"
        return NSAttributedString(
            string: yearText,
            attributes: [
                .foregroundColor: UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0), // #efecec
                .font: UIFont.boldSystemFont(ofSize: 18) // bolding the selected state
            ]
        )
    }


    // handles logic for the year that is picked 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedYear = years[row]
        print("📆 Selected Year: \(selectedYear!)")
    }
}


class FilterViewController: UIViewController {
    
    // delegate property in FilterViewController
    weak var delegate: FilterViewControllerDelegate?
    
    // Used to send filter query params to the backend
    struct AnimeFilterParameterModels {
        var genres: [String]?
        var season: String?
        var year: Int?
        var formats: [String]?
        var status: String?
    }
    
    // genres, season, status, and types variables
    let genres = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Sci-Fi"]
    let seasons = ["WINTER", "SPRING", "SUMMER", "FALL"]
    
    let statusMappings: [String: String] = [
        "Airing": "RELEASING",
        "Finished": "FINISHED",
        "Not Yet Aired": "NOT_YET_RELEASED",
        "Cancelled": "CANCELLED"
    ]

    let formatMappings: [String: String] = [
        "TV Show": "TV",
        "Movie": "MOVIE",
        "OVA": "OVA",
        "Special": "SPECIAL",
        "Short": "TV_SHORT",
        "Music": "MUSIC"
    ]

    
    
    // selected genres are stored in array for multi-selection
    var selectedGenres: Set<String> = []
    var genreScrollView: UIScrollView!  // genre is in a scroll view
    
    // years in array and selected year state
    var years: [Int] = Array(1970...Calendar.current.component(.year, from: Date()))
    var selectedYear: Int?
    var yearPicker: UIPickerView!

    
    // selected seasons are stored in array for multi-selection
    var selectedSeason: String?
    var seasonScrollView: UIScrollView!  // season is in a scroll view
    var seasonButtons = [UIButton]() // empty string array to store the Season buttons


    // selected statuses are stored in array (but not for multi-selection)
    var statusScrollView: UIScrollView! // tracks state of the Status
    var selectedStatus: String?
    var statusButtons = [UIButton]() // empty string array to store the Status buttons
    
    // selected Anime Formats are stored in array (but for multi-selection)
    var selectedFormats: Set<String> = []
    var typesScrollView: UIScrollView! // tracks state of the Status
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .otakuDark

        // declares headers for the label
        setupHeader()
        
        // creates UI declarations for the Filter Buttons
        setupGenreButtons()
        setupYearPickerSection()
        setupSeasonButtons(below: yearPicker)
        setupStatusButtons(below: seasonScrollView)
        setupTypesButtons(below: statusScrollView)
        
        // sets up the "Apply Filters" button
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        applyButton.backgroundColor = .otakuRed // selected red button
        applyButton.layer.cornerRadius = 10
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        view.addSubview(applyButton)

        NSLayoutConstraint.activate([
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    //  function to setup and display the title header
    func setupHeader() {
        
        // filter header
        let title = UILabel()
        title.text = "Filter"
        title.textColor = .white
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    //  function to setup and display the genre buttons
    func setupGenreButtons() {
        // 0. Genre Header Label
        let genreLabel = UILabel()
        genreLabel.text = "Genre"
        genreLabel.textColor = .white
        genreLabel.font = UIFont.boldSystemFont(ofSize: 18)
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(genreLabel)
        
        // 1. Create and assign the scroll view
        genreScrollView = UIScrollView()
        genreScrollView.showsHorizontalScrollIndicator = false
        genreScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(genreScrollView)


        // 2. Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        genreScrollView.addSubview(stackView)

        // 3. Add genre buttons to the stack view
        for genre in genres {
            let button = UIButton(type: .system)
            button.setTitle(genre, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .otakuPink // selected red button
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.sizeToFit() // Make the button wrap its content
            button.addTarget(self, action: #selector(genreTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        // 4. Add layout constraints
        NSLayoutConstraint.activate([
            // Genre Label Constraints
            genreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            genreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Pin scroll view
            genreScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            genreScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genreScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            genreScrollView.heightAnchor.constraint(equalToConstant: 50),

            // Pin stack view inside scroll view
            stackView.topAnchor.constraint(equalTo: genreScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: genreScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: genreScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: genreScrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: genreScrollView.heightAnchor)
        ])
    }
    
    // MARK: - Year Picker Setup
    func setupYearPickerSection() {
        // 1. Year Label
        let yearLabel = UILabel()
        yearLabel.text = "Year"
        yearLabel.textColor = .otakuGray
        yearLabel.font = UIFont.boldSystemFont(ofSize: 18)
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yearLabel)

        // 2. Year Picker (UIPickerView)
        yearPicker = UIPickerView()
        yearPicker.delegate = self
        yearPicker.dataSource = self
        yearPicker.backgroundColor = .otakuDark
        yearPicker.translatesAutoresizingMaskIntoConstraints = false
        
        // pink border to background - Year Picker
        yearPicker.layer.borderWidth = 1
        yearPicker.layer.borderColor = UIColor(red: 219/255, green: 45/255, blue: 105/255, alpha: 0.6).cgColor
        yearPicker.layer.cornerRadius = 8

        view.addSubview(yearPicker)
        
        // 3. Highlight of the year picker
        let highlightView = UIView()
        highlightView.backgroundColor = UIColor(red: 219/255, green: 45/255, blue: 105/255, alpha: 0.2) // light translucent pink
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        yearPicker.addSubview(highlightView)

        NSLayoutConstraint.activate([
            // Highlights for the Picker Itself
            highlightView.centerYAnchor.constraint(equalTo: yearPicker.centerYAnchor),
            highlightView.leadingAnchor.constraint(equalTo: yearPicker.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: yearPicker.trailingAnchor),
            highlightView.heightAnchor.constraint(equalToConstant: 32),
            
            // constraints for the year Label
            yearLabel.topAnchor.constraint(equalTo: genreScrollView.bottomAnchor, constant: 30), // Or another section
            yearLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // constraints for the Year Picker
            yearPicker.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 10),
            yearPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            yearPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            yearPicker.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
    // MARK: - Season Picker Setup
    func setupSeasonButtons(below anchorView: UIView) {
        // 0. Season Header Label
        let seasonLabel = UILabel()
        seasonLabel.text = "Season"
        seasonLabel.textColor = .white
        seasonLabel.font = UIFont.boldSystemFont(ofSize: 18)
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seasonLabel)
        
        // 1. Create and assign the scroll view
        seasonScrollView = UIScrollView()
        seasonScrollView.showsHorizontalScrollIndicator = false
        seasonScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seasonScrollView)


        // 2. Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        seasonScrollView.addSubview(stackView)

        // 3. Add genre buttons to the stack view
        for season in seasons {
            let seasonButton = UIButton(type: .system)
            seasonButton.setTitle(season, for: .normal)
            seasonButton.setTitleColor(.white, for: .normal)
            seasonButton.backgroundColor = .otakuPink // #db2d69
            seasonButton.layer.cornerRadius = 10
            seasonButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            seasonButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            seasonButton.sizeToFit() // Make the button wrap its content
            seasonButton.addTarget(self, action: #selector(seasonTapped(_:)), for: .touchUpInside)
            
            // adds the buttons to the stackview
            stackView.addArrangedSubview(seasonButton)
            seasonButtons.append(seasonButton) // stores the state of the buttons
        }

        // 4. Add layout constraints
        NSLayoutConstraint.activate([
            // Season Label
            seasonLabel.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: 30),
            seasonLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // ScrollView
            seasonScrollView.topAnchor.constraint(equalTo: seasonLabel.bottomAnchor, constant: 10),
            seasonScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            seasonScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            seasonScrollView.heightAnchor.constraint(equalToConstant: 50),

            // StackView inside scrollView
            stackView.topAnchor.constraint(equalTo: seasonScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: seasonScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: seasonScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: seasonScrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: seasonScrollView.heightAnchor)
        ])
    }
    
    // MARK: - Status Buttons Setup
    func setupStatusButtons(below anchorView: UIView) {
        // 0. Status Header Label
        let statusLabel = UILabel()
        statusLabel.text = "Airing Status"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.boldSystemFont(ofSize: 18)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // 1. Create and assign the scroll view
        statusScrollView = UIScrollView()
        statusScrollView.showsHorizontalScrollIndicator = false
        statusScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusScrollView)


        // 2. Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        statusScrollView.addSubview(stackView)
        
        // 3. Add genre buttons to the stack view
        for (label, _) in statusMappings {
            let statusButton = UIButton(type: .system)
            statusButton.setTitle(label, for: .normal)
            statusButton.setTitleColor(.white, for: .normal)
            statusButton.backgroundColor = .otakuPink // #db2d69 for "default buton color"
            statusButton.layer.cornerRadius = 10
            statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            statusButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            statusButton.sizeToFit()
            statusButton.addTarget(self, action: #selector(statusTapped(_:)), for: .touchUpInside)

            stackView.addArrangedSubview(statusButton)
            statusButtons.append(statusButton)
        }

        
        // 4. Add layout constraints
        NSLayoutConstraint.activate([
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: seasonScrollView.bottomAnchor, constant: 30), // change `previousSection`
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Status ScrollView
            statusScrollView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            statusScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusScrollView.heightAnchor.constraint(equalToConstant: 50),

            // StackView inside scrollView
            stackView.topAnchor.constraint(equalTo: statusScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: statusScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: statusScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: statusScrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: statusScrollView.heightAnchor)
        ])
    }
    
    // MARK: - Types Buttons Setup
    func setupTypesButtons(below anchorView: UIView) {
        // 0. Types Header Label
        let typesLabel = UILabel()
        typesLabel.text = "Formats"
        typesLabel.textColor = .white
        typesLabel.font = UIFont.boldSystemFont(ofSize: 18)
        typesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typesLabel)
        
        // 1. Create and assign the scroll view
        typesScrollView = UIScrollView()
        typesScrollView.showsHorizontalScrollIndicator = false
        typesScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typesScrollView)


        // 2. Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        typesScrollView.addSubview(stackView)
        
        // 3. Add types buttons to the stack view
        for (label, _) in formatMappings {
            let formatButton = UIButton(type: .system)
            formatButton.setTitle(label, for: .normal)
            formatButton.setTitleColor(.white, for: .normal)
            formatButton.backgroundColor = .otakuPink // #db2d69 (default button)
            formatButton.layer.cornerRadius = 10
            formatButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            formatButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            formatButton.sizeToFit() // Make the button wrap its content
            formatButton.addTarget(self, action: #selector(formatTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(formatButton)
            statusButtons.append(formatButton) // stores the state of the buttons
        }
        
        // 4. Add layout constraints
        NSLayoutConstraint.activate([
            // Types Label
            typesLabel.topAnchor.constraint(equalTo: statusScrollView.bottomAnchor, constant: 30), // change `previousSection`
            typesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Status ScrollView
            typesScrollView.topAnchor.constraint(equalTo: typesLabel.bottomAnchor, constant: 10),
            typesScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            typesScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            typesScrollView.heightAnchor.constraint(equalToConstant: 50),

            // StackView inside scrollView
            stackView.topAnchor.constraint(equalTo: typesScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: typesScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: typesScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: typesScrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: typesScrollView.heightAnchor)
        ])
    }
    
    
    // MARK: - Filters Query Building Setup
    func applyFilters() {
        
        // Dynamically map the status to its backend value
        let mappedStatus = selectedStatus.flatMap { statusMappings[$0] } ?? selectedStatus
        
        // Dynamically map the selected format labels to backend format strings
        let mappedFormats = selectedFormats.compactMap { formatMappings[$0] }


        // 1. Create filter parameters using selected values from UI
        let filterParams = AnimeFilterParameterModels(
            genres: Array(selectedGenres),
            season: selectedSeason,
            year: selectedYear,
            formats: mappedFormats,
            status: mappedStatus
        )

        // 2. Define backend endpoint URL
        guard let baseURL = URL(string: "http://localhost:8080/anime/filter") else {
            print("❌ Invalid backend URL.")
            return
        }

        // 3. Use URLComponents to build query parameters dynamically
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []

        // 4. Append multi-select genres
        filterParams.genres?.forEach {
            queryItems.append(URLQueryItem(name: "genres", value: $0))
        }

        // 5. Append season if selected
        if let season = filterParams.season {
            queryItems.append(URLQueryItem(name: "season", value: season))
        }

        // 6. Append year if valid
        if let year = filterParams.year, year > 0 {
            queryItems.append(URLQueryItem(name: "year", value: String(year)))
        }

        // 7. Append multi-select formats
        filterParams.formats?.forEach {
            queryItems.append(URLQueryItem(name: "formats", value: $0))
        }

        // 8. Append status if selected
        if let status = filterParams.status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        components.queryItems = queryItems


        // 9. Create GET request
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        // 19. Perform network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("⚠️ No data returned from server.")
                return
            }

            // 11. Decode JSON into [FilteredAnime]
            do {
                // Decode response
                let decoded = try JSONDecoder().decode(FilteredAnimeResponse.self, from: data)
                let resultAnimeArray = decoded.data.Page.media

                // Debug raw JSON (optional)
                if let rawJSON = String(data: data, encoding: .utf8) {
                }

                // Dispatch task to update the UI on main thread
                DispatchQueue.main.async {
    
                    // ✅ Only delegate handles the filtering logic now
                    self.delegate?.didApplyFilters(resultAnimeArray)

                    // ✅ Dismiss the sheet
                    self.dismiss(animated: true)
                }


            } catch {
                print("❌ Failed to decode JSON: \(error)")
            }

        }.resume()
    }


    
    //  function handles the genre being tapped
    @objc func genreTapped(_ sender: UIButton) {
        guard let genre = sender.title(for: .normal) else { return }

        // checks if the genre is inside that array
        if selectedGenres.contains(genre) {
            // 🔄 Deselect
            selectedGenres.remove(genre)
            sender.backgroundColor = .otakuPink // special red background (SELECTED)
            sender.setTitleColor(.white, for: .normal)
        } else {
            // ✅ Select
            selectedGenres.insert(genre)
            sender.backgroundColor = .otakuRed // slightly different red
            sender.setTitleColor(UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0), for: .normal)
        }
    }
    
    //  function handles the season being tapped
    @objc func seasonTapped(_ sender: UIButton) {
        
        guard let tappedSeason = sender.title(for: .normal) else { return }

        if selectedSeason == tappedSeason {
            // Deselect if already selected
            selectedSeason = nil
            sender.backgroundColor = UIColor(red: 219/255, green: 45/255, blue: 105/255, alpha: 1.0)
            sender.setTitleColor(.white, for: .normal)
        } else {
            // Select new button and deselect others
            for seasonButton in seasonButtons {
                seasonButton.backgroundColor = UIColor(red: 219/255, green: 45/255, blue: 105/255, alpha: 1.0)
                seasonButton.setTitleColor(.white, for: .normal)
            }

            selectedSeason = tappedSeason
            sender.backgroundColor = UIColor(red: 219/255, green: 55/255, blue: 45/255, alpha: 1.0)
            sender.setTitleColor(.white, for: .normal)
        }
    }

    
    //  function handles the Status being tapped
    @objc func statusTapped(_ sender: UIButton) {
        guard let tappedStatus = sender.title(for: .normal) else { return }

        // if the current state of status is the same as it being tapped, then...
        if selectedStatus == tappedStatus {
            // Deselect if already selected
            selectedStatus = nil
            sender.backgroundColor = .otakuPink // "default button color"
            sender.setTitleColor(.white, for: .normal)
        } else {
            // Select new button and deselect others
            for statusButton in statusButtons {
                statusButton.backgroundColor = .otakuPink // "default button color"
                statusButton.setTitleColor(.white, for: .normal)
            }

            selectedStatus = tappedStatus
            sender.backgroundColor = .otakuRed // "SELECTED RED COLOR"
            sender.setTitleColor(.white, for: .normal)
        }
    }
    
    //  function handles the formats being tapped
    @objc func formatTapped(_ sender: UIButton) {
        guard let format = sender.title(for: .normal) else { return }

        // checks if the genre is inside that array
        if selectedFormats.contains(format) {
            // 🔄 Deselect
            selectedFormats.remove(format)
            sender.backgroundColor = .otakuPink // special red background (SELECTED)
            sender.setTitleColor(.white, for: .normal)
        } else {
            // ✅ Select
            selectedFormats.insert(format)
            sender.backgroundColor = .otakuRed // special red background (SELECTED)
            sender.setTitleColor(UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0), for: .normal)
        }

    }
    
    // function to handle the filter apply button
    @objc func applyButtonTapped() {
        applyFilters() // calls the filters function
        dismiss(animated: true) // Optionally close the sheet after applying
    }
    
    
    //  helper function
    // clears the filters once the CLEAR BUTTON
    // is tapped
    @objc func clearFiltersTapped() {
 
        // Reset all selections
        selectedGenres.removeAll()
        selectedFormats.removeAll()
        selectedSeason = nil
        selectedYear = 0
        selectedStatus = nil
        
        // calls the delegate to clear filters
        delegate?.didClearFilters()
        self.dismiss(animated: true)


        // Notify root VC to reset
        if let nav = self.presentingViewController as? UINavigationController,
           let rootVC = nav.viewControllers.first as? ViewController {
            rootVC.isFiltering = false
            rootVC.filteredAnime = []
            rootVC.table.reloadData()
            rootVC.showToast(message: "🔄 Filters cleared")
        }

        self.dismiss(animated: true)
    }




}


