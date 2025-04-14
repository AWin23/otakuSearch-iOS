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
}
