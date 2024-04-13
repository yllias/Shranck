//
//  PhotoPicker.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 14.03.24.
//

import Foundation
import SwiftUI
import PhotosUI


struct PhotosSelector: View {
    @State var selectedImage: PhotosPickerItem?


    var body: some View {
        PhotosPicker(selection: $selectedImage,
                     matching: .images) {
            Text("Select Multiple Photos")
        }
    }
}
