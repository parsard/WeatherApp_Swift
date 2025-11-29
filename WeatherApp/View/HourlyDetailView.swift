import SwiftUI

struct HourlyDetailView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @Environment(\.dismiss) var dismiss
    
    let city: String
    
    @State private var selectedItem: (time: String, temp: Double)?

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading Forecast...")
                    .tint(.white)
                    .scaleEffect(1.5)
            } else if viewModel.hourlyTemperatures.isEmpty {
                Text("No Data Available")
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 0) {
                    
                    // --- UPPER HALF ---
                    VStack(spacing: 10) {
                        Text(city)
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        if let item = selectedItem {
                            Image(systemName: getIconName(for: item.time))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 140)
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.6), radius: 25)
                                .padding(.bottom, 10)
                            
                            VStack(spacing: 4) {
                                Text(String(format: "%.0f°", item.temp))
                                    .font(.system(size: 90, weight: .thin, design: .rounded))
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 2) {
                                    Text(getNiceTime(item.time))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(getSmartDayLabel(item.time))
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            // Force a transition animation when data changes
                            .id(item.time)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.60)
                    
                    // --- LOWER HALF: Selector ---
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .cornerRadius(30,)
                            .ignoresSafeArea(edges: .bottom)
                        
                        VStack(alignment: .leading) {
                            Text("Today's Timeline")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                                .padding(.top, 20)
                            
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.hourlyTemperatures, id: \.0) { item in
                                            HourlySelectorItem(
                                                time: item.0,
                                                temp: item.1,
                                                isSelected: selectedItem?.time == item.0
                                            )
                                            .id(item.0)
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    selectedItem = item
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 40)
                                }
                                .onChange(of: selectedItem?.time) { newTime in
                                    if let newTime = newTime {
                                        withAnimation {
                                            proxy.scrollTo(newTime, anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
        .task { await viewModel.fetchWeather(for: city) }
        .onChange(of: viewModel.hourlyTemperatures.count) { _ in
            scrollToCurrentTime()
        }
    }
    
    // MARK: - FIXED Logic to Select Current Time
    private func scrollToCurrentTime() {
        // 1. Get current hour (0-23)
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // 2. Find the item in the list where the parsed hour matches current hour
        // We use item.0 because the data is a Tuple (String, Double)
        let foundItem = viewModel.hourlyTemperatures.first { item in
            if let date = apiDateFormatter.date(from: item.0) {
                let itemHour = Calendar.current.component(.hour, from: date)
                return itemHour == currentHour
            }
            return false
        }
        
        // 3. Select it, or fallback to first
        if let found = foundItem {
            selectedItem = found
        } else {
            selectedItem = viewModel.hourlyTemperatures.first
        }
    }

    // MARK: - Formatters & Helpers
    private var apiDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        // IMPORTANT: Ensure parsing matches API format strictly
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    var isDaytime: Bool {
        guard let time = selectedItem?.time else { return true }
        let hour = getHour(from: time)
        return hour >= 6 && hour < 18
    }
    
    var backgroundGradient: LinearGradient {
        if isDaytime {
            return LinearGradient(colors: [Color(hex: "#2980B9"), Color(hex: "#6DD5FA")], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [Color(hex: "#141E30"), Color(hex: "#243B55")], startPoint: .top, endPoint: .bottom)
        }
    }
    
    func getIconName(for isoTime: String) -> String {
        let hour = getHour(from: isoTime)
        let isDay = hour >= 6 && hour < 18
        
        // Simple logic: Sun for day, Moon for night.
        // You can expand this based on weather code later.
        return isDay ? "sun.max.fill" : "moon.stars.fill"
    }
    
    func getHour(from isoString: String) -> Int {
        if let date = apiDateFormatter.date(from: isoString) {
            return Calendar.current.component(.hour, from: date)
        }
        return 12
    }
    
    func getNiceTime(_ isoString: String) -> String {
        if let date = apiDateFormatter.date(from: isoString) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a" // Example: 2:00 PM
            return formatter.string(from: date)
        }
        return "--:--"
    }
    
    func getSmartDayLabel(_ isoString: String) -> String {
        guard let date = apiDateFormatter.date(from: isoString) else { return "" }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Example: Monday
        return formatter.string(from: date)
    }
}

// MARK: - Selector Item Component
struct HourlySelectorItem: View {
    let time: String
    let temp: Double
    let isSelected: Bool
    
    private var simpleTime: String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        if let date = parser.date(from: time) {
            let output = DateFormatter()
            output.dateFormat = "h a" // 1 PM
            return output.string(from: date)
        }
        return ""
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(simpleTime)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .white : .primary.opacity(0.7))
                .textCase(.uppercase)
            
            Text(String(format: "%.0f°", temp))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.blue : Color.white.opacity(0.4))
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .shadow(color: isSelected ? Color.blue.opacity(0.4) : Color.clear, radius: 5, y: 3)
    }
}
#Preview{
    HourlyDetailView(city: "Tehran")
}
