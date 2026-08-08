import SwiftUI

struct ListingCardView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.colorScheme) var scheme
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: AppTheme.radiusCard)
                    .fill(LinearGradient(colors: listing.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 130)
                    .overlay {
                        Image(systemName: listing.category.icon)
                            .font(.system(size: 42, weight: .thin))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                Button {
                    vm.toggleLike(listing: listing)
                } label: {
                    Image(systemName: vm.isLiked(listing) ? "heart.fill" : "heart")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.25), in: Circle())
                }
                .padding(8)
            }

            Text(listing.title)
                .font(AppTheme.fontHeadline)
                .foregroundStyle(AppTheme.textPrimary(scheme))
                .lineLimit(2)

            Text(listing.formattedPrice)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.accent)

            Text(listing.keySpecs.map { $0.value + $0.unit }.joined(separator: " / "))
                .font(AppTheme.fontCaption)
                .foregroundStyle(AppTheme.textSecondary(scheme))
                .lineLimit(1)
        }
        .padding(10)
        .visCard()
    }
}

struct ListingDetailView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let listing: Listing

    var body: some View {
        NavigationStack {
            List {
                Section {
                    RoundedRectangle(cornerRadius: AppTheme.radiusCard)
                        .fill(LinearGradient(colors: listing.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 220)
                        .overlay {
                            Image(systemName: listing.category.icon)
                                .font(.system(size: 70, weight: .thin))
                                .foregroundStyle(.white)
                        }
                }
                .listRowBackground(Color.clear)

                Section("Listing") {
                    Text(listing.title).font(.title2.bold())
                    Text(listing.description)
                    LabeledContent("Price", value: listing.formattedPrice)
                    LabeledContent("Condition", value: listing.condition.rawValue)
                    LabeledContent("Location", value: listing.location)
                }

                Section("Specs") {
                    ForEach(listing.specs) { spec in
                        LabeledContent(spec.label, value: spec.value + spec.unit)
                    }
                }

                Section("Seller") {
                    LabeledContent("Seller", value: listing.sellerName)
                    LabeledContent("Username", value: listing.sellerUsername)
                    LabeledContent("Verified", value: listing.isVerifiedSeller ? "Yes" : "No")
                }

                Section {
                    Button("Add to Cart") { vm.addToCart(listing) }
                    Button("Message Seller") { vm.openContact(listing: listing, type: .message) }
                }
            }
            .navigationTitle("Listing")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}
