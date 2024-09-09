//
//  ForecastLocationItemContentView.swift
//  Forecast
//
//  Created by Julia Grasevych on 18.04.2024.
//

import Foundation
import SwiftUI

@MainActor
struct ForecastLocationItemContentView<VM: ForecastLocationItemViewModelProtocol>: View {
    @StateObject private var viewModel: VM
    @State private var showingForecast = false
    @State private var isAnimating = false
    @Binding var showingDeleteAlert: Bool
    
    @State private var taskId: UUID?
    private var isRefreshing: Bool { taskId != nil }
    @Environment(\.refresh) private var refresh
    
    init(viewModel: @escaping @autoclosure () -> VM, showingDeleteAlert: Binding<Bool>) {
        _viewModel = .init(wrappedValue: viewModel())
        _showingDeleteAlert = showingDeleteAlert
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    locationImage()
                }
                .contentShape(Rectangle())
                .clipped()
            
            VStack {
                currentWeatherView()
                    .overlay(alignment: .bottomTrailing) {
                        Button{
                            taskId = .init()
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                        }
                        .defaultContentStyle()
                        .rotationEffect(isRefreshing ? .degrees(360) : .zero)
                        .animation(
                            isRefreshing
                            ? .default.repeatForever(autoreverses: false)
                            : .default,
                            value: taskId
                        )
                        .opacity(isRefreshing ? 0.5 : 1.0)
                        .padding([.bottom, .trailing], 20)
                        .font(.title)
                        .disabled(isRefreshing)
                        .task(id: taskId) {
                            guard isRefreshing else {
                                return
                            }
                            await refresh?()
                            taskId = nil
                        }
                    }
                Spacer()
                photoAuthorView()
                // hack to disable refreshable behavior (pull-to-refresh) on subviews
                forecastView()
                    .environment(\EnvironmentValues.refresh as! WritableKeyPath<EnvironmentValues, RefreshAction?>, nil)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
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
    
    private func currentWeatherView() -> some View {
        VStack {
            HStack {
                if viewModel.output.isUserLocation {
                    Image(systemName: "location.fill")
                        .scaleEffect(isAnimating ? 1.5 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(), value: isAnimating)
                        .onAppear { isAnimating = true }
                }
                Text(viewModel.output.locationName)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
            }
            Text(viewModel.output.currentWeather.temperature)
                .font(.system(.title, design: .rounded))
            Image(systemName: viewModel.output.currentWeather.weatherSFSymbol)
                .symbolRenderingMode(.hierarchical)
                .fixedSize()
                .font(Font.system(size: 80))
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
    
    private func forecastView() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 20) {
                todaysForecastTopView()
                
                if showingForecast {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            hourlyWeatherView(forecast: viewModel.output.hourlyForecast)
                            dailyWeatherView(forecast: viewModel.output.dailyForecast)
                        }
                    }
                    .transition(.push(from: .bottom))
                }
                if !viewModel.output.isUserLocation {
                    Button("Delete location", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .buttonStyle(.borderless)
                    .shadow(color: .red, radius: 20)
                }
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
                    Self.dailyTemperatureView(value: viewModel.output.todayForecast.temperatureMin, isMax: false)
                    Self.dailyTemperatureView(value: viewModel.output.todayForecast.temperatureMax, isMax: true)
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
        Label(value, systemImage: isMax ? "arrow.up" : "arrow.down")
    }
    
    private func hourlyWeatherView(forecast: [ForecastLocationItemViewModelOutput.HourlyForecast]) -> some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack {
                    Section {
                        ForEach(forecast) { item in
                            VStack {
                                Text(item.time)
                                    .font(.body)
                                Image(systemName: item.weatherSFSymbol)
                                    .symbolRenderingMode(.hierarchical)
                                    .fixedSize()
                                    .font(Font.system(size: 25))
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
    
    private func dailyWeatherView(forecast: [ForecastLocationItemViewModelOutput.DailyForecast]) -> some View {
        LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(forecast) { item in
                    HStack {
                        Text(item.date)
                            .font(.body)
                        Spacer()
                        Image(systemName: item.weatherSFSymbol)
                            .symbolRenderingMode(.hierarchical)
                            .fixedSize()
                            .font(Font.system(size: 25))
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
    
    private func photoAuthorView() -> some View {
        VStack {
            Label(viewModel.output.imageAuthorTitle ?? "", systemImage: "camera.fill")
                .defaultContentStyle()
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
    
    private func defaultImage() -> some View {
        Image(.defaultCity)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

#Preview {
    ForecastLocationItemContentView(viewModel: ForecastLocationItemViewModel.preview, showingDeleteAlert: Binding(get: { false }, set: { _ in }))
}
