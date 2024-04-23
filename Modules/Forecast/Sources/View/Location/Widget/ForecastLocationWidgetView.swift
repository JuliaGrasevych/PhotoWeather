//
//  ForecastLocationWidgetView.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.04.2024.
//

import Foundation
import SwiftUI

@MainActor
struct ForecastLocationWidgetView<VM: ForecastLocationItemViewModelProtocol>: View {
    @StateObject private var viewModel: VM
    
    init(viewModel: @escaping @autoclosure () -> VM) {
        _viewModel = .init(wrappedValue: viewModel())
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
                if viewModel.output.isUserLocation {
                    Image(systemName: "location.fill")
                }
                Text(viewModel.output.locationName)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
            }
            Text(viewModel.output.currentWeather.temperature)
                .font(.system(.body, design: .rounded))
            Text(viewModel.output.currentWeather.weatherIcon)
                .font(Font.weatherIconFont(size: 12))
            Text(viewModel.output.currentWeather.weatherDescription)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
        }
        .defaultContentStyle()
        .padding(EdgeInsets(top: 40, leading: 0, bottom: 20, trailing: 0))
        .frame(maxWidth: .infinity, alignment: .top)
        .background(.ultraThinMaterial.opacity(0.85))
        .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func locationImage() -> some View {
        switch viewModel.output.image {
        case .stockPhoto(let photo):
            AsyncImage(url: photo.url, content: { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    defaultImage()
                } else {
                    ProgressView().progressViewStyle(.circular)
                        .tint(.white)
                }
            })
        case .default:
            defaultImage()
        case .none:
            EmptyView()
        }
    }
    
    private func defaultImage() -> some View {
        Image(.defaultCity)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
