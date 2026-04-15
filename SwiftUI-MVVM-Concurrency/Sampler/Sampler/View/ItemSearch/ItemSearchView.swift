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
        VStack {
            Image("empty")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var startView: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 24, height: 24)
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
                        ItemCell(item: item)
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
        .searchable(text: $viewModel.output.searchText)
        .navigationTitle(String(localized: "com.danielsinclairtill.Sampler.itemSearch.title"))
        .apiErrorAlert(viewModel.output.error) {
            viewModel.refreshBegin()
        }
    }
}

#Preview {
    ItemSearchView(viewModel: ItemSearchViewModel(router: ItemSearchRouter()))
}
