import Foundation

struct SampleConversation {
    var unreadCount: Int
}

enum SampleConversations {
    static let all: [SampleConversation] = [
        SampleConversation(unreadCount: 2),
        SampleConversation(unreadCount: 0)
    ]
}

enum SampleData {
    static let sellerID = UUID()

    static let currentUser = User(
        name: "Vishnav",
        username: "@sudovish",
        isVerifiedSeller: true,
        rating: 4.9,
        totalSales: 128,
        joinDate: Date(),
        bio: "Local tech marketplace builder.",
        location: "Toronto, ON",
        avatarColor: "6366F1",
        totalListings: 14
    )

    static let listings: [Listing] = [
        Listing(
            title: "MacBook Pro 14-inch M3 Pro",
            price: 2199,
            description: "Clean MacBook Pro with strong battery health, Apple silicon performance, and a ready-to-use setup for school, work, or editing.",
            category: .electronics,
            subcategory: "MacBook",
            location: "Downtown Toronto",
            city: "Toronto",
            imageColors: ["1E1B4B", "6366F1"],
            specs: [
                ProductSpec(key: "chip", label: "Chip", value: "M3 Pro", unit: "", isHighlighted: true),
                ProductSpec(key: "ram", label: "RAM", value: "18", unit: "GB", isHighlighted: true),
                ProductSpec(key: "storage", label: "Storage", value: "512", unit: "GB", isHighlighted: true),
                ProductSpec(key: "battery_health", label: "Battery Health", value: "96", unit: "%", isHighlighted: false)
            ],
            sellerId: sellerID,
            sellerName: "Vishthetica Deals",
            sellerUsername: "@vishtheticadeals",
            isVerifiedSeller: true,
            condition: .likeNew,
            createdAt: Date().addingTimeInterval(-3600),
            isFeatured: true
        ),
        Listing(
            title: "iPhone 15 Pro 256GB",
            price: 999,
            description: "Unlocked iPhone 15 Pro with clean body, strong battery health, and original box.",
            category: .electronics,
            subcategory: "iPhone",
            location: "North York",
            city: "Toronto",
            imageColors: ["0F172A", "14B8A6"],
            specs: [
                ProductSpec(key: "storage", label: "Storage", value: "256", unit: "GB", isHighlighted: true),
                ProductSpec(key: "battery_health", label: "Battery Health", value: "91", unit: "%", isHighlighted: true),
                ProductSpec(key: "carrier", label: "Carrier", value: "Unlocked", unit: "", isHighlighted: true)
            ],
            sellerId: sellerID,
            sellerName: "Vishthetica Deals",
            sellerUsername: "@vishtheticadeals",
            isVerifiedSeller: true,
            condition: .good,
            createdAt: Date().addingTimeInterval(-7200),
            isFeatured: false
        )
    ]
}
