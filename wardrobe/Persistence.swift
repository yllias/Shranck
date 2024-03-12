//
//  Persistence.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 12.03.24.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.name = "Sample Item"
            if let imageData = randomImageData() {
                newItem.image = imageData
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "wardrobe")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private static func randomImageData() -> Data? {
        let imageSize = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let randomColor = UIColor(red: .random(in: 0...1),
                                  green: .random(in: 0...1),
                                  blue: .random(in: 0...1),
                                  alpha: 1)
        
        let image = renderer.image { context in
            randomColor.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))
        }
        
        return image.pngData()
    }
}
