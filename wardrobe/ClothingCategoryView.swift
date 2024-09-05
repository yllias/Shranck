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
    @Binding var displayedItems: [String: Item]

    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = PhotoPickerViewModel()

    @FetchRequest private var items: FetchedResults<Item>

    init(category: String, displayedItems: Binding<[String: Item]>) {
        self.category = category
        self._displayedItems = displayedItems

        var categoryPredicate: NSPredicate {
            return NSPredicate(format: "category BEGINSWITH[c] %@", category)
        }
        _items = FetchRequest<Item>(sortDescriptors: [], predicate: categoryPredicate)
    }

    @State private var isGridVisible = false
    @State private var selectedItem: Item? = nil
    @State private var isShowingItemDetail = false
    @State private var isShowingPhotoPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea(.all)
                VStack (spacing: 5){
                    PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                        Text("+")
                            .font(.title)
                            .padding()
                            .foregroundColor(Color.black)
                    }
                    if !items.isEmpty {
                        ScrollView(.vertical) {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 10)
                            {
                                Image(uiImage: categoryToImage(categories: category))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .onTapGesture {
                                        print("tapped X")
                                        displayedItems[category] = nil
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                displayedItems[category] == nil
                                                    ? Color.gray : Color.clear
                                            )
                                            .opacity(0.25)
                                            .scaleEffect(1.05)
                                    )
                                ForEach(items) { item in
                                    if let imageData = item.image,
                                        let uiImage = UIImage(data: imageData)
                                    {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 150, height: 150)
                                            .onTapGesture {
                                                print("tapped")
                                                displayedItems[category] = item
                                            }
                                            .onLongPressGesture {
                                                print("long press")
                                                displayedItems[category] = item
                                                selectedItem = item
                                                if(selectedItem != nil) {
                                                    isShowingItemDetail = true
                                                }
                                            }
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        displayedItems[category] == item
                                                            ? Color.gray : Color.clear
                                                    )
                                                    .opacity(0.25)
                                                    .scaleEffect(1.05)
                                            )
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle("Your " + (category.contains("Acc") ? "Accessories" : category))
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
    
    public func categoryToImage(categories: String) -> UIImage {
        switch categories {
        case "Hats":
            return UIImage(named: "cap")!
        case "Accessories1":
            return UIImage(named: "tie")!
        case "Accessories2":
            return UIImage(named: "glasses")!
        case "Accessories3":
            return UIImage(named: "handbag")!
        case "Sweatshirts":
            return UIImage(named: "sweater")!
        case "Shirts":
            return UIImage(named: "tshirt")!
        case "Jacket":
            return UIImage(named: "jacket")!
        case "Pants":
            return UIImage(named: "jeansskirt")!
        case "Shoes":
            return UIImage(named: "sneakers")!
        default:
            return UIImage(systemName: "exclamationmark.triangle")!
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
