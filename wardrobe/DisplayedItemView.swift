import SwiftUI
import CoreData

struct DisplayedItemView: View {
    let category: category
    @Binding var displayedItems: [String: Item]
    
    var width: CGFloat {
            switch category {
            case .hats:
                return 100
            case .accessories1, .accessories2, .accessories3:
                return 80
            case .sweatshirts, .shirts:
                return 150
            case .jackets:
                return 170
            case .pants:
                return 275
            case .shoes:
                return 125
            }
        }

        var height: CGFloat {
            switch category {
            case .hats:
                return 100
            case .accessories1, .accessories2, .accessories3:
                return 80
            case .sweatshirts, .shirts:
                return 150
            case .jackets:
                return 170
            case .pants:
                return 275
            case .shoes:
                return 125
            }
        }

    var body: some View {
        NavigationLink(
            destination: ClothingCategoryView(
                category: category.rawValue,
                displayedItems: $displayedItems
            )
        ) {
            if let imageData = displayedItems[category.rawValue]?.image {
                viewForItem(imageData: imageData, width: 100, height: 100)
            } else {
                Image(uiImage: categoryToImage(categories: category.rawValue))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
            }
        }
    }
    
    func viewForItem(imageData: Data, width: CGFloat, height: CGFloat) -> some View {
        if let uiImage = UIImage(data: imageData) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
            )
        } else {
            return AnyView(Rectangle())
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
}
