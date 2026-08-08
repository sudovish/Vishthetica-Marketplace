import SwiftUI
import Combine

@MainActor
final class SellerViewModel: ObservableObject {
    @Published var profile: SellerProfile?
    @Published var backendState = SellerBackendState(
        isConnected: false,
        service: "unknown",
        backendKey: "unknown",
        version: nil,
        message: "Not checked"
    )

    @Published var listings: [SellerListing] = []
    @Published var orders: [SellerOrder] = []
    @Published var conversations: [SellerConversation] = []
    @Published var schedule = SellerSchedulePreferences(
        pickupEnabled: true,
        deliveryEnabled: true,
        sameDayDeliveryEnabled: false,
        defaultWindowStart: "12:00 PM",
        defaultWindowEnd: "5:00 PM",
        blockedDates: []
    )

    @Published var email = ""
    @Published var password = ""
    @Published var accessToken = ""
    @Published var refreshToken = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: SellerAPI

    init(api: SellerAPI = .shared) {
        self.api = api
    }

    var isSignedIn: Bool {
        !accessToken.isEmpty && profile != nil
    }

    var activeListings: [SellerListing] {
        listings.filter { $0.status == .active }
    }

    var openOrders: [SellerOrder] {
        orders.filter { $0.status != .delivered && $0.status != .cancelled }
    }

    var unreadMessageCount: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    func checkBackendHealth() async {
        do {
            let health = try await api.health()
            let version = try? await api.version()
            backendState = SellerBackendState(
                isConnected: true,
                service: health.service,
                backendKey: health.backendKey,
                version: version?.version,
                message: "Connected",
                environment: health.environment,
                publicBaseUrl: health.publicBaseUrl
            )
        } catch {
            backendState = SellerBackendState(
                isConnected: false,
                service: "unknown",
                backendKey: "unknown",
                version: nil,
                message: error.localizedDescription
            )
        }
    }

    func signIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await api.login(identifier: email, password: password)
            accessToken = session.accessToken
            refreshToken = session.refreshToken
            profile = session.seller?.sellerProfile
            try await reloadSellerData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restoreSession(accessToken: String, refreshToken: String) async {
        self.accessToken = accessToken
        self.refreshToken = refreshToken

        do {
            let me = try await api.me(token: accessToken)
            profile = me.user.sellerProfile
            try await reloadSellerData()
        } catch let error as SellerAPIError where error.shouldRefreshToken {
            await refreshSession()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshSession() async {
        guard !refreshToken.isEmpty else { return }

        do {
            let session = try await api.refreshSession(refreshToken: refreshToken)
            accessToken = session.accessToken
            self.refreshToken = session.refreshToken
            profile = session.seller?.sellerProfile
            try await reloadSellerData()
        } catch {
            signOut()
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        profile = nil
        accessToken = ""
        refreshToken = ""
        listings = []
        orders = []
        conversations = []
    }

    func reloadSellerData() async throws {
        guard !accessToken.isEmpty else { return }

        async let listingsTask = api.sellerListings(token: accessToken)
        async let ordersTask = api.sellerOrders(token: accessToken)
        async let conversationsTask = api.sellerConversations(token: accessToken)
        async let scheduleTask = api.sellerSchedule(token: accessToken)

        listings = try await listingsTask
        orders = try await ordersTask
        conversations = try await conversationsTask
        schedule = try await scheduleTask
    }

    func refreshListings() async {
        do {
            listings = try await api.sellerListings(token: accessToken)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshOrders() async {
        do {
            orders = try await api.sellerOrders(token: accessToken)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptOrder(_ order: SellerOrder) async {
        guard let backendID = order.backendID else { return }

        do {
            try await api.acceptOrder(id: backendID, token: accessToken)
            await refreshOrders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateOrder(_ order: SellerOrder, to status: SellerOrderStatus, paymentStatus: String? = nil) async {
        guard let backendID = order.backendID else { return }

        do {
            try await api.updateOrderStatus(
                id: backendID,
                status: status.backendValue,
                paymentStatus: paymentStatus,
                token: accessToken
            )
            await refreshOrders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateSchedule(_ preferences: SellerSchedulePreferences) async {
        do {
            try await api.updateSellerSchedule(preferences, token: accessToken)
            schedule = preferences
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openConversation(_ conversation: SellerConversation) async -> [SellerMessage] {
        do {
            let messages = try await api.sellerMessages(conversationId: conversation.id, token: accessToken)
            try? await api.markSellerConversationRead(conversationId: conversation.id, token: accessToken)
            conversations = conversations.map { item in
                item.id == conversation.id
                    ? SellerConversation(id: item.id, buyerName: item.buyerName, listingTitle: item.listingTitle, lastMessage: item.lastMessage, unreadCount: 0)
                    : item
            }
            return messages
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }

    func sendMessage(_ text: String, in conversation: SellerConversation) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            try await api.sendSellerMessage(conversationId: conversation.id, text: trimmed, token: accessToken)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
