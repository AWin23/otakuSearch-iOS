//
//  AnimeSearchResultsTableViewCell.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/30/25.
//

import UIKit

class AnimeSearchResultTableViewCell: UITableViewCell {

    static let identifier = "AnimeSearchResultTableViewCell"
    
    // Cover image
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    
    // Anime title label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 1.0) // #EFECEC
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    // Subtitle Label
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 239/255, green: 236/255, blue: 236/255, alpha: 0.7) // #EFECEC with slight transparency
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    // Initializer for programmatic cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        coverImageView.layer.cornerRadius = 8
        coverImageView.layer.masksToBounds = true

        
        // inject the title and cover image into the contentView
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)


        NSLayoutConstraint.activate([
            // Image constraints
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 80),
            coverImageView.heightAnchor.constraint(equalToConstant: 120),
                   
            // Anime Title Label constraints
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 45),

            // Subtitle (year) label constraints (just below the title)
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        
        contentView.backgroundColor = UIColor(red: 27/255, green: 25/255, blue: 25/255, alpha: 1.0) // #1B1919
        backgroundColor = UIColor(red: 27/255, green: 25/255, blue: 25/255, alpha: 1.0) // Match contentView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // Configure method to accept a String for title
    func configure(with title: String, imageURL: String, seasonYear: Int?) {
        titleLabel.text = title
        subtitleLabel.text = seasonYear != nil ? "📅 \(seasonYear!)" : "📅 Year Unknown"
        print("🧾 Configuring cell with title: \(title)")

        if let url = URL(string: imageURL) {
            fetchImage(from: url)
        } else {
            coverImageView.image = nil
        }
    }
    
    // Fetches the image
    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self?.coverImageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }


}

