//
//  ForecastList.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI

struct ForecastList: View {
    @StateObject private var viewModel: ViewModel
    private let itemBuilder: ForecastLocationItemBuilder
    
    init(
        viewModel: @escaping @autoclosure () -> ViewModel,
        itemBuilder: ForecastLocationItemBuilder
    ) {
        _viewModel = .init(wrappedValue: viewModel())
        self.itemBuilder = itemBuilder
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ZStack {
                LazyHStack(spacing: 0) {
                    ForEach(viewModel.locations, id: \.name) { item in
                        itemBuilder.view(location: item)
                        .containerRelativeFrame([.horizontal, .vertical])
                    }
                    .scrollTransition { effect, phase in
                        effect
                            .opacity(phase.isIdentity ? 1.0 : 0.8)
                    }
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

/// Preview
struct ForecastListPreviewFetcher: ForecastFetching {
    func forecast(for location: ForecastLocation) async throws -> ForecastItem {
        return ForecastItem.preview
    }
}

struct PhotoStockPreviewFetcher: PhotoStockFetching {
    func photoURL(for location: ForecastLocation, tags: [String]) async throws -> URL {
        URL(string: "https://cdn.vectorstock.com/i/preview-1x/65/30/default-image-icon-missing-picture-page-vector-40546530.jpg")!
    }
}

extension ForecastList.ViewModel {
    static let preview: ForecastList.ViewModel = ForecastList.ViewModel(
        weatherFetcher: ForecastListPreviewFetcher(),
        photoFetcher: PhotoStockPreviewFetcher()
    )
}

#Preview {
    ForecastList(
        viewModel: .preview,
        itemBuilder: ForecastLocationItemBuilderPreview()
    )
}
