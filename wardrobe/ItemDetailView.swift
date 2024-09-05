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
    @State private var itemName: String
    @State private var itemPrice: Float
    @State private var itemBrand: String

    init(item: Item, isShowing: Binding<Bool>) {
        self.item = item
        self._isShowing = isShowing
        _itemName = State(initialValue: item.name ?? "")
        _itemPrice = State(initialValue: item.price)
        _itemBrand = State(initialValue: item.brand ?? "")
    }

    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea(.all)
            VStack {
                Text("Item Details")
                    .font(.title)
                    .padding()
                    .foregroundColor(Color.black)
                if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding()
                }

                Text("Item Category: \(item.category ?? "Unknown")")
                    .padding()
                    .foregroundColor(Color.black)

                TextField("Name", text: $itemName)
                    .padding()
                    .foregroundColor(Color.black)

                TextField("Brand", text: $itemBrand)
                    .keyboardType(.decimalPad)
                    .padding()
                    .foregroundColor(Color.black)

                TextField("Price", value: $itemPrice, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .padding()
                    .foregroundColor(Color.black)

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
