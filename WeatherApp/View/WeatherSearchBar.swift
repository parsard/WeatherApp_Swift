import SwiftUI

struct WeatherSearchBar: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        HStack {
            TextField("Enter city name", text: $viewModel.cityName)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            Button("Search") {
                Task { await viewModel.fetchWeather(for: viewModel.cityName) }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
