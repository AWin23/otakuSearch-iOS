//
//  DiscoveryViewModel.swift
//  otakuSearch-iOS
//  DiscoveryViewModel handles data fetching. 
//  Created by Andrew Nguyen on 3/15/25.
//

import Foundation

class DiscoveryViewModel {
    
    // Arrays to store anime data for different categories
    var trendingAnime: [Anime] = [] // Trending anime list
    var upcomingAnime: [Anime] = [] // Upcoming anime list
    var currentPopularAnime: [Anime] = [] // Popular anime list
    var allTimePopularAnime: [Anime] = [] // All-time popular anime list
    
    /// Fetches trending anime from the API and updates the `trendingAnime` array.
    /// Calls the completion handler after data is retrieved and updated.
    func fetchTrendingAnime(completion: @escaping () -> Void) {
        print("[DEBUG] Fetching trending anime from API...") // Debugging fetch initiation
        
        APIService.shared.fetchTrendingAnime { result in
            switch result {
            case .success(let anime):
                print("[DEBUG] Successfully fetched trending anime: \(anime.count) items") // Debugging fetched count
                
                // Store fetched data in the trendingAnime array
                self.trendingAnime = anime
                
                DispatchQueue.main.async {
                    completion() // Notify UI to refresh data
                }
                
            case .failure(let error):
                print("[ERROR] Failed to fetch trending anime: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetches upcoming anime from the API and updates the `upcomingAnime` array.
    /// Calls the completion handler after data is retrieved and updated.
    func fetchUpcomingAnime(completion: @escaping () -> Void) {
        print("[DEBUG] Fetching upcoming anime from API...") // Debugging fetch initiation
        
        APIService.shared.fetchUpcomingAnime { result in
            switch result {
            case .success(let anime):
                print("[DEBUG] Successfully fetched upcoming anime: \(anime.count) items") // Debugging fetched count
                
                // Store fetched data in the upcomingAnime array
                self.upcomingAnime = anime
                
                DispatchQueue.main.async {
                    completion() // Notify UI to refresh data
                }
                
            case .failure(let error):
                print("[ERROR] Failed to fetch upcoming anime: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetches currently popular anime from the API and updates the `currentPopularAnime` array.
    /// Calls the completion handler after data is retrieved and updated.
    func fetchCurrentPopularAnime(completion: @escaping () -> Void) {
        print("[DEBUG] Fetching current popular anime from API...") // Debugging fetch initiation
        
        APIService.shared.fetchCurrentPopularAnime { result in
            switch result {
            case .success(let anime):
                print("[DEBUG] Successfully fetched popular anime: \(anime.count) items") // Debugging fetched count
                
                // Store fetched data in the currentPopularAnime array
                self.currentPopularAnime = anime
                
                DispatchQueue.main.async {
                    completion() // Notify UI to refresh data
                }
                
            case .failure(let error):
                print("[ERROR] Failed to fetch current popular anime: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetches All Time Popular anime from the API and updates the `AllTimePopularAnime` array.
    /// Calls the completion handler after data is retrieved and updated.
    func fetchAllTimePopularAnime(completion: @escaping () -> Void) {
        print("[DEBUG] Fetching All Time Popular anime from API...") // Debugging fetch initiation
        
        APIService.shared.fetchAllTimePopularAnime { result in
            switch result {
            case .success(let anime):
                print("[DEBUG] Successfully fetched All Time Popular anime: \(anime.count) items") // Debugging fetched count
                
                // Store fetched data in the AllTimePopularAnime array
                self.allTimePopularAnime = anime
                
                DispatchQueue.main.async {
                    completion() // Notify UI to refresh data
                }
                
            case .failure(let error):
                print("[ERROR] Failed to fetch All TIme popular anime: \(error.localizedDescription)")
            }
        }
    }
}


