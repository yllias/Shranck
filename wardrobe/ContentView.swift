//
//  ContentView.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 12.03.24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack (spacing: 200){
                Text("Hat")
                    .background(
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .padding()
                            .border(Color.gray, width: 2)
                    )
                
                Text("Shirt")
                    .background(
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .padding()
                            .border(Color.gray, width: 2)
                    )
                NavigationLink(destination: ClothingCategoryView(category: 3)) {
                    Text("Pants")
                        .background(
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .padding()
                                .border(Color.gray, width: 2)
                        )
                }
                
            }
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
