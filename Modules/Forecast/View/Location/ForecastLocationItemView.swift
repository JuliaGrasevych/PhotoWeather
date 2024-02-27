//
//  ForecastLocationItemView.swift
//  Forecast
//
//  Created by Julia Grasevych on 07.02.2024.
//

import SwiftUI
import CoreLocation
import ForecastDependency

struct ForecastLocationItemView: View {
    @StateObject private var viewModel: ViewModel
    @State private var showingForecast = false
    @State private var showingDeleteAlert = false
    
    init(viewModel: @escaping @autoclosure () -> ViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    AsyncImage(url: viewModel.imageURL, content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }, placeholder: {
                        ProgressView().progressViewStyle(.circular)
                            .tint(.white)
                    })
                }
                .contentShape(Rectangle())
                .clipped()
            
            VStack {
                currentWeatherView()
                Spacer()
                forecastView()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .background(.black)
        .alert("Delete current location?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteLocation()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func currentWeatherView() -> some View {
        VStack {
            Text(viewModel.locationName)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
            Text(viewModel.currentWeather.temperature)
                .font(.system(.title, design: .rounded))
            Text(viewModel.currentWeather.weatherIcon)
                .font(Font.weatherIconFont(size: 80))
            Text(viewModel.currentWeather.weatherDescription)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
        .defaultContentStyle()
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 20, trailing: 0))
        .frame(maxWidth: .infinity, alignment: .top)
        .background(.ultraThinMaterial.opacity(0.85))
        .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 4)
    }
    
    private func forecastView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 20) {
                todaysForecastTopView()
                
                if showingForecast {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            hourlyWeatherView(forecast: viewModel.hourlyForecast)
                            dailyWeatherView(forecast: viewModel.dailyForecast)
                        }
                    }
                    .transition(.push(from: .bottom))
                }
                Button("Delete location", role: .destructive) {
                    showingDeleteAlert = true
                }
                .buttonStyle(.borderless)
                .shadow(color: .red, radius: 20)
            }
            .padding()
            Spacer()
        }
        .background(.ultraThinMaterial.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .white.opacity(0.25), radius: 4)
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 40, trailing: 8))
    }
    
    private func todaysForecastTopView() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(showingForecast ? "Today" : "Forecast")
                    .font(.headline)
                HStack(spacing: 16) {
                    Self.dailyTemperatureView(value: viewModel.todayForecast.temperatureMin, isMax: false)
                    Self.dailyTemperatureView(value: viewModel.todayForecast.temperatureMax, isMax: true)
                }
                .font(.body)
            }
            Spacer()
            Button {
                withAnimation {
                    showingForecast.toggle()
                }
            } label: {
                Image(systemName: showingForecast ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
            }
            .font(.title)
        }
        .defaultContentStyle()
    }
    
    private static func dailyTemperatureView(value: String, isMax: Bool) -> some View {
        HStack {
            Image(systemName: isMax ? "arrow.up" : "arrow.down")
            Text(value)
        }
    }
    
    private func hourlyWeatherView(forecast: [HourlyForecast]) -> some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack {
                    Section {
                        ForEach(forecast) { item in
                            VStack {
                                Text(item.time)
                                    .font(.body)
                                Text(item.weatherIcon)
                                    .font(Font.weatherIconFont(size: 25))
                                Text(item.temperature)
                                    .font(.body)
                            }
                            .defaultContentStyle()
                            .padding(8)
                            .roundedBorder(
                                radius: 8,
                                border: Color.black.opacity(0.1),
                                lineWidth: 1
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func dailyWeatherView(forecast: [DailyForecast]) -> some View {
        LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(forecast) { item in
                    HStack {
                        Text(item.date)
                            .font(.body)
                        Spacer()
                        Text(item.weatherIcon)
                            .font(Font.weatherIconFont(size: 25))
                        Spacer()
                        Self.dailyTemperatureView(value: item.temperatureMin, isMax: false)
                            .font(.body)
                        Self.dailyTemperatureView(value: item.temperatureMax, isMax: true)
                            .font(.body)
                    }
                    .defaultContentStyle()
                    .padding(8)
                    .roundedBorder(
                        radius: 8,
                        border: Color.black.opacity(0.1),
                        lineWidth: 1
                    )
                    .frame(maxWidth: .infinity)
                }
            } header: {
                Text("Upcoming")
                    .font(.headline)
                    .defaultContentStyle()
            }
        }
    }
}

fileprivate extension Font {
    static func weatherIconFont(size: CGFloat) -> Font {
        .custom("weather-icons-lite", size: size)
    }
}

fileprivate extension View {
    func defaultContentShadow() -> some View {
        self.shadow(color: .white, radius: 10)
    }
    
    func defaultContentColor() -> some View {
        self.foregroundStyle(.black)
    }
    
    func defaultContentStyle() -> some View {
        self
            .defaultContentColor()
            .defaultContentShadow()
    }
}

/// Preview
fileprivate struct PreviewLocation: ForecastLocation {
    var id: String = UUID().uuidString
    var name: String = "Kyiv"
    var latitude: Float = 0
    var longitude: Float = 0
    var timeZoneIdentifier: String? = nil
}

extension ForecastLocationItemView.ViewModel {
    static let preview: ForecastLocationItemView.ViewModel = ForecastLocationItemView.ViewModel(
        location: PreviewLocation(),
        weatherFetcher: ForecastListPreviewFetcher(),
        photoFetcher: PhotoStockPreviewFetcher(),
        locationManager: LocationStoragePreview()
    )
}

struct ForecastLocationItemBuilderPreview: ForecastLocationItemBuilder {
    func view(location: NamedLocation) -> AnyView {
        AnyView(
            ForecastLocationItemView(viewModel: .preview)
        )
    }
}

#Preview {
    ForecastLocationItemView(viewModel: .preview)
}

