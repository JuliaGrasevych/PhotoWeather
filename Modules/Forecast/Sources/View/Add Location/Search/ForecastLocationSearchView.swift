//
//  ForecastLocationSearchView.swift
//  Forecast
//
//  Created by Julia Grasevych on 19.02.2024.
//

import Foundation
import SwiftUI
import ForecastDependency

@MainActor
struct ForecastLocationSearchView<VM: ForecastLocationSearchViewModelProtocol>: View {
    @Environment(\.dismiss) var dismiss
    @State private var isPresented = true
    @StateObject private var viewModel: VM
    
    @Binding var location: NamedLocation?
    
    init(viewModel: @escaping @autoclosure () -> VM, location: Binding<NamedLocation?>) {
        _viewModel = .init(wrappedValue: viewModel())
        _location = location
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.outputBinding.searchResults, id: \.self, selection: viewModel.inputBinding.selection) { $item in
                    VStack(alignment: .leading) {
                        Text(item)
                    }
                }
                .searchable(text: viewModel.inputBinding.text, isPresented: $isPresented, prompt: Text("Search"))
                .autocorrectionDisabled()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .foregroundStyle(Color.accentColor)
            .onReceive(viewModel.output.$location) { location in
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

extension ForecastLocationSearchViewModel {
    static let preview: ForecastLocationSearchViewModel = ForecastLocationSearchViewModel(locationFinder: LocationSearchingPreview())
}

struct ForecastLocationSearchView_Preview: PreviewProvider {
    @Environment(\.dismiss) var dismiss
    static var previews: some View {
        ForecastLocationSearchView(viewModel: ForecastLocationSearchViewModel.preview, location: .constant(nil)).body
    }
}

struct ForecastLocationSearchViewBuilderPreview: ForecastLocationSearchViewBuilder {
    @MainActor
    func view(locationBinding: Binding<NamedLocation?>) -> AnyView {
        AnyView(
            ForecastLocationSearchView(viewModel: ForecastLocationSearchViewModel.preview, location: .constant(nil))
        )
    }
}
