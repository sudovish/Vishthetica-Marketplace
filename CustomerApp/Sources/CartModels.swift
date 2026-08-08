import Foundation
import SwiftUI

// MARK: - Cart Item
struct CartItem: Identifiable, Equatable {
    let id: UUID
    let listing: Listing

    init(listing: Listing) {
        self.id = UUID()
        self.listing = listing
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool { lhs.id == rhs.id }
}

// MARK: - Delivery Mode
enum DeliveryMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case pickup   = "Schedule Pickup"
    case delivery = "Free Delivery"

    var icon: String {
        switch self {
        case .pickup:   return "mappin.and.ellipse"
        case .delivery: return "shippingbox"
        }
    }
    var description: String {
        switch self {
        case .pickup:   return "Meet at seller's location"
        case .delivery: return "2-3 business days - Metro area"
        }
    }
    var priceLabel: String { "FREE" }
}

// MARK: - Pickup Time
enum PickupTime: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case morning   = "Morning (9am - 12pm)"
    case afternoon = "Afternoon (12pm - 5pm)"
    case evening   = "Evening (5pm - 8pm)"
}

// MARK: - Checkout Info
struct CheckoutInfo {
    var fullName:     String       = ""
    var phone:        String       = ""
    var address:      String       = ""
    var deliveryMode: DeliveryMode = .pickup
    var pickupTime:   PickupTime   = .morning
}

// MARK: - Checkout Step
enum CheckoutStep { case contact, summary, success }

// MARK: - Contact Seller
enum ContactType: String {
    case message = "Inquiry"
    case offer   = "Appeal Pricing"
}
