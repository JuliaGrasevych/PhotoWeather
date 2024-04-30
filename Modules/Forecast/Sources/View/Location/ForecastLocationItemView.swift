//
//  ForecastLocationItemView.swift
//  Forecast
//
//  Created by Julia Grasevych on 07.02.2024.
//

import SwiftUI
import CoreLocation
import ForecastDependency
import PhotoStockDependency

enum LocationPhoto {
    case stockPhoto(Photo)
    case `default`
}

@MainActor
struct ForecastLocationItemView<VM: ForecastLocationItemViewModelProtocol>: View {
    @StateObject private var viewModel: VM
    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false
    
    init(viewModel: @escaping @autoclosure () -> VM) {
        _viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        ForecastLocationItemContentView(viewModel: viewModel, showingDeleteAlert: $showingDeleteAlert)
            .background(.black)
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Delete current location?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteLocation()
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert(isPresented: $showingErrorAlert, error: viewModel.output.error) {
                Button("Ok", role: .cancel) { }
            }
            .onReceive(viewModel.output.$error) { error in
                guard error != nil else { return }
                showingErrorAlert = true
            }
    }
}

/// Preview
fileprivate struct PreviewLocation: ForecastLocation {
    var id: String = UUID().uuidString
    var isUserLocation: Bool = false
    var name: String = "Kyiv"
    var latitude: Float = 0
    var longitude: Float = 0
    var timeZoneIdentifier: String? = nil
}

extension ForecastLocationItemViewModel {
    static let preview: ForecastLocationItemViewModel = ForecastLocationItemViewModel(
        location: PreviewLocation(),
        weatherFetcher: ForecastListPreviewFetcher(),
        photoFetcher: PhotoStockPreviewFetcher(),
        locationManager: LocationStoragePreview()
    )
}

struct ForecastLocationItemBuilderPreview: ForecastLocationItemBuilder {
    @MainActor
    func view(location: any ForecastLocation) -> AnyView {
        AnyView(
            ForecastLocationItemView(viewModel: ForecastLocationItemViewModel.preview)
        )
    }
}

#Preview {
    ForecastLocationItemView(viewModel: ForecastLocationItemViewModel.preview)
}
