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
                .sheet(isPresented: $showingSearch) {
                    searchBuilder.view(locationBinding: $viewModel.location)
                }
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
