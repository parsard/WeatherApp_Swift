import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            searchBarSection()

            weatherInfoSection()

            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }

    // MARK: - Subviews as Functions

    @ViewBuilder
    private func searchBarSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            WeatherSearchBar(viewModel: viewModel)
            if let city = viewModel.searchedCity {
                Text("Weather in \(city)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private func weatherInfoSection() -> some View {
        if viewModel.isLoading {
            ProgressView("Loading…")
        } else if let error = viewModel.errorMessage {
            Text(error).foregroundStyle(.red)
        } else {
            VStack(spacing: 8) {
                Text("🌡️ \(viewModel.temperature)")
                    .font(.system(size: 28))
                    .fontWeight(.medium)
                Text("🌬️ \(viewModel.windSpeed)")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WeatherView()
}
