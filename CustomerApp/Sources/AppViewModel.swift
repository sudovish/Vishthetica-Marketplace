import SwiftUI
import Combine

class AppViewModel: ObservableObject {

    // MARK: - Listings & User
    @Published var listings: [Listing]        = SampleData.listings
    @Published var currentUser: User          = SampleData.currentUser
    @Published var likedListingIDs: Set<UUID> = []
    @Published var selectedTab: Int           = 0
    @Published var showCreateListing: Bool    = false

    // MARK: - Cart
    @Published var cartItems: [CartItem]      = []
    @Published var showCart: Bool             = false
    @Published var showCheckout: Bool         = false
    @Published var checkoutStep: CheckoutStep = .contact
    @Published var checkoutInfo: CheckoutInfo = CheckoutInfo()
    @Published var lastOrderID: String        = ""

    // MARK: - Contact Seller
    @Published var showContactSeller: Bool    = false
    @Published var contactType: ContactType   = .message
    @Published var contactListing: Listing?   = nil

    // MARK: - Messaging unread
    var unreadMessageCount: Int {
        SampleConversations.all.reduce(0) { $0 + $1.unreadCount }
    }

    // MARK: - Filtering
    func listings(for category: ProductCategory?) -> [Listing] {
        guard let cat = category else { return listings }
        return listings.filter { $0.category == cat }
    }

    func searchListings(query: String, category: ProductCategory?) -> [Listing] {
        let base = listings(for: category)
        if query.isEmpty { return base }
        let q = query.lowercased()
        return base.filter {
            $0.title.lowercased().contains(q) ||
            $0.description.lowercased().contains(q) ||
            $0.subcategory.lowercased().contains(q) ||
            $0.specs.contains { $0.value.lowercased().contains(q) }
        }
    }

    // MARK: - Like / Save
    func toggleLike(listing: Listing) {
        if likedListingIDs.contains(listing.id) { likedListingIDs.remove(listing.id) }
        else { likedListingIDs.insert(listing.id) }
    }
    func isLiked(_ listing: Listing) -> Bool { likedListingIDs.contains(listing.id) }
    var savedListings: [Listing] { listings.filter { likedListingIDs.contains($0.id) } }

    // MARK: - Create
    func addListing(_ listing: Listing) {
        listings.insert(listing, at: 0)
    }

    var featuredListings: [Listing] { listings.filter { $0.isFeatured } }

    // MARK: - Cart Operations
    var cartTotal: Double { cartItems.reduce(0) { $0 + $1.listing.price } }

    var formattedCartTotal: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "CAD"
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: cartTotal)) ?? "$\(Int(cartTotal))"
    }

    func addToCart(_ listing: Listing) {
        guard !cartItems.contains(where: { $0.listing.id == listing.id }) else { return }
        cartItems.append(CartItem(listing: listing))
    }

    func removeFromCart(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }

    func clearCart() { cartItems.removeAll() }

    func isInCart(_ listing: Listing) -> Bool {
        cartItems.contains { $0.listing.id == listing.id }
    }

    // MARK: - Checkout
    func startCheckout() {
        checkoutStep  = .contact
        checkoutInfo  = CheckoutInfo()
        showCheckout  = true
    }

    func placeOrder() {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let code  = String((0..<8).map { _ in chars.randomElement()! })
        lastOrderID   = "VD-\(code)"
        checkoutStep  = .success
    }

    func finishOrder() {
        clearCart()
        showCheckout  = false
        checkoutStep  = .contact
    }

    // MARK: - Contact Seller
    func openContact(listing: Listing, type: ContactType) {
        contactListing    = listing
        contactType       = type
        showContactSeller = true
    }
}
