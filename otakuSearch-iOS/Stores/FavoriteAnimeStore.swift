//
//  FavoriteAnimeStore.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 6/3/25.
//

import CoreData
import UIKit

class FavoriteAnimeStore {
    static let shared = FavoriteAnimeStore()
    
    private init() {}
        
    // Computed property ensures safe access on main thread
    public var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // Save
    func saveFavorite(_ favorite: FavoriteAnime) {
        let entity = FavoriteAnimeEntity(context: context)
        entity.configure(from: favorite)

        do {
            try context.save()
            print("✅ Favorite saved locally")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }

    // Load favorites by AnimeID (access their details)
    func loadFavorites(by animeId: Int) -> FavoriteAnime? {
        print("LoadFavorites by Anime ID is called")
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "animeId == %d", animeId)

        do {
            let results = try context.fetch(request)
            return results.first?.toStruct()
        } catch {
            print("❌ Fetch failed: \(error)")
            return nil
        }
    }
    
    // Fetch all saved favorites
    func loadVisibleFavorites() -> [FavoriteAnime] {
        print("loadVisibleFavorites (Fetch all saved favorites) is called")
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isDeletedLocally == NO")

        do {
            let results = try context.fetch(request)

            for result in results {
                print("📦 Found animeId: \(result.animeId), favoriteId: \(result.favoriteId), isDeletedLocally: \(result.isDeletedLocally)")
            }

            return results.map { $0.toStruct() }
        } catch {
            print("❌ Fetch failed: \(error)")
            return []
        }
    }

    
    // Marks the Core Data for Deletion on Offline
    func markAsDeleted(animeId: Int) {
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "animeId == %d", animeId)

        do {
            if let result = try context.fetch(request).first {
                print("🗑 Found anime ID \(animeId) in Core Data. Marking as deleted.")
                result.isDeletedLocally = true
                try context.save()
                print("✅ Saved isDeletedLocally = true for anime ID \(animeId)")
            } else {
                print("⚠️ No Core Data record found for anime ID \(animeId)")
            }
        } catch {
            print("❌ Error while marking anime ID \(animeId) as deleted:", error)
        }
    }
    
    /// Checks if the backend is reachable via a lightweight health endpoint.
    func checkBackendAvailability(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:8080/health") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 3 // short timeout for quick failover

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    
    // function that calls the delete function
    func deleteFavorite(favoriteId: Int, animeId: Int, completion: @escaping () -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }

        // 🧠 Step 1: Check if we are connected to any network
        if NetworkMonitor.shared.isConnected {
            // 🌐 Connected to internet — now check if backend is reachable
            checkBackendAvailability { [weak self] isBackendReachable in
                guard let self = self else { return }

                if isBackendReachable {
                    // ✅ Backend is reachable — proceed with real DELETE request
                    let urlString = "http://localhost:8080/users/\(userId)/favorites/\(favoriteId)"
                    guard let url = URL(string: urlString) else {
                        print("❌ Invalid URL for delete")
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "DELETE"

                    URLSession.shared.dataTask(with: request) { _, response, error in
                        if let error = error {
                            print("❌ Backend delete failed:", error.localizedDescription)
                            return
                        }

                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                            print("❌ Backend delete returned status code \(httpResponse.statusCode)")
                            return
                        }

                        print("✅ Backend confirmed deletion for favorite ID \(favoriteId)")

                        // 🧹 Delete local Core Data entry using animeId
                        let context = FavoriteAnimeStore.shared.context
                        context.perform {
                            let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
                            request.predicate = NSPredicate(format: "animeId == %d", animeId)

                            do {
                                let results = try context.fetch(request)
                                results.forEach { context.delete($0) }

                                try context.save()
                                print("🗑 Deleted anime ID \(animeId) from Core Data (after backend confirmed)")
                            } catch {
                                print("❌ Core Data cleanup failed:", error)
                            }

                            DispatchQueue.main.async {
                                completion()
                            }
                        }
                    }.resume()
                } else {
                    // 🚨 Backend is unreachable even though we're online — fallback to local mark
                    print("⚠️ Backend unreachable: marking anime ID \(animeId) as locally deleted")
                    ToastManager.shared.show(message: "Backend unavailable — deletion will sync later.")
                    FavoriteAnimeStore.shared.markAsDeleted(animeId: animeId)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }

        } else {
            // 📴 No internet connection at all — mark as deleted locally
            print("📴 Offline mode: marking anime ID \(animeId) as locally deleted")
            ToastManager.shared.show(message: "Offline mode — deletion will sync when back online.")
            FavoriteAnimeStore.shared.markAsDeleted(animeId: animeId)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    
    
    
    /// Saves additional anime metadata (description, episodes, status, genres, studio) into Core Data.
    /// This is typically called after fetching anime details from the backend to persist them offline.
    func updateDetailInfo(
        animeId: Int,
        description: String?,
        episodes: Int?,
        status: String?,
        genres: [String]?,
        studio: String?,
        season: String?
    ) {
        // Create a fetch request to find the FavoriteAnimeEntity matching the given anime ID
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "animeId == %d", animeId)

        do {
            // If a matching entity exists, update its detail fields
            if let entity = try context.fetch(request).first {
                entity.animeDescription = description                        // Save description
                entity.episodes = Int16(episodes ?? 0)                       // Save episode count (default to 0 if nil)
                entity.status = status                                       // Save airing status
                entity.genres = (genres ?? []).joined(separator: ",")       // Save genres as a comma-separated string
                entity.studio = studio                                       // Save studio name
                entity.season = season                                       // Save season name

                try context.save()                                           // Persist changes to disk
                print("💾 Core Data updated with detailed info for anime ID \(animeId)")
            } else {
                // ⚠️ If no existing entity is found, log a warning
                print("⚠️ No Core Data entry found for anime ID \(animeId)")
            }
        } catch {
            // ❌ Log if saving fails due to Core Data error
            print("❌ Failed to update detail info:", error)
        }
    }


    
    /// Replaces the original version that cleared and re-saved Core Data
    func syncCoreDataWithBackend(_ backendFavorites: [FavoriteAnime]) {
        
        // cal it from favoriteAnime store
        let context = FavoriteAnimeStore.shared.context

        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()

        do {
            let coreDataFavorites = try context.fetch(request)

            // 🧼 Track local deletions using the 'isDeletedLocally' flag
            let locallyDeleted = coreDataFavorites.filter { $0.isDeletedLocally }
            let deletedFavorites = locallyDeleted.map { ($0.animeId, $0.favoriteId) }
            
            // Step X: Clean orphaned anime details (not in backend favorites)
            let existingIds = backendFavorites.map { $0.animeId }
            self.cleanUpOrphanedAnimeDetails(existingAnimeIds: existingIds)


            // Step 1: Delete from backend if anime is marked locally deleted but still exists in backend
            for favorite in backendFavorites {
                if deletedFavorites.contains(where: { $0.0 == favorite.animeId && $0.1 == favorite.favoriteId }) {
                    print("📡 (From FavoriteAnimeStore) Sending DELETE request to backend for anime ID \(favorite.animeId), favorite ID \(favorite.favoriteId)")

                    FavoriteAnimeStore.shared.deleteFavorite(
                        favoriteId: favorite.favoriteId,
                        animeId: favorite.animeId
                    ) {
                        print("✅ (sync) Successfully deleted favoriteId \(favorite.favoriteId) during sync")
                    }
                }
            }


            // Step 2: Clean up orphaned local entries — anime marked deleted but not found in backend anymore
            for entity in locallyDeleted {
                let animeId = Int(entity.animeId)
                if !backendFavorites.contains(where: { $0.animeId == animeId }) {
                    print("🗑 Cleaning orphaned Core Data entry for deleted anime ID \(animeId)")
                    context.delete(entity)
                }
            }

            // Step 3: Sync backend favorites into Core Data (skip any that are still flagged deleted)
            for favorite in backendFavorites {
                if let existing = coreDataFavorites.first(where: { Int($0.animeId) == favorite.animeId }) {
                    existing.configure(from: favorite)
                    existing.isDeletedLocally = false
                } else {
                    let newEntity = FavoriteAnimeEntity(context: context)
                    newEntity.configure(from: favorite)
                    newEntity.isDeletedLocally = false
                }
            }

            try context.save()
            print("✅ Core Data sync complete — all backend deletions and merges handled.")

        } catch {
            print("❌ Core Data fetch error during sync:", error)
        }
    }
    
    /// Loads detailed Anime info from Core Data for offline viewing.
    /// Called when the app is offline and a user taps into an anime detail.
    func loadDetailInfo(animeId: Int) -> AnimeDetail? {
        
        // Create a Core Data fetch request targeting FavoriteAnimeEntity with the matching anime ID
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "animeId == %d", animeId)

        do {
            // Attempt to fetch the first matching Core Data entity
            if let entity = try context.fetch(request).first {
                
                // Construct StudioContainer if the studio name was saved
                let studioContainer: AnimeDetail.StudioContainer
                if let savedStudioName = entity.studio, !savedStudioName.isEmpty {
                    // Wrap the studio name into the nested structure expected by AnimeDetail
                    let studio = AnimeDetail.Studio(name: savedStudioName)
                    let edge = AnimeDetail.StudioEdge(node: studio)
                    studioContainer = AnimeDetail.StudioContainer(edges: [edge])
                } else {
                    // No studio available — fallback to an empty edge list
                    studioContainer = AnimeDetail.StudioContainer(edges: [])
                }

                // Reconstruct the AnimeDetail object from saved fields
                return AnimeDetail(
                    id: animeId,
                    title: AnimeTitle(
                        romaji: entity.title ?? "",
                        english: entity.title ?? "" // Use romaji as fallback for English title
                    ),
                    description: entity.animeDescription,
                    episodes: Int(entity.episodes),
                    status: entity.status ?? "Unknown",
                    duration: nil,      // Not saved offline
                    season: entity.season,
                    favourites: nil,    // Not saved offline
                    genres: (entity.genres ?? "").components(separatedBy: ","),
                    studios: studioContainer,
                    coverImage: CoverImage(
                        medium: nil, // Medium not saved; use large only
                        large: entity.coverImageUrl ?? ""
                    )
                )
            }
        } catch {
            // Log if Core Data retrieval fails
            print("❌ Failed to load detail info from Core Data:", error)
        }

        // 🔙 Return nil if no entry was found or decoding failed
        return nil
    }


    
    
    /// Function to loop through and clean up orpahned anime details.
    func cleanUpOrphanedAnimeDetails(existingAnimeIds: [Int]) {
        // Create a Core Data fetch request targeting FavoriteAnimeEntity
        let context = self.context
        let fetchRequest: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()

        do {
            let allFavorites = try context.fetch(fetchRequest)
            
            for entity in allFavorites {
                let animeId = Int(entity.animeId)
                if !existingAnimeIds.contains(animeId) {
                    print("🗑 Deleting orphaned AnimeDetail for animeId: \(animeId)")
                    context.delete(entity) // This deletes the entire favorite + detail
                }
            }

            try context.save()
            print("✅ Finished cleaning up orphaned AnimeDetail entries.")

        } catch {
            print("❌ Error during orphaned AnimeDetail cleanup: \(error)")
        }
    }



    
    
    // Deletes the Favorite Anime in Core Data by ID
    func deleteFromCoreDataById(animeId: Int) {
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "animeId == %d", animeId)

        do {
            let results = try context.fetch(request)
            for result in results {
                context.delete(result)
                print("🗑 Deleted anime ID \(animeId) from Core Data (sync case)")
            }
            try context.save()
        } catch {
            print("❌ Core Data deletion failed for anime ID \(animeId):", error)
        }
    }



    // Clear All Core Data(for testing or Settings screen)
    func clearAllCoreDataFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteAnimeEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🧹 Core Data: All favorites cleared")
        } catch {
            print("❌ Failed to clear Core Data favorites: \(error)")
        }
    }

    
    // Logs the data of CoreData for the Anime Favorites (TEST ONLY)
    func logAllCoreDataFavorites() {
        let request: NSFetchRequest<FavoriteAnimeEntity> = FavoriteAnimeEntity.fetchRequest()

        do {
            let results = try context.fetch(request)
            print("📦 Core Data: Found \(results.count) saved favorites")
            for anime in results {
                print("(Core data entries) 📝 [\(anime.animeId)] \(anime.title ?? "Untitled")")
            }
        } catch {
            print("❌ Failed to fetch for logging: \(error)")
        }
    }

}
