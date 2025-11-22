import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var temperature = "--"
    @Published var windSpeed = "--"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cityName: String = ""
    @Published var searchedCity: String?
    @Published var hourlyTemperatures: [(String, Double)] = []   // time + temp tuples

    func fetchWeather(for city: String) async {
        guard !city.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let coords = try await fetchCoordinates(for: city) else {
                errorMessage = "City not found"
                return
            }

            // Main weather
            let url = URL(string:
                "https://api.open-meteo.com/v1/forecast?latitude=\(coords.latitude)&longitude=\(coords.longitude)&current_weather=true"
            )!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            temperature = String(format: "%.1f °C", decoded.currentWeather.temperature)
            windSpeed = String(format: "%.1f km/h", decoded.currentWeather.windspeed)
            searchedCity = coords.name

            await fetchHourlyWeather(lat: coords.latitude, lon: coords.longitude)

        } catch {
            errorMessage = "Network error"
        }
    }

    private func fetchCoordinates(for city: String) async throws -> GeocodingResult? {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results?.first
    }

    private func fetchHourlyWeather(lat: Double, lon: Double) async {
        do {
            let url = URL(string:
              "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m"
            )!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(HourlyWeatherResponse.self, from: data)

            // Pair first 12 hours for view
            hourlyTemperatures = Array(zip(decoded.hourly.time, decoded.hourly.temperature2m).prefix(12))
        } catch {
            print("Hourly weather error: \(error)")
        }
    }
}
