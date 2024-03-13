//
//  ClothingCategoryView.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 13.03.24.
//

import SwiftUI
import CoreData

struct ClothingCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [],
        animation: .easeInOut)
    private var items: FetchedResults<Item>
    let category: Int
    @State private var isGridVisible = false
    @State private var selectedItem: Item? = nil // Track selected item

    var body: some View {
            NavigationView {
                VStack {
                    Button(action: {
                        addItem()
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                    if !items.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 10) {
                            ForEach(items) { item in
                                if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .onLongPressGesture {
                                            selectedItem = item // Set selected item
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Wardrobe")
                .sheet(item: $selectedItem) { selectedItem in // Present ItemDetailView when selectedItem is not nil
                    ItemDetailView(item: selectedItem)
                }
                .onAppear {
                    isGridVisible = !items.isEmpty
                }
            }
        }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            if let imageData = randomImageData() {
                newItem.image = imageData
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
    
    private func randomImageData() -> Data? {
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

