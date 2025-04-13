import UIKit

/// A UITableViewCell that displays a user's favorite anime with an image and title.
/// Used in AnimeController to build the Favorites page UI.
class FavoriteAnimeCell: UITableViewCell {
    
    // MARK: - UI Components

    /// The image view that displays the anime cover.
    private let animeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    /// The label that displays the anime title.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Initializer

    /// Initializes the custom cell and its layout.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Background color (optional): cell should blend in with dark background
        backgroundColor = .clear
                
        // Anime Image View
        animeImageView.contentMode = .scaleAspectFill
        animeImageView.clipsToBounds = true
        animeImageView.layer.cornerRadius = 8
        animeImageView.translatesAutoresizingMaskIntoConstraints = false
        
                
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#efecec")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews
        contentView.addSubview(animeImageView)
        contentView.addSubview(titleLabel)

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            animeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            animeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            animeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            animeImageView.widthAnchor.constraint(equalToConstant: 70),
            animeImageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.leadingAnchor.constraint(equalTo: animeImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: animeImageView.centerYAnchor)
        ])
    }

    /// Required initializer for storyboard (not used here).
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Configures the cell with anime data.
    /// - Parameter anime: A `FavoriteAnime` object containing title and image URL.
    func configure(with anime: FavoriteAnime) {
        titleLabel.text = anime.title
        if let url = URL(string: anime.coverImageUrl) {
            loadImage(from: url)
        }
    }

    /// Loads and sets the anime image asynchronously from a URL.
    /// - Parameter url: The cover image URL to load.
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.animeImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
