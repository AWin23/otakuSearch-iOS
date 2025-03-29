//
//  AnimeCollectionViewCell.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/19/25.
//
import UIKit
import SDWebImage

class AnimeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "AnimeCollectionViewCell"
    
    // Declrator for the Image Views in the Grid
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // Declare the Title Label for displaying the anime title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true  // Prevent content from overflowing
        
        // Configure the image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        // Configure the title label
        contentView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        // Constraints for layout
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 120),

            
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil // Prevents old images from flashing
        titleLabel.text = nil
    }
    
    
    // Setting up properties for the Anime title 
    func configure(with anime: Anime) {
        // Set the titleLabel text to the anime's English title if available, otherwise use the Romaji title.
        titleLabel.text = anime.title.english ?? anime.title.romaji
        
        // If the anime has a cover image URL, set the imageView to load that image from the URL.
        if let imageUrl = anime.coverImage.large {
            imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    
    // Override isSelected to change the background color when tapped
    override var isSelected: Bool {
        didSet {
            // Animate selection effect when tapped
            UIView.animate(withDuration: 0.2) {
                self.contentView.backgroundColor = self.isSelected ? UIColor.lightGray.withAlphaComponent(0.3) : .clear
            }
        }
    }
}
