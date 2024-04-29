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
    // TODO: add image loading
//    let image: LocationPhoto?
    
    public init(locationName: String, isUserLocation: Bool, currentWeather: CurrentWeather) {
        self.locationName = locationName
        self.isUserLocation = isUserLocation
        self.currentWeather = currentWeather
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
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    private func locationImage() -> some View {
        EmptyView()
//        switch viewModel.image {
//        case .stockPhoto(let photo):
//            AsyncImage(url: photo.url, content: { phase in
//                if let image = phase.image {
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } else if phase.error != nil {
//                    defaultImage()
//                } else {
//                    ProgressView().progressViewStyle(.circular)
//                        .tint(.white)
//                }
//            })
//        case .default:
//            defaultImage()
//        case .none:
//            EmptyView()
//        }
    }
    
    private func defaultImage() -> some View {
        Image(.defaultCity)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
