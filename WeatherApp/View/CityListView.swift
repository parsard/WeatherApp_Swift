import SwiftUI

struct CityListView: View {
    @StateObject private var listVM = CityListViewModel()
    @StateObject private var weatherVM = WeatherViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                LinearGradient(
                    colors: [
                        Color(hex: "#E3F2FD"), // Light Blue
                        DesignSystem.Colors.backgroundLight
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.l) {
                    
                    // MARK: - Search Section
                    VStack(spacing: DesignSystem.Spacing.m) {
                        TextField("Search for a city...", text: $weatherVM.cityName)
                            .padding()
                            .background(DesignSystem.Colors.cardBackground)
                            .cornerRadius(DesignSystem.Radius.s)
                            .shadow(color: DesignSystem.Shadow.color, radius: 2)
                            .submitLabel(.search)
                            .onSubmit {
                                Task { await weatherVM.fetchWeather(for: weatherVM.cityName) }
                            }

                        Button(action: {
                            Task { await weatherVM.fetchWeather(for: weatherVM.cityName) }
                        }) {
                            HStack {
                                if weatherVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search City")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.primary)
                            .cornerRadius(DesignSystem.Radius.s)
                            .shadow(color: DesignSystem.Shadow.color, radius: 4, y: 2)
                        }
                        .disabled(weatherVM.isLoading || weatherVM.cityName.isEmpty)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.l)
                    .padding(.top, DesignSystem.Spacing.l)

                    // MARK: - Result Card (Component)
                    // This is now cleaner and imported from the other file
                    if let city = weatherVM.searchedCity {
                        CityResultCard(
                            city: city,
                            temperature: weatherVM.temperature,
                            windSpeed: weatherVM.windSpeed,
                            onAdd: {
                                // The Logic remains here in the parent
                                listVM.addCity(city)
                                weatherVM.searchedCity = nil
                                weatherVM.cityName = ""
                            }
                        )
                    }

                    // Error Message
                    if let error = weatherVM.errorMessage {
                        Text(error)
                            .foregroundColor(DesignSystem.Colors.error)
                            .font(.caption)
                    }

                    // MARK: - The List
                    List {
                        Section(header: Text("Saved Cities")) {
                            ForEach(listVM.savedCities, id: \.self) { city in
                                NavigationLink(destination: HourlyDetailView(city: city)) {
                                    HStack {
                                        Text("🌍")
                                        Text(city)
                                            .font(.body)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete(perform: listVM.removeCity)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Cities")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CityListView()
}
