import SwiftUI

struct HourlyDetailView: View {
    @StateObject private var viewModel = WeatherViewModel()
    let city: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(city)
                .font(.title)
                .fontWeight(.bold)

            if viewModel.isLoading {
                ProgressView("Fetching hourly weather...")
            } else {
                if viewModel.hourlyTemperatures.isEmpty {
                    Text("No hourly data available.")
                        .foregroundStyle(.secondary)
                } else {
                    List(viewModel.hourlyTemperatures, id: \.0) { time, temp in
                        HStack {
                            Text(formatTime(time))
                                .font(.system(size: 16))
                            Spacer()
                            Text(String(format: "%.1f °C", temp))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Hourly Forecast")
        .task { await viewModel.fetchWeather(for: city) }
    }

    private func formatTime(_ isoString: String) -> String {
        let input = ISO8601DateFormatter()
        if let date = input.date(from: isoString) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return isoString
    }
}
