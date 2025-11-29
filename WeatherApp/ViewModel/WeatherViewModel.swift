import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var temperature = "--"
    @Published var windSpeed = "--"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cityName: String = ""
    @Published var searchedCity: String?
    @Published var hourlyTemperatures: [(String, Double)] = []

    func fetchWeather(for city: String) async {
        guard !city.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 1. Get Coordinates
            guard let coords = try await fetchCoordinates(for: city) else {
                errorMessage = "City not found"
                return
            }

            // 2. Get Current Weather
            // Added &timezone=auto so the API returns local time, not UTC
            let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(coords.latitude)&longitude=\(coords.longitude)&current_weather=true&timezone=auto"
            guard let url = URL(string: urlString) else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            
            temperature = String(format: "%.1f °C", decoded.currentWeather.temperature)
            windSpeed = String(format: "%.1f km/h", decoded.currentWeather.windspeed)
            searchedCity = coords.name

            // 3. Get Hourly Weather
            await fetchHourlyWeather(lat: coords.latitude, lon: coords.longitude)

        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
    }

    private func fetchCoordinates(for city: String) async throws -> GeocodingResult? {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results?.first
    }

    private func fetchHourlyWeather(lat: Double, lon: Double) async {
        do {
            // Added &timezone=auto here too
            let url = URL(string:
              "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m&timezone=auto"
            )!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(HourlyWeatherResponse.self, from: data)

            // FIX: Changed prefix(12) to prefix(24) to get the full day's worth of data
            // Otherwise, afternoon hours simply didn't exist in the array.
            let fullDayData = Array(zip(decoded.hourly.time, decoded.hourly.temperature2m))
            hourlyTemperatures = Array(fullDayData.prefix(24))
            
        } catch {
            print("Hourly weather error: \(error)")
        }
    }
}
