import SwiftUI

// MARK: - Design System
struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "#3498DB")
        static let success = Color(hex: "#2ECC71")
        static let error = Color(hex: "#E74C3C")
        static let warning = Color(hex: "#F39C12")
        
        static let textPrimary = Color(hex: "#2C3E50")
        static let textSecondary = Color(hex: "#7F8C8D")
        
        static let backgroundLight = Color(hex: "#F8F9FA")
        static let cardBackground = Color(hex: "#FFFFFF")
        static let accentBackground = Color(hex: "#E8F8F5")
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let xs: CGFloat = 12
        static let s: CGFloat = 14
        static let m: CGFloat = 16
        static let l: CGFloat = 18
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Corner Radius
    struct Radius {
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let color = Color.black.opacity(0.05)
        static let radius: CGFloat = 4
    }
}
