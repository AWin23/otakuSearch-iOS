//
//  PersistenceController.swift
//  otakuSearch-iOS
//
//  Created by Andrew Nguyen on 6/3/25.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "otakuSearch_iOS") // ← Must match the .xcdatamodeld file name.
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Core Data failed to load: \(error)")
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
    }
}

