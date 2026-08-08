import SwiftUI
import Foundation

// MARK: - Seller Roles

enum SellerAccountRole: String, Codable {
    case seller = "Seller"
    case admin = "Admin"
}

enum SellerApprovalStatus: String, Codable {
    case pending
    case approved
    case rejected
    case suspended

    var displayName: String {
        switch self {
        case .pending: return "Pending Approval"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .suspended: return "Suspended"
        }
    }
}

struct SellerProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var storeName: String
    var displayName: String
    var email: String
    var phone: String
    var location: String
    var role: SellerAccountRole
    var approvalStatus: SellerApprovalStatus
    var rating: Double
    var totalSales: Int

    var canPublishListings: Bool {
        approvalStatus == .approved || role == .admin
    }

    var isAdmin: Bool {
        role == .admin
    }
}

// MARK: - Listings

enum SellerListingStatus: String, CaseIterable, Codable {
    case active = "Active"
    case reserved = "Reserved"
    case pending = "Offer Pending"
    case sold = "Sold"
    case draft = "Draft"
    case archived = "Archived"

    var color: Color {
        switch self {
        case .active: return Color(hex: "10B981")
        case .reserved: return Color(hex: "2DD4BF")
        case .pending: return Color(hex: "F59E0B")
        case .sold: return Color(hex: "6366F1")
        case .draft: return Color(hex: "6B7280")
        case .archived: return Color(hex: "374151")
        }
    }
}

enum SellerPriceType: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }

    case firm = "Firm Price"
    case negotiable = "Open to Offers"
    case range = "Price Range"

    var backendValue: String {
        switch self {
        case .firm: return "firm"
        case .negotiable: return "negotiable"
        case .range: return "range"
        }
    }
}

struct SellerSpec: Identifiable, Hashable, Codable {
    var id = UUID()
    var key: String
    var label: String
    var value: String
    var unit: String
    var isRequired: Bool
    var isHighlighted: Bool

    var displayValue: String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let cleanUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUnit.isEmpty else { return trimmed }
        if trimmed.lowercased().contains(cleanUnit.lowercased()) { return trimmed }
        return "\(trimmed)\(cleanUnit)"
    }
}

struct SellerListingMedia: Identifiable, Hashable, Codable {
    var id: String
    var type: String
    var url: URL
    var thumbnailURL: URL?
    var sortOrder: Int

    var previewURL: URL {
        thumbnailURL ?? url
    }

    var isVideo: Bool {
        type.lowercased().contains("video")
    }
}

struct SellerListing: Identifiable, Codable {
    var id = UUID()
    var backendID: String? = nil
    var sellerId: UUID
    var title: String
    var price: Double
    var discountPrice: Double? = nil
    var priceType: SellerPriceType
    var priceRangeMin: Double?
    var priceRangeMax: Double?
    var category: String
    var subcategory: String
    var condition: String
    var description: String
    var specs: [SellerSpec]
    var tags: [String]
    var imageColors: [String]
    var location: String
    var city: String
    var status: SellerListingStatus
    var quantity: Int
    var reservedOrderNumber: String? = nil
    var views: Int
    var createdAt: Date
    var isFeatured: Bool
    var deliveryAvailable: Bool
    var pickupAvailable: Bool
    var sameDayAvailable: Bool
    var media: [SellerListingMedia]

    var isHiddenFromCustomerApp: Bool {
        status == .reserved || status == .sold || status == .archived || quantity <= 0
    }

    var formattedPrice: String {
        formatted(price)
    }

    var formattedDiscountPrice: String? {
        guard let discountPrice, discountPrice > 0, discountPrice < price else { return nil }
        return formatted(discountPrice)
    }

    var displayPrice: String {
        switch priceType {
        case .firm:
            return formattedDiscountPrice ?? formattedPrice
        case .negotiable:
            return (formattedDiscountPrice ?? formattedPrice) + " (OBO)"
        case .range:
            let low = formatted(priceRangeMin ?? price)
            let high = formatted(priceRangeMax ?? price)
            return "\(low) - \(high)"
        }
    }

    var compactSpecsLine: String {
        specs
            .filter { $0.isHighlighted }
            .map(\.displayValue)
            .filter { !$0.isEmpty }
            .prefix(3)
            .joined(separator: " / ")
    }

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }
}

// MARK: - Orders

enum SellerOrderStatus: String, CaseIterable, Codable {
    case processing = "Order Placed"
    case confirmed = "Confirmed"
    case inTransit = "On My Way"
    case readyPickup = "Ready for Pickup"
    case delivered = "Sale Complete"
    case cancelled = "Cancelled"

    var backendValue: String {
        switch self {
        case .processing: return "processing"
        case .confirmed: return "confirmed"
        case .inTransit: return "in_transit"
        case .readyPickup: return "ready_pickup"
        case .delivered: return "completed"
        case .cancelled: return "cancelled"
        }
    }
}

enum SellerPaymentMethod: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }

    case cashOnPickup = "Cash"
    case eTransfer = "E-Transfer"

    var backendValue: String {
        switch self {
        case .cashOnPickup: return "cash"
        case .eTransfer: return "etransfer"
        }
    }
}

struct SellerCharge: Identifiable, Hashable, Codable {
    var id = UUID()
    var label: String
    var amount: Double
}

struct SellerOrder: Identifiable, Codable {
    var id = UUID()
    var backendID: String? = nil
    var sellerId: UUID
    var orderNumber: String
    var listingId: UUID? = nil
    var listingTitle: String
    var buyerName: String
    var buyerPhone: String? = nil
    var buyerEmail: String? = nil
    var price: Double
    var deliveryMode: String
    var status: SellerOrderStatus
    var createdAt: Date
    var deliveryAddress: String?
    var pickupTime: String?
    var scheduledDate: Date
    var windowStart: String
    var windowEnd: String
    var deliveryFee: Double
    var customCharges: [SellerCharge]
    var discountAmount: Double
    var paymentMethod: SellerPaymentMethod
    var quantity: Int
    var customerNotes: String? = nil

    var total: Double {
        price + deliveryFee + customCharges.reduce(0) { $0 + $1.amount } - discountAmount
    }

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: total)) ?? "$\(Int(total))"
    }
}

// MARK: - Messaging And Schedule

struct SellerMessage: Identifiable, Codable, Equatable {
    var id: UUID
    var conversationId: String
    var senderName: String
    var body: String
    var timestamp: Date
    var isFromCurrentSeller: Bool
    var isRead: Bool
}

struct SellerConversation: Identifiable, Codable {
    var id: String
    var buyerName: String
    var listingTitle: String?
    var lastMessage: SellerMessage?
    var unreadCount: Int
}

struct SellerSchedulePreferences: Codable, Equatable {
    var pickupEnabled: Bool
    var deliveryEnabled: Bool
    var sameDayDeliveryEnabled: Bool
    var defaultWindowStart: String
    var defaultWindowEnd: String
    var blockedDates: [Date]
}

struct SellerBackendState: Equatable {
    var isConnected: Bool
    var service: String
    var backendKey: String
    var version: String?
    var message: String
    var environment: String? = nil
    var publicBaseUrl: String? = nil
}
