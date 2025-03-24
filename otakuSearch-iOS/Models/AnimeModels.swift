//
//  AnimeModels.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/15/25.
//

import Foundation

// MARK: - Common Structs (Reused for Trending, Upcoming, All-Time, Top 100, etc.)

/// This struct represents the title information for the anime, including both its romaji and English title.
struct AnimeTitle: Codable {
    let romaji: String?
    let english: String?
}

/// This struct represents an individual anime entry, shared across multiple data types.
struct Anime: Codable {
    let id: Int
    let title: AnimeTitle
    let episodes: Int?
    let status: String
    let coverImage: AnimeCoverImage
}

struct AnimeCoverImage: Codable {
    let medium: String?  // Using medium resolution for grid layout
}

/// This struct represents the `Page` object which contains a list of anime items (`media`).
/// Used across multiple response types.
struct AnimePage: Codable {
    let media: [Anime]
}

/// This struct represents the `data` property in the response, containing the `Page` object.
/// Shared by multiple response types.
struct PageData: Codable {
    let Page: AnimePage
}

// MARK: - Trending Anime Models

/// This struct represents the top-level response structure for fetching trending anime data.
struct TrendingAnimeResponse: Codable {
    let data: PageData
}

// MARK: - Upcoming Anime Models

/// This struct represents the top-level response structure for fetching upcoming anime data.
struct UpcomingAnimeResponse: Codable {
    let data: PageData
}

// MARK: - Current Popular Anime Models

/// This struct represents the top-level response structure for fetching popular current anime data.
struct CurrentPopularAnimeResponse: Codable {
    let data: PageData
}

// MARK: - All-TIme Popular Anime Models

/// This struct represents the top-level response structure for fetching popular all-time anime data.
struct AllTimePopularAnimeResponse: Codable {
    let data: PageData
}

