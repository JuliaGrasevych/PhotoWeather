//
//  ForecastAddLocationView.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import SwiftUI

struct ForecastAddLocationView: View {
    @State private var showingSearch = false
    @State private var showingAlert = false
    
    @StateObject private var viewModel: ViewModel
    private let searchBuilder: ForecastLocationSearchViewBuilder
    
    init(
        viewModel: @escaping @autoclosure () -> ViewModel,
        searchBuilder: ForecastLocationSearchViewBuilder
    ) {
        _viewModel = .init(wrappedValue: viewModel())
        self.searchBuilder = searchBuilder
    }
    
    var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Text("Add location")
                    .font(.title2)
                Button {
                    showingSearch.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .font(.largeTitle)
            }
            .foregroundColor(.black)
            .shadow(color: .white, radius: 10)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background {
                Image(.defaultBg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(.ultraThinMaterial.opacity(0.75))
            }
            .contentShape(Rectangle())
            .clipped()
            .sheet(isPresented: $showingSearch) {
                searchBuilder.view(locationBinding: $viewModel.location)
                    .alert(isPresented: $showingAlert, error: viewModel.error) {
                        Button("Ok", role: .cancel) { }
                    }
            }
            .onReceive(viewModel.$error) { error in
                guard error != nil else { return }
                showingAlert = true
            }
            .onReceive(viewModel.$dismissSearch) { dismissSearch in
                guard dismissSearch else { return }
                showingSearch = false
            }
    }
}

/// Preview
extension ForecastAddLocationView.ViewModel {
    static let preview: ForecastAddLocationView.ViewModel = ForecastAddLocationView.ViewModel(locationStorage: LocationStoragePreview())
}

struct ForecastAddLocationViewBuilderPreview: ForecastAddLocationViewBuilder {
    let view: AnyView = AnyView(
        ForecastAddLocationView(
            viewModel: .preview,
            searchBuilder: ForecastLocationSearchViewBuilderPreview()
        )
    )
}

#Preview {
    ForecastAddLocationView(
        viewModel: .preview,
        searchBuilder: ForecastLocationSearchViewBuilderPreview()
    )
}
