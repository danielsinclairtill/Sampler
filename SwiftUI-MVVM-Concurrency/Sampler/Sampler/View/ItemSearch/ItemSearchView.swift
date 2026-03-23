//
//  ItemSearchView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ItemSearchView: View {
    @State private var viewModel: ItemSearchViewModel
    
    init(viewModel: ItemSearchViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No Results Found")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var startView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Start Searching")
                .font(.headline)
            Text("Enter a search term to find recipes")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingAnimation: some View {
        ProgressView()
            .frame(width: 50, height: 50)
            .foregroundColor(.blue)
    }
    
    var body: some View {
        ZStack {
            if viewModel.output.items.isEmpty &&
                !viewModel.output.isRefreshing &&
                !viewModel.output.searchText.isEmpty {
                emptyView
            } else if viewModel.output.searchText.isEmpty {
                startView
            } else if viewModel.output.isRefreshing {
                loadingAnimation
                    .onAppear {
                        viewModel.refresh()
                    }
            } else {
                List {
                    ForEach(viewModel.output.items.enumerated(), id: \.element.id) { index, item in
                        ItemCell(item: item, imageManager: viewModel.imageManager)
                            .onTapGesture {
                                viewModel.cellTapped(index: index)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                            .listRowSeparator(.hidden)
                    }
                    
                    if viewModel.output.hasMorePages {
                        LoadingCell()
                            .onAppear {
                                viewModel.loadNextPage()
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.output.searchText, prompt: "Search recipes")
        .navigationTitle("Search")
        .apiErrorAlert($viewModel.output.error) {
            viewModel.refreshBegin()
        }
    }
}

#Preview {
    ItemSearchView(viewModel: ItemSearchViewModel(router: ItemSearchRouter()))
}
