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
    
    init(viewModel: @escaping @autoclosure () -> ViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack {
//                TextField(
//                    "Search query",
//                    text: $viewModel.text,
//                    prompt: Text("Search")
//                )
//                
//                .padding(8)
//                .multilineTextAlignment(.center)
//                .background(.gray.opacity(0.25))
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .padding()
                
//                Spacer()
                List($viewModel.searchResults, id: \.description) { $item in
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
        }
    }
}

fileprivate struct LocationSearchingPreview: LocationSearching {
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
        ForecastLocationSearchView(viewModel: .preview).body
    }
}

struct ForecastLocationSearchViewBuilderPreview: ForecastLocationSearchViewBuilder {
    let view: AnyView = AnyView(
            ForecastLocationSearchView(viewModel: .preview)
        )
}
