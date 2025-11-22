import Foundation

struct HourlyWeatherResponse: Codable {
    let hourly: HourlyData
}

struct HourlyData: Codable {
    let time: [String]
    let temperature2m: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
    }
}
