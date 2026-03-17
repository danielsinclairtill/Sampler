//
//  ItemsListView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ItemsListView: View {
    @StateObject private var viewModel: ItemsListViewModel
    
    init(viewModel: ItemsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No Items Found")
                .font(.headline)
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
                        viewModel.input.refresh.send(())
                    }
            } else if viewModel.output.items.isEmpty {
                emptyView
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
                .refreshable {
                    viewModel.input.refreshBegin.send(())
                }
            }
        }
        .navigationTitle("Recipes")
        .onAppearOnce {
            viewModel.input.viewDidLoad.send(())
        }
        .apiErrorAlert($viewModel.output.error) {
            viewModel.input.refresh.send(())
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
            .frame(width: 100, height: 150)
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
