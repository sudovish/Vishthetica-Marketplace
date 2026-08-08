import SwiftUI

@main
struct VistheticaSellerApp: App {
    @StateObject private var viewModel = SellerViewModel()

    var body: some Scene {
        WindowGroup {
            SellerRootView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.checkBackendHealth()
                }
        }
    }
}

struct SellerRootView: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        Group {
            if vm.isSignedIn {
                SellerDashboardView()
            } else {
                SellerLoginView()
            }
        }
    }
}

struct SellerLoginView: View {
    @EnvironmentObject var vm: SellerViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Seller Login") {
                    TextField("Email or phone", text: $vm.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $vm.password)
                }

                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(vm.isLoading ? "Signing in..." : "Sign In") {
                        Task { await vm.signIn() }
                    }
                    .disabled(vm.isLoading)
                }
            }
            .navigationTitle("Visthetica Seller")
        }
    }
}
