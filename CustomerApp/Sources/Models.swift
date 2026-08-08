import SwiftUI
import Foundation

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Codable, Hashable {
    case electronics = "Electronics"
    case fashion     = "Fashion"
    case furniture   = "Furniture"
    case vehicles    = "Vehicles"
    case sports      = "Sports"
    case books       = "Books"
    case other       = "Other"

    var icon: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .fashion:     return "tshirt"
        case .furniture:   return "sofa"
        case .vehicles:    return "car"
        case .sports:      return "figure.run"
        case .books:       return "books.vertical"
        case .other:       return "tag"
        }
    }

    var subcategories: [String] {
        switch self {
        case .electronics: return ["iPhone","Samsung Phone","Pixel Phone","iPad","MacBook","Gaming Laptop","iMac","Apple Watch","AirPods","Monitor","TV","Miscellaneous"]
        case .fashion:     return ["Tops","Bottoms","Shoes","Bags","Accessories","Outerwear","Watches","Jewelry"]
        case .furniture:   return ["Sofa","Table","Chair","Bed","Storage","Desk","Shelving","Lighting"]
        case .vehicles:    return ["Car","Motorcycle","Bicycle","Scooter","Truck","Boat"]
        case .sports:      return ["Gym","Outdoor","Water Sports","Team Sports","Winter Sports","Cycling","Golf"]
        case .books:       return ["Textbooks","Fiction","Non-Fiction","Comics","Magazines","Science","History"]
        case .other:       return ["Collectibles","Art","Musical Instruments","Tools","Baby Items","Pet Supplies","Other"]
        }
    }

    // Required spec keys per subcategory (key, label, unit, isHighlightedOnCard)
    func requiredSpecs(for subcategory: String) -> [SpecTemplate] {
        switch self {
        case .electronics:
            switch subcategory {
            case "MacBook", "Gaming Laptop":
                return [
                    SpecTemplate(key: "battery_health", label: "Battery Health", unit: "%", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "ram",            label: "RAM",           unit: "GB", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "storage",        label: "Storage",       unit: "GB", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "chip",           label: "Chip / CPU",    unit: "",   isHighlighted: false, inputType: .text),
                    SpecTemplate(key: "cycles",         label: "Battery Cycles",unit: "",   isHighlighted: false, inputType: .number)
                ]
            case "iPhone", "Samsung Phone", "Pixel Phone":
                return [
                    SpecTemplate(key: "battery_health", label: "Battery Health", unit: "%", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "storage",        label: "Storage",        unit: "GB", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "color",          label: "Color",          unit: "",   isHighlighted: false, inputType: .text),
                    SpecTemplate(key: "carrier",        label: "Carrier",        unit: "",   isHighlighted: false, inputType: .text)
                ]
            case "iPad":
                return [
                    SpecTemplate(key: "storage",        label: "Storage",        unit: "GB", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "wifi_cellular",  label: "Wi-Fi / Cellular",unit: "",  isHighlighted: false, inputType: .text)
                ]
            case "iMac":
                return [
                    SpecTemplate(key: "ram",     label: "RAM",        unit: "GB", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "storage", label: "Storage",    unit: "GB", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "chip",    label: "Chip / CPU", unit: "",   isHighlighted: true, inputType: .text)
                ]
            case "Apple Watch", "AirPods":
                return [
                    SpecTemplate(key: "battery_health", label: "Battery Health", unit: "%", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "generation",     label: "Generation",     unit: "",  isHighlighted: false, inputType: .text)
                ]
            case "Monitor", "TV":
                return [
                    SpecTemplate(key: "size",       label: "Size",       unit: "\"", isHighlighted: true, inputType: .number),
                    SpecTemplate(key: "resolution", label: "Resolution", unit: "",   isHighlighted: true, inputType: .text),
                    SpecTemplate(key: "refresh",    label: "Refresh",    unit: "Hz", isHighlighted: false, inputType: .number)
                ]
            default:
                return []
            }
        case .vehicles:
            return [
                SpecTemplate(key: "year",     label: "Year",      unit: "",   isHighlighted: true, inputType: .number),
                SpecTemplate(key: "mileage",  label: "Mileage",   unit: "km", isHighlighted: true, inputType: .number),
                SpecTemplate(key: "color",    label: "Color",     unit: "",   isHighlighted: false, inputType: .text),
                SpecTemplate(key: "fuel",     label: "Fuel Type", unit: "",   isHighlighted: false, inputType: .text)
            ]
        default:
            return []
        }
    }
}

// MARK: - Spec Template (what info to collect when listing)
struct SpecTemplate: Identifiable {
    let id = UUID()
    let key: String
    let label: String
    let unit: String
    let isHighlighted: Bool   // shown on the listing card overlay
    let inputType: SpecInputType

    enum SpecInputType { case text, number }
}

// MARK: - Product Spec (saved on listing)
struct ProductSpec: Identifiable, Codable, Hashable {
    var id = UUID()
    let key: String
    let label: String
    let value: String
    let unit: String
    let isHighlighted: Bool
}

// MARK: - Item Condition
enum ItemCondition: String, CaseIterable, Codable {
    case brandNew  = "Brand New"
    case likeNew   = "Like New"
    case good      = "Good"
    case fair      = "Fair"
    case forParts  = "For Parts"

    var color: Color {
        switch self {
        case .brandNew: return Color(hex: "10B981")
        case .likeNew:  return Color(hex: "22D3EE")
        case .good:     return Color(hex: "6366F1")
        case .fair:     return Color(hex: "F59E0B")
        case .forParts: return Color(hex: "EF4444")
        }
    }

    var shortLabel: String {
        switch self {
        case .brandNew: return "New"
        case .likeNew:  return "Like New"
        case .good:     return "Good"
        case .fair:     return "Fair"
        case .forParts: return "Parts"
        }
    }
}

// MARK: - Listing
struct Listing: Identifiable, Codable {
    var id = UUID()
    var title: String
    var price: Double
    var description: String
    var category: ProductCategory
    var subcategory: String
    var location: String
    var city: String
    var imageColors: [String]  // placeholder hex colors (simulating images)
    var specs: [ProductSpec]
    var sellerId: UUID
    var sellerName: String
    var sellerUsername: String
    var isVerifiedSeller: Bool
    var condition: ItemCondition
    var createdAt: Date
    var isFeatured: Bool
    var isLiked: Bool = false

    var keySpecs: [ProductSpec] {
        specs.filter { $0.isHighlighted }.prefix(3).map { $0 }
    }

    var primaryColor: Color {
        Color(hex: imageColors.first ?? "6366F1")
    }

    var gradientColors: [Color] {
        imageColors.prefix(2).map { Color(hex: $0) }
    }

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 3600 { return "\(Int(diff/60))m ago" }
        else if diff < 86400 { return "\(Int(diff/3600))h ago" }
        else { return "\(Int(diff/86400))d ago" }
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$\(Int(price))"
    }
}

// MARK: - User
struct User: Identifiable, Codable {
    var id = UUID()
    var name: String
    var username: String
    var isVerifiedSeller: Bool
    var rating: Double
    var totalSales: Int
    var joinDate: Date
    var bio: String
    var location: String
    var avatarColor: String  // hex placeholder
    var totalListings: Int
}

// MARK: - Message
struct Message: Identifiable, Codable {
    var id = UUID()
    var senderId: UUID
    var senderName: String
    var text: String
    var timestamp: Date
    var listingId: UUID?
    var listingTitle: String?
    var isRead: Bool
}
