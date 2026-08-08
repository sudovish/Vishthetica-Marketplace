import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.colorScheme) var scheme

    @State private var searchText = ""
    @State private var selectedListing: Listing? = nil

    var filteredListings: [Listing] {
        vm.searchListings(query: searchText, category: .electronics)
    }

    var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background(scheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 18)
                            .padding(.bottom, 16)

                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        listingsSection
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedListing) { ListingDetailView(listing: $0) }
        }
    }

    var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text("Visthetica")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.accent)
                    Text("Deals")
                        .font(.system(size: 22, weight: .light, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary(scheme))
                }
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.teal)
                    Text("Nearby")
                        .font(AppTheme.fontCaption)
                        .foregroundColor(AppTheme.textTertiary(scheme))
                }
            }
            Spacer()

            Button {} label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary(scheme))
                        .frame(width: 40, height: 40)
                        .background(AppTheme.surface(scheme), in: Circle())
                        .overlay(Circle().stroke(AppTheme.cardBorder(scheme), lineWidth: 1))
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 8, height: 8)
                        .offset(x: 1, y: 1)
                }
            }
        }
    }

    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textTertiary(scheme))
            TextField("Search listings, specs, models...", text: $searchText)
                .font(AppTheme.fontBody)
                .foregroundColor(AppTheme.textPrimary(scheme))
                .tint(AppTheme.accent)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textTertiary(scheme))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(AppTheme.inputBackground(scheme), in: RoundedRectangle(cornerRadius: AppTheme.radiusButton))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusButton).stroke(AppTheme.cardBorder(scheme), lineWidth: 1))
    }

    var listingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Electronics")
                    .font(AppTheme.fontTitle2)
                    .foregroundColor(AppTheme.textPrimary(scheme))
                Spacer()
                Text("\(filteredListings.count) items")
                    .font(AppTheme.fontCaption)
                    .foregroundColor(AppTheme.textTertiary(scheme))
            }
            .padding(.horizontal, 20)

            if filteredListings.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundColor(AppTheme.textTertiary(scheme))
                    Text("No listings found")
                        .font(AppTheme.fontHeadline)
                        .foregroundColor(AppTheme.textSecondary(scheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredListings) { listing in
                        Button { selectedListing = listing } label: {
                            ListingCardView(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
    }
}
