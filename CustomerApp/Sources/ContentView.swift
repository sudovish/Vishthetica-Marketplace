import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        TabView(selection: $vm.selectedTab) {
            MarketplaceView()
                .tabItem { Label("Deals", systemImage: "tag") }
                .tag(0)

            CartSummaryView()
                .tabItem { Label("Cart", systemImage: "cart") }
                .badge(vm.cartItems.count)
                .tag(1)

            TradeInSummaryView()
                .tabItem { Label("Trade In", systemImage: "arrow.triangle.2.circlepath") }
                .tag(2)

            ProfileSummaryView()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(3)
        }
    }
}

struct CartSummaryView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.cartItems) { item in
                    HStack {
                        Text(item.listing.title)
                        Spacer()
                        Text(item.listing.formattedPrice)
                    }
                }
                Section {
                    LabeledContent("Total", value: vm.formattedCartTotal)
                    Button("Start Checkout") { vm.startCheckout() }
                        .disabled(vm.cartItems.isEmpty)
                }
            }
            .navigationTitle("Cart")
        }
    }
}

struct TradeInSummaryView: View {
    @StateObject private var state = TradeInState()

    var body: some View {
        NavigationStack {
            List(TradeInDeviceType.allCases) { device in
                Button {
                    state.chooseDevice(device)
                } label: {
                    Label(device.rawValue, systemImage: device.systemIcon)
                }
            }
            .navigationTitle("Trade In")
        }
    }
}

struct ProfileSummaryView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Customer") {
                    LabeledContent("Name", value: vm.currentUser.name)
                    LabeledContent("Username", value: vm.currentUser.username)
                    LabeledContent("Location", value: vm.currentUser.location)
                }
                Section("Saved") {
                    LabeledContent("Saved listings", value: "\(vm.savedListings.count)")
                }
            }
            .navigationTitle("Profile")
        }
    }
}
