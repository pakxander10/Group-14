import SwiftUI

struct AppColors {
    static let primary       = Color(hex: "#D4537E")
    static let primaryDark   = Color(hex: "#4B1528")
    static let primaryMid    = Color(hex: "#993556")
    static let primaryLight  = Color(hex: "#FBEAF0")
    static let primaryBorder = Color(hex: "#F4C0D1")

    static let success       = Color(hex: "#1D9E75")
    static let successLight  = Color(hex: "#E1F5EE")
    static let successBorder = Color(hex: "#9FE1CB")

    static let purple        = Color(hex: "#7F77DD")
    static let purpleLight   = Color(hex: "#EEEDFE")

    static let bg            = Color(hex: "#f9f9f9")
    static let card          = Color.white
    static let textPrimary   = Color(hex: "#1a1a1a")
    static let textSecondary = Color(hex: "#666666")
    static let textTertiary  = Color(hex: "#999999")
    static let divider       = Color(hex: "#f0f0f0")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
