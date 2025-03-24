//
//  AnimeTableViewCell.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/19/25.
//
import UIKit

class AnimeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    static let identifier = "AnimeTableViewCell"
    
    var collectionView: UICollectionView!
    var animeData: [Anime] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Configure horizontal scrolling layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        layout.itemSize = CGSize(width: 150, height: 220) // Adjusting item size

        // Initialize collection view with the layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set the background color of the collection view (not the layout)
        // 1B1919 color
        collectionView.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0) // 1B1919 color
        
        collectionView.showsHorizontalScrollIndicator = false
        
        //collectionView.backgroundColor = .clear UNCOMMENT THIS FOR DEBUGGING
        
        collectionView.register(AnimeCollectionViewCell.self, forCellWithReuseIdentifier: AnimeCollectionViewCell.identifier)
        
        contentView.addSubview(collectionView)
        
        // Set constraints for collection view to fit inside table view cell
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animeData = []
        collectionView.reloadData()  // Ensures no stale data is displayed
    }
    
    // the function to configure the cell with the anime data.
    func configure(with anime: [Anime]) {
        self.animeData = anime
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            //print("AnimeTableViewCell configured with \(anime.count) items.")
        }
    }

    
    // MARK: - CollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCollectionViewCell.identifier, for: indexPath) as! AnimeCollectionViewCell
        let anime = animeData[indexPath.row]
        cell.configure(with: anime)
        return cell
    }
}
