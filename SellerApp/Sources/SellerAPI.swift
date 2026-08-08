import Foundation

// MARK: - API Errors

enum SellerAPIError: LocalizedError {
    case invalidResponse
    case wrongBackend(service: String?, backendKey: String?)
    case server(errorCode: String, message: String, debugId: String?, httpStatus: Int?, rawBody: String?)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .wrongBackend(let service, let backendKey):
            return "Wrong backend identity: \(service ?? "unknown") / \(backendKey ?? "unknown")."
        case .server(let errorCode, let message, let debugId, let httpStatus, let rawBody):
            let status = httpStatus.map { "HTTP \($0): " } ?? ""
            let raw = rawBody.map { "\nResponse: \($0)" } ?? ""
            if let debugId, !debugId.isEmpty {
                return "\(status)\(message) (\(errorCode), \(debugId))\(raw)"
            }
            return "\(status)\(message) (\(errorCode))\(raw)"
        }
    }

    var errorCode: String? {
        if case .server(let errorCode, _, _, _, _) = self { return errorCode }
        return nil
    }

    var shouldRefreshToken: Bool {
        guard let code = errorCode?.uppercased() else { return false }
        return code.contains("UNAUTHORIZED") || code.contains("AUTH_EXPIRED") || code.contains("TOKEN_EXPIRED") || code.contains("AUTH_INVALID")
    }

    var isMissingRoute: Bool {
        guard case .server(_, _, _, let httpStatus, _) = self else { return false }
        return httpStatus == 404 || httpStatus == 405
    }
}

// MARK: - API Client

final class SellerAPI {
    static let shared = SellerAPI()
    static let baseURL = URL(string: "https://api-deals.vishthetica.ca")!
    static let adminDashboardURL = baseURL.appendingPathComponent("admin/dashboard")

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder = JSONEncoder()

    init(session: URLSession = .shared) {
        self.session = session
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = fractional.date(from: value) { return date }

            let standard = ISO8601DateFormatter()
            standard.formatOptions = [.withInternetDateTime]
            if let date = standard.date(from: value) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(value)")
        }
    }

    func health() async throws -> SellerHealthResponse {
        let response: SellerHealthResponse = try await request("GET", path: "/health")
        guard response.service == "visthetica-api", response.backendKey == "visthetica-deals-backend" else {
            throw SellerAPIError.wrongBackend(service: response.service, backendKey: response.backendKey)
        }
        return response
    }

    func version() async throws -> SellerVersionResponse {
        try await request("GET", path: "/version")
    }

    func login(identifier: String, password: String) async throws -> SellerAuthSession {
        try await request("POST", path: "/auth/login", body: LoginRequest(identifier: identifier, password: password))
    }

    func refreshSession(refreshToken: String) async throws -> SellerAuthSession {
        try await request("POST", path: "/auth/refresh", body: RefreshTokenRequest(refreshToken: refreshToken))
    }

    func me(token: String) async throws -> SellerMeResponse {
        try await request("GET", path: "/me", token: token)
    }

    func sellerListings(token: String) async throws -> [SellerListing] {
        let response: SellerListingsResponse = try await request("GET", path: "/seller/listings", token: token)
        return response.listings.map(\.sellerListing)
    }

    func sellerOrders(token: String) async throws -> [SellerOrder] {
        let response: SellerOrdersResponse = try await request("GET", path: "/seller/orders", token: token)
        return response.orders.map(\.sellerOrder)
    }

    func sellerConversations(token: String) async throws -> [SellerConversation] {
        let response: SellerConversationsResponse = try await request("GET", path: "/conversations", token: token)
        return response.conversations.map(\.sellerConversation)
    }

    func sellerMessages(conversationId: String, token: String) async throws -> [SellerMessage] {
        let response: SellerConversationMessagesResponse = try await request(
            "GET",
            path: "/conversations/\(conversationId)/messages",
            token: token
        )
        return response.messages.map(\.sellerMessage)
    }

    func sendSellerMessage(conversationId: String, text: String, token: String) async throws {
        let _: EmptyResponse = try await request(
            "POST",
            path: "/conversations/\(conversationId)/messages",
            token: token,
            body: SellerSendMessageRequest(body: text)
        )
    }

    func markSellerConversationRead(conversationId: String, token: String) async throws {
        let _: EmptyResponse = try await request(
            "POST",
            path: "/conversations/\(conversationId)/read",
            token: token,
            body: EmptyBody()
        )
    }

    func sellerSchedule(token: String) async throws -> SellerSchedulePreferences {
        let response: SellerScheduleResponse = try await request("GET", path: "/seller/schedule", token: token)
        return response.schedule.preferences
    }

    func updateSellerSchedule(_ preferences: SellerSchedulePreferences, token: String) async throws {
        let _: EmptyResponse = try await request(
            "PATCH",
            path: "/seller/schedule",
            token: token,
            body: SellerSchedulePatchRequest(preferences: preferences)
        )
    }

    func acceptOrder(id: String, token: String) async throws {
        do {
            let _: EmptyResponse = try await request("POST", path: "/seller/orders/\(id)/accept", token: token, body: EmptyBody())
        } catch let error as SellerAPIError where error.isMissingRoute {
            let _: EmptyResponse = try await request("POST", path: "/orders/\(id)/confirm", token: token, body: EmptyBody())
        }
    }

    func updateOrderStatus(
        id: String,
        status: String,
        message: String? = nil,
        estimatedArrivalText: String? = nil,
        paymentMethod: SellerPaymentMethod? = nil,
        paymentStatus: String? = nil,
        token: String
    ) async throws {
        let _: EmptyResponse = try await request(
            "POST",
            path: "/seller/orders/\(id)/status",
            token: token,
            body: SellerOrderStatusUpdateRequest(
                status: status,
                message: message,
                estimatedArrivalText: estimatedArrivalText,
                paymentMethod: paymentMethod?.backendValue,
                paymentStatus: paymentStatus
            )
        )
    }

    private func request<T: Decodable, Body: Encodable>(
        _ method: String,
        path: String,
        token: String? = nil,
        body: Body? = Optional<EmptyBody>.none
    ) async throws -> T {
        var urlRequest = URLRequest(url: Self.baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))))
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token, !token.isEmpty {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw SellerAPIError.invalidResponse }

        guard (200..<300).contains(http.statusCode) else {
            let serverError = try? decoder.decode(ServerErrorResponse.self, from: data)
            let raw = String(data: data, encoding: .utf8)
            throw SellerAPIError.server(
                errorCode: serverError?.error ?? "SERVER_ERROR",
                message: serverError?.message ?? "Request failed",
                debugId: serverError?.debugId,
                httpStatus: http.statusCode,
                rawBody: raw
            )
        }

        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }

        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - DTOs

struct EmptyBody: Encodable {}
struct EmptyResponse: Codable {}

struct ServerErrorResponse: Codable {
    var error: String?
    var message: String?
    var debugId: String?
}

struct LoginRequest: Codable {
    var identifier: String
    var password: String
}

struct RefreshTokenRequest: Codable {
    var refreshToken: String
}

struct SellerSendMessageRequest: Codable {
    var body: String
}

struct SellerSchedulePatchRequest: Codable {
    var preferences: SellerSchedulePreferences
}

struct SellerOrderStatusUpdateRequest: Codable {
    var status: String
    var message: String?
    var estimatedArrivalText: String?
    var paymentMethod: String?
    var paymentStatus: String?
}

struct SellerHealthResponse: Codable {
    var ok: Bool?
    var service: String
    var backendKey: String
    var environment: String?
    var publicBaseUrl: String?
}

struct SellerVersionResponse: Codable {
    var version: String
    var build: String?
}

struct SellerAuthSession: Codable {
    var accessToken: String
    var refreshToken: String
    var seller: SellerProfileDTO?
}

struct SellerMeResponse: Codable {
    var user: SellerProfileDTO
}

struct SellerProfileDTO: Codable {
    var id: UUID
    var storeName: String
    var displayName: String
    var email: String
    var phone: String
    var location: String
    var role: SellerAccountRole
    var approvalStatus: SellerApprovalStatus
    var rating: Double?
    var totalSales: Int?

    var sellerProfile: SellerProfile {
        SellerProfile(
            id: id,
            storeName: storeName,
            displayName: displayName,
            email: email,
            phone: phone,
            location: location,
            role: role,
            approvalStatus: approvalStatus,
            rating: rating ?? 0,
            totalSales: totalSales ?? 0
        )
    }
}

struct SellerListingsResponse: Codable {
    var listings: [SellerListingDTO]
}

struct SellerListingDTO: Codable {
    var id: String
    var sellerId: UUID
    var title: String
    var price: Double
    var category: String
    var subcategory: String
    var condition: String
    var description: String
    var status: SellerListingStatus
    var quantity: Int?
    var views: Int?
    var createdAt: Date?

    var sellerListing: SellerListing {
        SellerListing(
            backendID: id,
            sellerId: sellerId,
            title: title,
            price: price,
            priceType: .firm,
            priceRangeMin: nil,
            priceRangeMax: nil,
            category: category,
            subcategory: subcategory,
            condition: condition,
            description: description,
            specs: [],
            tags: [],
            imageColors: ["6366F1", "14B8A6"],
            location: "",
            city: "",
            status: status,
            quantity: quantity ?? 1,
            views: views ?? 0,
            createdAt: createdAt ?? Date(),
            isFeatured: false,
            deliveryAvailable: false,
            pickupAvailable: true,
            sameDayAvailable: false,
            media: []
        )
    }
}

struct SellerOrdersResponse: Codable {
    var orders: [SellerOrderDTO]
}

struct SellerOrderDTO: Codable {
    var id: String
    var sellerId: UUID
    var orderNumber: String
    var listingTitle: String
    var buyerName: String
    var price: Double
    var deliveryMode: String
    var status: SellerOrderStatus
    var createdAt: Date

    var sellerOrder: SellerOrder {
        SellerOrder(
            backendID: id,
            sellerId: sellerId,
            orderNumber: orderNumber,
            listingTitle: listingTitle,
            buyerName: buyerName,
            price: price,
            deliveryMode: deliveryMode,
            status: status,
            createdAt: createdAt,
            scheduledDate: Date(),
            windowStart: "12:00 PM",
            windowEnd: "5:00 PM",
            deliveryFee: 0,
            customCharges: [],
            discountAmount: 0,
            paymentMethod: .cashOnPickup,
            quantity: 1
        )
    }
}

struct SellerConversationsResponse: Codable {
    var conversations: [SellerConversationDTO]
}

struct SellerConversationDTO: Codable {
    var id: String
    var buyerName: String
    var listingTitle: String?
    var unreadCount: Int?

    var sellerConversation: SellerConversation {
        SellerConversation(id: id, buyerName: buyerName, listingTitle: listingTitle, lastMessage: nil, unreadCount: unreadCount ?? 0)
    }
}

struct SellerConversationMessagesResponse: Codable {
    var messages: [SellerMessageDTO]
}

struct SellerMessageDTO: Codable {
    var id: UUID
    var conversationId: String
    var senderName: String
    var body: String
    var timestamp: Date
    var isFromCurrentSeller: Bool?
    var isRead: Bool?

    var sellerMessage: SellerMessage {
        SellerMessage(
            id: id,
            conversationId: conversationId,
            senderName: senderName,
            body: body,
            timestamp: timestamp,
            isFromCurrentSeller: isFromCurrentSeller ?? false,
            isRead: isRead ?? false
        )
    }
}

struct SellerScheduleResponse: Codable {
    var schedule: SellerScheduleDTO
}

struct SellerScheduleDTO: Codable {
    var preferences: SellerSchedulePreferences
}
