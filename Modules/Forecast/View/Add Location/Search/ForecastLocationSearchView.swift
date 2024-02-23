//
//  ForecastLocationSearchView.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import SwiftUI

struct ForecastLocationSearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ViewModel
    
    @Binding var location: NamedLocation?
    
    init(viewModel: @escaping @autoclosure () -> ViewModel, location: Binding<NamedLocation?>) {
        _viewModel = .init(wrappedValue: viewModel())
        _location = location
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List($viewModel.searchResults, id: \.self, selection: $viewModel.selection) { $item in
                    VStack(alignment: .leading) {
                        Text(item)
                    }
                }
                .searchable(text: $viewModel.text, prompt: Text("Search"))
                .autocorrectionDisabled()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .foregroundColor(.black)
            .onReceive(viewModel.$dismiss) { shouldDismiss in
                guard shouldDismiss else { return }
                dismiss()
            }
            .onReceive(viewModel.$location) { location in
                guard let location else { return }
                self.location = location
            }
        }
    }
}

fileprivate struct LocationSearchingPreview: LocationSearching {
    func location(for query: String) async throws -> NamedLocation {
        throw NSError(domain: "", code: 0)
    }
    
    func search(query: String) async throws -> [String] {
        return ["Kyiv"]
    }
}

extension ForecastLocationSearchView.ViewModel {
    static let preview: ForecastLocationSearchView.ViewModel = ForecastLocationSearchView.ViewModel(locationFinder: LocationSearchingPreview())
}

struct ForecastLocationSearchView_Preview: PreviewProvider {
    @Environment(\.dismiss) var dismiss
    static var previews: some View {
        ForecastLocationSearchView(viewModel: .preview, location: .constant(nil)).body
    }
}

struct ForecastLocationSearchViewBuilderPreview: ForecastLocationSearchViewBuilder {
    func view(locationBinding: Binding<NamedLocation?>) -> AnyView {
        AnyView(
            ForecastLocationSearchView(viewModel: .preview, location: .constant(nil))
        )
    }
}
