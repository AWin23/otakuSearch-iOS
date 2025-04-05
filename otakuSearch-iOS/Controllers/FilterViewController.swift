//
//  FilterViewController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/4/25.
//
import UIKit


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
    
    // genres, season, status, and years variables
    let genres = ["Action", "Adventure", "Comedy", "Drama", "Fantasy", "Sci-Fi"]
    let seasons = ["WINTER", "SPRING", "SUMMER", "FALL"]
    let statuses = ["FINISHED", "RELEASING", "NOT_YET_RELEASED"]
    
    // selected genres are stored in array for multi-selection
    var selectedGenres: Set<String> = []
    var genreScrollView: UIScrollView!  // genre is in a scroll view
    
    // years in array and selected year state
    var years: [Int] = Array(1970...Calendar.current.component(.year, from: Date()))
    var selectedYear: Int?
    var yearPicker: UIPickerView!

    
    // selected genres are stored in array for multi-selection
    var selectedSeason: Set<String> = []
    var seasonScrollView: UIScrollView!  // genre is in a scroll view


    var selectedStatus: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 27/255, green: 25/255, blue: 25/255, alpha: 1.0) // #1b1919

        setupHeader()
        setupGenreButtons()
        setupYearPickerSection()
        setupSeasonButtons(below: yearPicker)

        // setupStatusButtons
        // You'll add season, year, status UI in similar fashion
        
        
        //  eventually, function will somehow call all the filter helper
        //  and query string build into the backend
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
            button.backgroundColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0) // #db2d69
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
        yearLabel.textColor = .white
        yearLabel.font = UIFont.boldSystemFont(ofSize: 18)
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yearLabel)

        // 2. Year Picker (UIPickerView)
        yearPicker = UIPickerView()
        yearPicker.delegate = self
        yearPicker.dataSource = self
        yearPicker.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0) // match theme
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
        // 0. Genre Header Label
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
            let button = UIButton(type: .system)
            button.setTitle(season, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0) // #db2d69
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.sizeToFit() // Make the button wrap its content
            button.addTarget(self, action: #selector(seasonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
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



    //  function handles the genre being tapped
    @objc func genreTapped(_ sender: UIButton) {
        guard let genre = sender.title(for: .normal) else { return }

        // checks if the genre is inside that array
        if selectedGenres.contains(genre) {
            // 🔄 Deselect
            selectedGenres.remove(genre)
            sender.backgroundColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0) // special red background
            sender.setTitleColor(.white, for: .normal)
        } else {
            // ✅ Select
            selectedGenres.insert(genre)
            sender.backgroundColor = UIColor(red: 219/255, green: 55/255, blue: 45/255, alpha: 1.0) // slightly different red
            sender.setTitleColor(UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0), for: .normal)
        }

        print("🎯 Selected Genres: \(selectedGenres)")
    }
    
    //  function handles the season being tapped
    @objc func seasonTapped(_ sender: UIButton) {
        guard let season = sender.title(for: .normal) else { return }

        // checks if the genre is inside that array
        if selectedSeason.contains(season) {
            // 🔄 Deselect
            selectedSeason.remove(season)
            sender.backgroundColor = UIColor(red: 219/255.0, green: 45/255.0, blue: 105/255.0, alpha: 1.0) // special red background
            sender.setTitleColor(.white, for: .normal)
        } else {
            // ✅ Select
            selectedSeason.insert(season)
            sender.backgroundColor = UIColor(red: 219/255, green: 55/255, blue: 45/255, alpha: 1.0) // slightly different red
            sender.setTitleColor(UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0), for: .normal)
        }

        print("🎯 Selected Season: \(selectedSeason)")
    }

}


