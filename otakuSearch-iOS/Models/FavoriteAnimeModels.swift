//
//  FavoriteAnimeModels.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/12/25.
//

struct FavoriteAnime: Codable {
    let favoriteId: Int 
    let animeId: Int
    let title: String
    let coverImageUrl: String
    
    // Optional Fields as they will be saved to the Core Data
    let description: String?
    let season: String?
    let episodes: Int?
    let status: String?
    let genres: [String]?
    let studio: String?
    
    // Local-only field (not from backend)
    var isDeletedLocally: Bool? = false
    
}
