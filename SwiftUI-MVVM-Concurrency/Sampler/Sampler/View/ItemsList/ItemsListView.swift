//
//  ItemsListView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ItemsListView: View {
    @State private var viewModel: ItemsListViewModel
    
    init(viewModel: ItemsListViewModel) {
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
    
    private var loadingAnimation: some View {
        ProgressView()
            .frame(width: 50, height: 50)
            .foregroundColor(.blue)
    }
    
    var body: some View {
        ZStack {
            if viewModel.output.isRefreshing {
                loadingAnimation
                    .onAppear {
                        viewModel.refresh()
                    }
            } else if viewModel.output.items.isEmpty {
                emptyView
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
                .refreshable {
                    viewModel.refreshBegin()
                }
            }
        }
        .navigationTitle(String(localized: "com.danielsinclairtill.Sampler.itemsList.title"))
        .onAppearOnce {
            viewModel.viewDidLoad()
        }
        .apiErrorAlert(viewModel.output.error) {
            viewModel.refreshBegin()
        }
    }
}

struct ItemCell: View {
    let item: Item
    let imageManager: ImageManagerContract
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            AsyncImageView(
                url: item.image,
            )
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name ?? "")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(item.ingredients?.joined(separator: ", ") ?? "")
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct LoadingCell: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

#Preview {
    ItemsListView(viewModel: ItemsListViewModel(router: ItemsListRouter()))
}
