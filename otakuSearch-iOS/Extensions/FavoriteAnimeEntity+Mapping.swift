//
//  FavoriteAnimeEntity+Mapping.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 6/3/25.
//

import Foundation

extension FavoriteAnimeEntity {
    func configure(from favorite: FavoriteAnime) {
        self.favoriteId = Int64(favorite.favoriteId)
        self.animeId = Int64(favorite.animeId)
        self.title = favorite.title
        self.coverImageUrl = favorite.coverImageUrl
        
        self.isDeletedLocally = false // default to false when saving
        
        // Optional Fields, will be saved into Core Data
        self.animeDescription = favorite.description
        self.season = favorite.season
        self.episodes = Int16(favorite.episodes ?? 0)
        self.status = favorite.status
        self.studio = favorite.studio
        self.genres = (favorite.genres ?? []).joined(separator: ",")  // ✅ safe unwrap here
    }

    func toStruct() -> FavoriteAnime {
        return FavoriteAnime(
            favoriteId: Int(self.favoriteId),
            animeId: Int(self.animeId),
            title: self.title ?? "",
            coverImageUrl: self.coverImageUrl ?? "",
            
            // Optional Fields, will be saved into Core Data
            description: self.animeDescription,
            season: self.season,
            episodes: Int(self.episodes),
            status: self.status ?? "",
            genres: (self.genres ?? "").components(separatedBy: ","),
            studio: self.studio,

            // manual assisment of local-only field
            isDeletedLocally: self.isDeletedLocally
        )
    }
}


