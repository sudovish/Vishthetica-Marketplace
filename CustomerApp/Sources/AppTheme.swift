import SwiftUI

// MARK: - Color Palette
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

struct AppTheme {
    static let accent       = Color(hex: "6366F1")
    static let accentGlow   = Color(hex: "818CF8")
    static let teal         = Color(hex: "14B8A6")
    static let verified     = Color(hex: "10B981")
    static let danger       = Color(hex: "EF4444")
    static let warning      = Color(hex: "F59E0B")

    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "0A0A0A") : Color(hex: "FAFAFA")
    }
    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "141414") : Color.white
    }
    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "1C1C1C") : Color.white
    }
    static func cardBorder(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "2A2A2A") : Color(hex: "EBEBEB")
    }
    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "F5F5F5") : Color(hex: "0A0A0A")
    }
    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "888888") : Color(hex: "6B7280")
    }
    static func textTertiary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "555555") : Color(hex: "9CA3AF")
    }
    static func inputBackground(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "1E1E1E") : Color(hex: "F3F4F6")
    }
    static func separatorColor(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "222222") : Color(hex: "E5E7EB")
    }

    static let categoryGradients: [ProductCategory: [Color]] = [
        .electronics: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
        .fashion:     [Color(hex: "EC4899"), Color(hex: "F43F5E")],
        .furniture:   [Color(hex: "D97706"), Color(hex: "B45309")],
        .vehicles:    [Color(hex: "0EA5E9"), Color(hex: "2563EB")],
        .sports:      [Color(hex: "10B981"), Color(hex: "059669")],
        .books:       [Color(hex: "F59E0B"), Color(hex: "D97706")],
        .other:       [Color(hex: "6B7280"), Color(hex: "4B5563")]
    ]

    static let fontDisplay   = Font.system(size: 34, weight: .black, design: .rounded)
    static let fontTitle     = Font.system(size: 24, weight: .bold, design: .rounded)
    static let fontTitle2    = Font.system(size: 20, weight: .bold, design: .rounded)
    static let fontHeadline  = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let fontBody      = Font.system(size: 15, weight: .regular, design: .rounded)
    static let fontCaption   = Font.system(size: 12, weight: .medium, design: .rounded)
    static let fontMicro     = Font.system(size: 10, weight: .semibold, design: .rounded)

    static let radiusCard: CGFloat = 16
    static let radiusButton: CGFloat = 12
    static let radiusChip: CGFloat = 8
    static let radiusFull: CGFloat = 100
}

struct VisCard: ViewModifier {
    @Environment(\.colorScheme) var scheme
    func body(content: Content) -> some View {
        content
            .background(AppTheme.card(scheme))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusCard)
                    .stroke(AppTheme.cardBorder(scheme), lineWidth: 1)
            )
            .shadow(color: scheme == .dark ? .black.opacity(0.5) : .black.opacity(0.06), radius: 16, x: 0, y: 6)
    }
}

extension View {
    func visCard() -> some View { modifier(VisCard()) }
}
