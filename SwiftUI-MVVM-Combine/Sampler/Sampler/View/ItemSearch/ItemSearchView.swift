//
//  ItemSearchView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ItemSearchView: View {
    @StateObject private var viewModel: ItemSearchViewModel

    @State private var searchText = ""
    
    init(viewModel: ItemSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                !searchText.isEmpty {
                emptyView
            } else if searchText.isEmpty {
                startView
            } else if viewModel.output.isRefreshing {
                loadingAnimation
                    .onAppear {
                        viewModel.input.refresh.send(())
                    }
            } else {
                List {
                    ForEach(viewModel.output.items.enumerated(), id: \.element.id) { index, item in
                        ItemCell(item: item, imageManager: viewModel.imageManager)
                            .onTapGesture {
                                viewModel.input.cellTapped.send((index))
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                            .listRowSeparator(.hidden)
                    }
                    
                    if viewModel.output.hasMorePages {
                        LoadingCell()
                            .onAppear {
                                viewModel.input.loadNextPage.send(())
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search recipes")
        .onChange(of: searchText) { oldValue, newValue in
            viewModel.input.searchText = newValue
        }
        .navigationTitle("Search")
        .apiErrorAlert($viewModel.output.error) {
            viewModel.input.refresh.send(())
        }
    }
}

#Preview {
    ItemSearchView(viewModel: ItemSearchViewModel(router: ItemSearchRouter()))
}
