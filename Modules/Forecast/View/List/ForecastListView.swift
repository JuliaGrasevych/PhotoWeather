//
//  ForecastListView.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import Core

import PhotoStockDependency

struct ForecastListView: View {
    @StateObject private var viewModel: ViewModel
    private let itemBuilder: ForecastLocationItemBuilder
    private let addLocationBuilder: ForecastAddLocationViewBuilder
    
    init(
        viewModel: @escaping @autoclosure () -> ViewModel,
        itemBuilder: ForecastLocationItemBuilder,
        addLocationBuilder: ForecastAddLocationViewBuilder
    ) {
        _viewModel = .init(wrappedValue: viewModel())
        self.itemBuilder = itemBuilder
        self.addLocationBuilder = addLocationBuilder
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ZStack {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.locations, id: \.name) { item in
                        itemBuilder.view(location: item)
                            .containerRelativeFrame([.horizontal, .vertical])
                    }
                    .fadeScrollTransition()
                    
                    addLocationBuilder.view
                        .containerRelativeFrame([.horizontal, .vertical])
                        .clipped()
                        .fadeScrollTransition()
                }
                .overlay(alignment: .top) {
                    Self.topGradient()
                }
                .overlay(alignment: .bottom) {
                    Self.bottomGradient()
                }
            }
        }
        .background(.black)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private static func topGradient() -> some View {
        Rectangle()
            .fill(LinearGradient(
                stops: [
                    Gradient.Stop(color: .black, location: 0.0),
                    Gradient.Stop(color: .black.opacity(0.8), location: 0.1),
                    Gradient.Stop(color: .black.opacity(0.5), location: 0.4),
                    Gradient.Stop(color: .clear, location: 1.0),
                       ],
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(height: 100)
    }
    
    private static func bottomGradient() -> some View {
        Rectangle()
            .fill(LinearGradient(
                stops: [
                    Gradient.Stop(color: .clear, location: 0.0),
                    Gradient.Stop(color: .black.opacity(0.5), location: 0.75),
                    Gradient.Stop(color: .black, location: 1.0),
                       ],
                startPoint: .top,
                endPoint: .bottom
            ))
            .frame(height: 20)
    }
}

fileprivate extension View {
    func fadeScrollTransition() -> some View {
        self.scrollTransition { effect, phase in
            effect
                .opacity(phase.isIdentity ? 1.0 : 0.3)
        }
    }
}

/// Preview
struct ForecastListPreviewFetcher: ForecastFetching {
    func forecast(for location: ForecastLocation) async throws -> ForecastItem {
        return ForecastItem.preview
    }
}

struct PhotoStockPreviewFetcher: PhotoStockFetching {
    func photoURL(for location: LocationProtocol, tags: [String]) async throws -> URL {
        URL(string: "https://th.bing.com/th/id/OIG3._lMZO_nHk.Lnpcc0Q0cT?w=1024&h=1024&rs=1&pid=ImgDetMain")!
    }
}

extension ForecastListView.ViewModel {
    static let preview: ForecastListView.ViewModel = ForecastListView.ViewModel(
        weatherFetcher: ForecastListPreviewFetcher(),
        photoFetcher: PhotoStockPreviewFetcher()
    )
}

#Preview {
    ForecastListView(
        viewModel: .preview,
        itemBuilder: ForecastLocationItemBuilderPreview(),
        addLocationBuilder: ForecastAddLocationViewBuilderPreview()
    )
}
