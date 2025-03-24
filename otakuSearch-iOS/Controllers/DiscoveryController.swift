//
//  DiscoveryController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/15/25.
//

import UIKit

class DiscoveryController: UIViewController {
    
    let viewModel = DiscoveryViewModel() // initialize the view model to be the Discovery View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Trigger the "trending anime" fetch when the view loads
        viewModel.fetchTrendingAnime {
            print("Trending anime data has been fetched and updated.") // Confirm when data is fetched
        }
        
        // Trigger the "ucpoming" fetch when the view loads
        viewModel.fetchUpcomingAnime {
            print("Upcoming anime data has been fetched and updated.") // Confirm when data is fetched
        }
        
        // Trigger the "current popular" anime fetch when the view loads
        viewModel.fetchCurrentPopularAnime {
            print("Current Popular Anime has been fetched and updated.") // Confirm when data is fetched
        }
        
        // Trigger the "All-Time Popular" anime fetch when the view loads
        viewModel.fetchAllTimePopularAnime {
            print("Current All Time Popular Anime has been fetched and updated.") // Confirm when data is fetched
        }
        
        // Trigger the "Top 100 Popular" anime fetch when the view loads
        viewModel.fetchTop100Anime {
            print("Top 100 Popular Anime has been fetched and updated.") // Confirm when data is fetched
        }
    }
}


