//
//  ItemDetailView.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 13.03.24.
//

import Foundation
import SwiftUI
import CoreData

struct ItemDetailView: View {
    let item: Item
    
    var body: some View {
        VStack {
            if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
            }
            
            Text("Item Details")
                .font(.title)
                .padding()

            // Example of displaying additional item details
            Text("Item Name: \(item.name ?? "Unknown")")
                .padding()
            
            Spacer()
        }
        .navigationTitle("Item Detail")
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let previewItem = Item()
        previewItem.name = "Sample Item"
        
        return ItemDetailView(item: previewItem)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
