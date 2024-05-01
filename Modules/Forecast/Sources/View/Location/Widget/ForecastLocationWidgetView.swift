//
//  ForecastLocationWidgetView.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.04.2024.
//

import Foundation
import SwiftUI

public struct ForecastLocationItemWidgetViewModel {
    public struct CurrentWeather {
        let temperature: String
        let weatherIcon: String
        let weatherDescription: String
        
        public init(temperature: String, weatherIcon: String, weatherDescription: String) {
            self.temperature = temperature
            self.weatherIcon = weatherIcon
            self.weatherDescription = weatherDescription
        }
    }
    
    let locationName: String
    let isUserLocation: Bool
    let currentWeather: CurrentWeather
    let image: UIImage?
    
    public init(locationName: String, isUserLocation: Bool, currentWeather: CurrentWeather, image: UIImage?) {
        self.locationName = locationName
        self.isUserLocation = isUserLocation
        self.currentWeather = currentWeather
        self.image = image
    }
}

@MainActor
struct ForecastLocationWidgetView: View {
    private var viewModel: ForecastLocationItemWidgetViewModel
    
    init(viewModel: ForecastLocationItemWidgetViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    locationImage()
                }
                .contentShape(Rectangle())
                .clipped()
                .overlay {
                    Rectangle()
                        .background(Material.ultraThinMaterial.opacity(0.25))
                }
            
            currentWeatherView()
        }
    }
    
    private func currentWeatherView() -> some View {
        VStack {
            HStack {
                if viewModel.isUserLocation {
                    Image(systemName: "location.fill")
                }
                Text(viewModel.locationName)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
            }
            Text(viewModel.currentWeather.temperature)
                .font(.system(.body, design: .rounded))
            Text(viewModel.currentWeather.weatherIcon)
                .font(Font.weatherIconFont(size: 40))
            Text(viewModel.currentWeather.weatherDescription)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
        .defaultContentStyle()
        .whiteContentShadow(radius: 5)
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    private func locationImage() -> some View {
        switch viewModel.image {
        case .none:
            EmptyView()
        case .some(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    private func defaultImage() -> some View {
        Image(.defaultCity)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
