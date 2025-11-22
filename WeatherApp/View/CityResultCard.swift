import SwiftUI

struct CityResultCard: View {
    // 1. Data passed in
    let city: String
    let temperature: String
    let windSpeed: String
    
    // 2. Action passed in (What happens when button is clicked)
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            
            // Header
            HStack {
                Text(city)
                    .font(.system(size: DesignSystem.FontSize.xl, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Button(action: onAdd) {
                    Text("Add +")
                        .font(.system(size: DesignSystem.FontSize.s, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(DesignSystem.Colors.success)
                        .cornerRadius(DesignSystem.Radius.s)
                        .shadow(radius: 2)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Data Rows
            HStack(spacing: DesignSystem.Spacing.xl) {
                // Temp Column
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "thermometer.medium")
                            .foregroundColor(DesignSystem.Colors.error)
                        Text("Temp")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.bottom,4)
                    Text(temperature)
                        .font(.system(size: DesignSystem.FontSize.l, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
                
                // Wind Column (Right aligned visually)
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("Wind")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Image(systemName: "wind")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    .padding(.bottom,4)
                    Text(windSpeed)
                        .font(.system(size: DesignSystem.FontSize.l, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
            }
        }
        .padding(DesignSystem.Spacing.l)
        // MARK: - Distinct Background Design
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.l)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "#F0F8FF")], // White to AliceBlue
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        // Add a subtle border to make it pop
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.l)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, DesignSystem.Spacing.l)
        .transition(.scale.combined(with: .opacity))
    }
}
#Preview {
    ZStack {
        // I added a gray background here just so you can see
        // how the Card's white background and shadow stand out.
        Color(hex: "#E3F2FD").ignoresSafeArea()
        
        CityResultCard(
            city: "Tehran",
            temperature: "25°C",
            windSpeed: "12 km/h",
            onAdd: {
                // This code runs when you click the button in the preview (Console)
                print("Add button tapped!")
            }
        )
        .padding() // Add some breathing room around the card
    }
}
