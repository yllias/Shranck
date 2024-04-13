//
//  ClothingCategoryView.swift
//  wardrobe
//
//  Created by Yll Kryeziu on 13.03.24.
//

import CoreData
import PhotosUI
import SwiftUI
import Vision

@MainActor final class PhotoPickerViewModel: ObservableObject {
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet { if imageSelections != [] { setImages(from: imageSelections) } }
    }

    @State public var refresh = false

    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) { images.append(uiImage) }
                }
            }
            selectedImages = images
            imageSelections = []
        }
    }
}

struct ClothingCategoryView: View {
    let category: String
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = PhotoPickerViewModel()

    @FetchRequest private var items: FetchedResults<Item>

    init(category: String) {
        self.category = category
        var categoryPredicate: NSPredicate {
            return NSPredicate(format: "category == %d", argumentArray: [category])
        }
        _items = FetchRequest<Item>(sortDescriptors: [], predicate: categoryPredicate)
    }
    
    @State private var isGridVisible = false
    @State private var selectedItem: Item? = nil
    @State private var isShowingItemDetail = false
    @State private var isShowingPhotoPicker = false

    
    
    var body: some View {
        NavigationView {
            VStack {
                PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                    Image(systemName: "plus").font(.title).padding()
                }
                Button(action: { addRandom() }) { Text("Add Random") }
                if !items.isEmpty {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 10) {
                            ForEach(items) { item in
                                if let imageData = item.image,
                                    let uiImage = UIImage(data: imageData)
                                {
                                    Image(uiImage: uiImage).resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                        .onLongPressGesture {
                                            selectedItem = item
                                            isShowingItemDetail = true
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Your " + category)
        .onChange(of: viewModel.selectedImages) {
            for item in viewModel.selectedImages {
                guard let processed = liftSubject(image: item) else {
                    print("Error")
                    return
                }
                addItem(image: processed)
            }
        }
        .sheet(isPresented: $isShowingItemDetail) {
            if let selectedItem = selectedItem {
                ItemDetailView(item: selectedItem, isShowing: $isShowingItemDetail)
            }
        }
    }

    private func liftSubject(image: UIImage) -> UIImage? {
        guard let cgImage = convertUIImageToCGImage(image: image) else {
            print("Failed to convert UIImage to CGImage")
            return nil
        }
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
            guard let result = request.results?.first else {
                return nil
            }

            let output = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: true
            )

            let image = UIImage(ciImage: CIImage(cvPixelBuffer: output))
            return image
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    func convertUIImageToCGImage(image: UIImage) -> CGImage? {
        let inputImage = CIImage(image: image)
        let context = CIContext()
        if let inputImage = inputImage,
            let cgImage = context.createCGImage(inputImage, from: inputImage.extent)
        {
            return cgImage
        }
        return nil
    }

    private func addRandom() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.image = randomImageData()
            newItem.name = "kleidung"
            do { try viewContext.save() } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            print("Image created" + self.category)
        }
    }

    private func addItem(image: UIImage) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.image = image.pngData()
            newItem.category = category
            do { try viewContext.save() } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func randomImageData() -> Data? {
        let imageSize = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let randomColor = UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1
        )

        let image = renderer.image { context in
            randomColor.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))
        }

        return image.pngData()
    }
}
