//
//  AnimeDetailModels.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/24/25.
//

import Foundation

/// Root response structure for decoding anime details from the API.
struct AnimeDetailResponse: Codable {
    let data: MediaContainer  /// Contains the `Media` object which holds actual anime details.
}

/// Wrapper struct to navigate through API's nested structure.
struct MediaContainer: Codable {
    let Media: AnimeDetail  /// The main anime details object.
}

/// Represents detailed information about an anime.
struct AnimeDetail: Codable {
    let id: Int  /// Unique identifier for the anime.
    let title: AnimeTitle  /// Contains titles in different languages.
    let description: String?  /// A textual description of the anime (optional).
    let episodes: Int?  /// Number of episodes (optional, since some anime are ongoing).
    let status: String /// Status of anime season
    let duration: Int?  /// Duration of each episode in minutes (optional).
    let season: String?  /// The airing season (e.g., "WINTER").
    let favourites: Int?  /// Number of users who marked this anime as a favorite (optional).
    let genres: [String]  /// List of genres the anime falls under.
    let studios: StudioContainer  /// Nested structure for studio information.
    let coverImage: CoverImage?  /// Stores image URLs for the anime (optional).


    /// Container for studio-related data.
    struct StudioContainer: Codable {
        let edges: [StudioEdge]  /// List of connections (edges) to studios.
    }

    /// Represents an edge in the studio connection structure.
    struct StudioEdge: Codable {
        let node: Studio  /// Contains the actual studio information.
    }

    /// Represents a studio that worked on the anime.
    struct Studio: Codable {
        let name: String  /// Name of the studio (e.g., "A-1 Pictures").
    }
}

/// Stores different sizes of cover images.
struct CoverImage: Codable {
    let medium: String?  /// Medium-sized cover image URL (optional).
    let large: String? /// Large-sized cover image URL
}
