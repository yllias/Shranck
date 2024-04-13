//
//  ItemDetailView.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 13.03.24.
//

import CoreData
import Foundation
import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @Binding var isShowing: Bool
    

    @Environment(\.managedObjectContext) private var viewContext
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

            Text("Item Name: \(item.name ?? "Unknown")")
                .padding()
            
            Text("Item Category: \(item.category ?? "Unknown")")
                .padding()

            Spacer()
            Image(systemName: "trash")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.red)
                .padding()
                .onTapGesture {
                    removeItem(item)
                    isShowing = false
                }
        }
        .navigationTitle("Item Detail")
    }

    private func removeItem(_ item: Item) {
        withAnimation {
            viewContext.delete(item)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
