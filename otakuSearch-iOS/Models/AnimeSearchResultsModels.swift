//
//  AnimeSearchResultsModels.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/30/25.
//

// MARK: - Root search response
struct AnimeSearchAPIResponse: Codable {
    let data: AnimeSearchData
}

struct AnimeSearchData: Codable {
    let Page: AnimeSearchPage
}

struct AnimeSearchPage: Codable {
    let media: [AnimeSearchEntry]
}

// MARK: - Individual anime entry in search results
struct AnimeSearchEntry: Codable {
    let id: Int
    let title: AnimeSearchTitle
    let coverImage: AnimeSearchCoverImage
    let seasonYear: Int?
}

struct AnimeSearchTitle: Codable {
    let romaji: String?
    let english: String?
}

struct AnimeSearchCoverImage: Codable {
    let large: String
}


