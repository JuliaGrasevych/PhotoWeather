//
//  ForecastListView.swift
//  Forecast
//
//  Created by Julia Grasevych on 05.02.2024.
//

import SwiftUI
import Core

import PhotoStockDependency
import ForecastDependency

@MainActor
struct ForecastListView: View {
    @StateObject private var viewModel: ViewModel
    @State private var selectedTab: String = ""
    
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
        TabView(selection: $selectedTab) {
            ForEach(viewModel.allLocations, id: \.id) { item in
                itemBuilder.view(location: item)
                    .containerRelativeFrame([.horizontal, .vertical])
                    .id(item.id)
            }
            
            addLocationBuilder.view
                .containerRelativeFrame([.horizontal, .vertical])
                .clipped()
        }
        
        .overlay(alignment: .top) {
            Self.topGradient()
        }
        .overlay(alignment: .bottom) {
            Self.bottomGradient()
        }
        .background(.black)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onChange(of: viewModel.allLocations.map(\.id), initial: false) { (old, new) in
            didUpdateContent(oldContent: old, newContent: new)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private func didUpdateContent(oldContent: [String], newContent: [String]) {
        // if not content - return
        guard !newContent.isEmpty else { return }
        // if oldContent is empty - scroll to 1st new item
        guard !oldContent.isEmpty else {
            if let firstId = newContent.first {
                selectedTab = firstId
            }
            return
        }
        let diff = newContent.difference(from: oldContent)
        // if has insertions - scroll to 1st insertion
        if !diff.insertions.isEmpty,
            case let .insert(_, first, _) = diff.insertions.first {
                selectedTab = first
                return
        }
        // if has removals - scroll to nearest item before the 1st removal
        if !diff.removals.isEmpty,
           case let .remove(_, first, _) = diff.removals.first,
           let firstRemoval = oldContent.firstIndex(where: { $0 == first }) {
            let idx = firstRemoval > oldContent.startIndex
            ? oldContent.index(before: firstRemoval)
            : oldContent.startIndex
            let value = oldContent[idx]
            selectedTab = value
            return
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
    func forecast(for location: any ForecastLocation) async throws -> ForecastItem {
        return ForecastItem.preview
    }
}

struct PhotoStockPreviewFetcher: PhotoStockFetching {
    func photoURL(for location: LocationProtocol, tags: [String]) async throws -> URL {
        URL(string: "https://th.bing.com/th/id/OIG3._lMZO_nHk.Lnpcc0Q0cT?w=1024&h=1024&rs=1&pid=ImgDetMain")!
    }
}

struct LocationStoragePreview: LocationStoring, LocationManaging {
    func locations() async -> AsyncStream<[NamedLocation]> {
        AsyncStream { _ in }
    }
    func add(location _: NamedLocation) { }
    func addLocationsObserver(_ observer: ([NamedLocation]) -> ()) { }
    func remove(location id: NamedLocation.ID) { }
}
import CoreLocation
struct LocationProviderPreview: LocationProviding {
    func isAuthorized() async -> Bool {
        true
    }
    
    var currentLocation: CLLocation { CLLocation(latitude: 0, longitude: 0) }
}

extension ForecastListView.ViewModel {
    static let preview: ForecastListView.ViewModel = ForecastListView.ViewModel(
        locationStorage: LocationStoragePreview(), 
        locationProvider: LocationProviderPreview()
    )
}

#Preview {
    ForecastListView(
        viewModel: .preview,
        itemBuilder: ForecastLocationItemBuilderPreview(),
        addLocationBuilder: ForecastAddLocationViewBuilderPreview()
    )
}
