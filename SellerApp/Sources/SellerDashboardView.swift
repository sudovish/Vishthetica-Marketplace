import SwiftUI

struct SellerDashboardView: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        TabView {
            SellerOverviewTab()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }

            SellerListingsTab()
                .tabItem { Label("Listings", systemImage: "tag") }

            SellerOrdersTab()
                .tabItem { Label("Orders", systemImage: "shippingbox") }

            SellerMessagesTab()
                .tabItem { Label("Messages", systemImage: "message") }

            if vm.profile?.isAdmin == true {
                AdminConfigView()
                    .tabItem { Label("Admin", systemImage: "slider.horizontal.3") }
            }
        }
    }
}

struct SellerOverviewTab: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Backend") {
                    LabeledContent("Status", value: vm.backendState.isConnected ? "Connected" : "Offline")
                    LabeledContent("Service", value: vm.backendState.service)
                    LabeledContent("Backend", value: vm.backendState.backendKey)
                    if let version = vm.backendState.version {
                        LabeledContent("Version", value: version)
                    }
                }

                Section("Today") {
                    LabeledContent("Active listings", value: "\(vm.activeListings.count)")
                    LabeledContent("Open orders", value: "\(vm.openOrders.count)")
                    LabeledContent("Unread messages", value: "\(vm.unreadMessageCount)")
                }
            }
            .navigationTitle("Seller Dashboard")
            .toolbar {
                Button("Refresh") {
                    Task { try? await vm.reloadSellerData() }
                }
            }
        }
    }
}

struct SellerListingsTab: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        NavigationStack {
            List(vm.listings) { listing in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(listing.title).font(.headline)
                        Spacer()
                        Text(listing.status.rawValue).font(.caption)
                    }
                    Text(listing.displayPrice)
                    Text(listing.compactSpecsLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Listings")
            .toolbar {
                Button("Sync") { Task { await vm.refreshListings() } }
            }
        }
    }
}

struct SellerOrdersTab: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        NavigationStack {
            List(vm.orders) { order in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(order.orderNumber).font(.headline)
                        Spacer()
                        Text(order.status.rawValue).font(.caption)
                    }
                    Text(order.listingTitle)
                    Text(order.formattedTotal)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button("Accept") { Task { await vm.acceptOrder(order) } }
                        Button("Complete") { Task { await vm.updateOrder(order, to: .delivered, paymentStatus: "paid") } }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Orders")
            .toolbar {
                Button("Sync") { Task { await vm.refreshOrders() } }
            }
        }
    }
}

struct SellerMessagesTab: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        NavigationStack {
            List(vm.conversations) { conversation in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(conversation.buyerName).font(.headline)
                        Spacer()
                        if conversation.unreadCount > 0 {
                            Text("\(conversation.unreadCount)")
                                .font(.caption)
                                .padding(6)
                                .background(Color.accentColor, in: Circle())
                                .foregroundStyle(.white)
                        }
                    }
                    Text(conversation.listingTitle ?? "General inquiry")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Messages")
        }
    }
}

struct AdminConfigView: View {
    @EnvironmentObject var vm: SellerViewModel
    @State private var deliveryEnabled = true
    @State private var sameDayEnabled = false
    @State private var marketplaceBanner = "Fresh local tech deals"
    @State private var publishMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Customer App Config") {
                    TextField("Marketplace banner", text: $marketplaceBanner)
                    Toggle("Delivery enabled", isOn: $deliveryEnabled)
                    Toggle("Same-day delivery", isOn: $sameDayEnabled)
                }

                Section("Admin Responsibilities") {
                    Label("Approve seller applications", systemImage: "checkmark.seal")
                    Label("Manage listing categories and specs", systemImage: "list.bullet.rectangle")
                    Label("Publish delivery and trade-in rules", systemImage: "arrow.up.doc")
                    Label("Monitor orders, messages, and inventory", systemImage: "eye")
                }

                Section {
                    Button("Publish Config") {
                        publishMessage = "Config staged for backend publish flow."
                    }
                }

                if let publishMessage {
                    Section {
                        Text(publishMessage)
                    }
                }
            }
            .navigationTitle("Admin Panel")
        }
    }
}
