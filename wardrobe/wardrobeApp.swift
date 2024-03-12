//
//  wardrobeApp.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 12.03.24.
//

import SwiftUI

@main
struct wardrobeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
