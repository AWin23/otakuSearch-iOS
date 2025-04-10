//
//  AnimeFilterParamterModels.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 4/7/25.
//
struct FilteredAnimeResponse: Codable {
    let data: PageWrapper
}

struct PageWrapper: Codable {
    let Page: MediaWrapper
}

struct MediaWrapper: Codable {
    let media: [FilteredAnime]
}

struct FilteredAnime: Codable {
    let id: Int
    let title: Title
    let episodes: Int?
    let status: String?
    let genres: [String]?
    let averageScore: Int?
    let coverImage: FilteredAnimeCoverImage
}

struct FilteredAnimeCoverImage: Codable {
    let large: String?  // Using medium resolution for grid layout
}

struct Title: Codable {
    let romaji: String
    let english: String?
}


