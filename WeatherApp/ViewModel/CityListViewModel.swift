import Foundation
import SwiftUI

@MainActor
class CityListViewModel: ObservableObject {
    @Published var savedCities: [String] = []        // simple persistence later with @AppStorage
    @Published var selectedCity: String? = nil

    func addCity(_ city: String) {
        guard !city.isEmpty, !savedCities.contains(city) else { return }
        savedCities.append(city)
    }

    func removeCity(at offsets: IndexSet) {
        savedCities.remove(atOffsets: offsets)
    }
}
