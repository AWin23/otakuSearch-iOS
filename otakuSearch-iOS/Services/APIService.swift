//
//  APIService.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 3/15/25.
//

import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    // Function that calls the Trending Anime '/anime/trending'
    func fetchTrendingAnime(completion: @escaping (Result<[Anime], Error>) -> Void) {
        // Step 1: Ensure that the URL for the API endpoint is valid.
        guard let url = URL(string: "http://localhost:8080/anime/trending") else { return }
        
        print("Fetching trending anime from: \(url)") // Add this to confirm the request is made

        // Step 2: Create a URLRequest object to configure the request details, like HTTP method.
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Set the HTTP method to GET because we are fetching data.
        
        // Step 3: Start a network request using URLSession's dataTask method to perform the HTTP request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Step 4: Handle any errors that occur during the network request.
                print("Error occurred: \(error.localizedDescription)") // Add this to print any error
                completion(.failure(error))
                return
            }
            
            // Step 5: Ensure that data has been received from the server.
            guard let data = data else {
                print("No data received.") // If no data is received, print this
                return
            }
            
            // Step 6: Try to decode the received data into our defined structure.
            do {
                // Use a JSONDecoder to decode the raw JSON data into the TrendingAnimeResponse structure.
                // Decode the JSON Response to TrendingAnimeResponse
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(TrendingAnimeResponse.self, from: data)
                
                // Extract the media array directly from the response and return it
                // Step 7: Extract the list of trending anime from the decoded response object.
                let trendingAnime = responseObject.data.Page.media
                
                // Step 8: Call the completion handler with the fetched anime data wrapped in a success result.
                completion(.success(trendingAnime))
            } catch {
                print("No data received.") // If no data is received, print this
                completion(.failure(error))
            }
        }.resume() // Finally, resume the task to start the network request.
    }
    
    // Function that calls the Upcoming Anime '/anime/upcoming'
    func fetchUpcomingAnime(completion: @escaping (Result<[Anime], Error>) -> Void) {
        // Step 1: Ensure that the URL for the API endpoint is valid.
        guard let url = URL(string: "http://localhost:8080/anime/upcoming") else { return }
        
        print("Fetching upcoming anime from: \(url)") // Add this to confirm the request is made

        // Step 2: Create a URLRequest object to configure the request details, like HTTP method.
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Set the HTTP method to GET because we are fetching data.
        
        // Step 3: Start a network request using URLSession's dataTask method to perform the HTTP request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Step 4: Handle any errors that occur during the network request.
                print("Error occurred: \(error.localizedDescription)") // Add this to print any error
                completion(.failure(error))
                return
            }
            
            // Step 5: Ensure that data has been received from the server.
            guard let data = data else {
                print("No data received.") // If no data is received, print this
                return
            }
            
            // Step 6: Try to decode the received data into our defined structure.
            do {
                // Use a JSONDecoder to decode the raw JSON data into the UpcominggAnimeResponse structure.
                // Decode the JSON Response to UpcomingAnimeResponse
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(UpcomingAnimeResponse.self, from: data)
                
                // Extract the media array directly from the response and return it
                // Step 7: Extract the list of trending anime from the decoded response object.
                let upcomingAnime = responseObject.data.Page.media
                
                // Step 8: Call the completion handler with the fetched anime data wrapped in a success result.
                completion(.success(upcomingAnime))
            } catch {
                print("No data received.") // If no data is received, print this
                completion(.failure(error))
            }
        }.resume() // Finally, resume the task to start the network request.
    }
    
    // Function that calls the Current Popular Anime '/anime/popular'
    func fetchCurrentPopularAnime(completion: @escaping (Result<[Anime], Error>) -> Void) {
        // Step 1: Ensure that the URL for the API endpoint is valid.
        guard let url = URL(string: "http://localhost:8080/anime/popular") else { return }
        
        print("Fetching upcoming anime from: \(url)") // Add this to confirm the request is made

        // Step 2: Create a URLRequest object to configure the request details, like HTTP method.
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Set the HTTP method to GET because we are fetching data.
        
        // Step 3: Start a network request using URLSession's dataTask method to perform the HTTP request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Step 4: Handle any errors that occur during the network request.
                print("Error occurred: \(error.localizedDescription)") // Add this to print any error
                completion(.failure(error))
                return
            }
            
            // Step 5: Ensure that data has been received from the server.
            guard let data = data else {
                print("No data received.") // If no data is received, print this
                return
            }
            
            // Step 6: Try to decode the received data into our defined structure.
            do {
                // Use a JSONDecoder to decode the raw JSON data into the UpcominggAnimeResponse structure.
                // Decode the JSON Response to UpcomingAnimeResponse
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(CurrentPopularAnimeResponse.self, from: data)
                
                // Extract the media array directly from the response and return it
                // Step 7: Extract the list of Current Popular anime from the decoded response object.
                let currentPopularAnime = responseObject.data.Page.media
                
                // Step 8: Call the completion handler with the fetched anime data wrapped in a success result.
                completion(.success(currentPopularAnime))
            } catch {
                print("No data received.") // If no data is received, print this
                completion(.failure(error))
            }
        }.resume() // Finally, resume the task to start the network request.
    }
    
    
    // Function that calls the Current Popular Anime '/anime/top100'
    func fetchAllTimePopularAnime(completion: @escaping (Result<[Anime], Error>) -> Void) {
        // Step 1: Ensure that the URL for the API endpoint is valid.
        guard let url = URL(string: "http://localhost:8080/anime/all-time-popular") else { return }
        
        print("Fetching all-time popular anime from: \(url)") // Add this to confirm the request is made

        // Step 2: Create a URLRequest object to configure the request details, like HTTP method.
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Set the HTTP method to GET because we are fetching data.
        
        // Step 3: Start a network request using URLSession's dataTask method to perform the HTTP request.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Step 4: Handle any errors that occur during the network request.
                print("Error occurred: \(error.localizedDescription)") // Add this to print any error
                completion(.failure(error))
                return
            }
            
            // Step 5: Ensure that data has been received from the server.
            guard let data = data else {
                print("No data received.") // If no data is received, print this
                return
            }
            
            // Step 6: Try to decode the received data into our defined structure.
            do {
                // Use a JSONDecoder to decode the raw JSON data into the UpcominggAnimeResponse structure.
                // Decode the JSON Response to UpcomingAnimeResponse
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(AllTimePopularAnimeResponse.self, from: data)
                
                // Extract the media array directly from the response and return it
                // Step 7: Extract the list of Current Popular anime from the decoded response object.
                let allTimePopularAnime = responseObject.data.Page.media
                
                // Step 8: Call the completion handler with the fetched anime data wrapped in a success result.
                completion(.success(allTimePopularAnime))
            } catch {
                print("No data received.") // If no data is received, print this
                completion(.failure(error))
            }
        }.resume() // Finally, resume the task to start the network request.
    }
    
}
