//
//  ContentView.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 12.03.24.
//

import CoreData
import SwiftUI

enum category: String {
    case hats = "Hats"
    case accessories1 = "Accessories1"
    case accessories2 = "Accessories2"
    case accessories3 = "Accessories3"
    case sweatshirts = "Sweatshirts"
    case shirts = "Shirts"
    case jackets = "Jacket"
    case pants = "Pants"
    case shoes = "Shoes"
}

let viewContext = PersistenceController.shared.container.viewContext
let hatItem = Item(context: viewContext)
let acc1Item = Item(context: viewContext)
let acc2Item = Item(context: viewContext)
let acc3Item = Item(context: viewContext)
let sweatshirtItem = Item(context: viewContext)
let shirtItem = Item(context: viewContext)
let jacketItem = Item(context: viewContext)
let pantsItem = Item(context: viewContext)
let shoesItem = Item(context: viewContext)

struct ContentView: View {
    @State var displayedItems = [
        category.hats.rawValue: hatItem,
        category.accessories1.rawValue: acc1Item,
        category.accessories2.rawValue: acc2Item,
        category.accessories3.rawValue: acc3Item,
        category.sweatshirts.rawValue: sweatshirtItem,
        category.shirts.rawValue: shirtItem,
        category.jackets.rawValue: jacketItem,
        category.pants.rawValue: pantsItem,
        category.shoes.rawValue: shoesItem
    ]
    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea(.all)
                VStack(spacing: -10) {
                    Image("titleText")
                        .resizable()
                        .frame(width: 350, height: 80)
                        .aspectRatio(contentMode: .fit)
                    Spacer()
                        .padding()
                    DisplayedItemView(category: .hats, displayedItems: $displayedItems)
                    HStack {
                        DisplayedItemView(category: .accessories1, displayedItems: $displayedItems)
                        DisplayedItemView(category: .accessories2, displayedItems: $displayedItems)
                        DisplayedItemView(category: .accessories3, displayedItems: $displayedItems)
                    }
                    ScrollView(.horizontal) {
                        LazyHStack (spacing: -5){
                            DisplayedItemView(category: .sweatshirts, displayedItems: $displayedItems)
                            .scrollTransition(axis: .horizontal) {
                                content, phase in
                                content
                                    .rotation3DEffect(.degrees(phase.value * 45), axis: (x: 0, y: 2, z: 0))
                                    .scaleEffect(
                                    x: phase.isIdentity ? 1 : 0.8,
                                    y: phase.isIdentity ? 1 : 0.8)
                            }
                            DisplayedItemView(category: .shirts, displayedItems: $displayedItems)
                            .scrollTransition(axis: .horizontal) {
                                content, phase in
                                content
                                    .rotation3DEffect(.degrees(phase.value * 45), axis: (x: 0, y: 2, z: 0))
                                    .scaleEffect(
                                    x: phase.isIdentity ? 1 : 0.8,
                                    y: phase.isIdentity ? 1 : 0.8)
                            }
                            DisplayedItemView(category: .jackets, displayedItems: $displayedItems)
                            .scrollTransition(axis: .horizontal) {
                                content, phase in
                                content
                                    .rotation3DEffect(.degrees(phase.value * 45), axis: (x: 0, y: 2, z: 0))
                                    .scaleEffect(
                                    x: phase.isIdentity ? 1 : 0.8,
                                    y: phase.isIdentity ? 1 : 0.8)
                            }
                        }
                    }
                    .frame(height: 175)
                    .contentMargins(50)
                    .scrollIndicators(ScrollIndicatorVisibility.never)
                    
                    DisplayedItemView(category: .pants, displayedItems: $displayedItems)
                    DisplayedItemView(category: .shoes, displayedItems: $displayedItems)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
