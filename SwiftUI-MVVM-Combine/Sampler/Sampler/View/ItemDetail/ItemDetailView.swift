//
//  ItemDetailView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ItemDetailView: View {    
    @StateObject private var viewModel: ItemDetailViewModel
    
    init(viewModel: ItemDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Item Image
                if let photoURL = viewModel.output.item?.image {
                    AsyncImageView(
                        url: photoURL,
                    )
                    .frame(height: 240)
                    .cornerRadius(12)
                    .clipped()
                }
                
                // Item Title
                Text(viewModel.output.item?.name ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                // Author Info
                HStack(spacing: 12) {
                    CircularImageView(
                        url: viewModel.output.item?.user?.image,
                        size: 40
                    )
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.output.item?.user?.username ?? "")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)
                    
                    Text(viewModel.output.item?.ingredients?.joined(separator: ", ") ?? "")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.input.tappedPostButton.send(())
                    }) {
                        Text("com.danielsinclairtill.Sampler.itemDetail.postButton.title")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        viewModel.input.tappedSaveButton.send(())
                    }) {
                        Text(viewModel.output.isSaved ? "com.danielsinclairtill.Sampler.itemDetail.saveButton.title.saved" : "com.danielsinclairtill.Sampler.itemDetail.saveButton.title.save")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.output.isSaved ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.output.isSaved || viewModel.output.isSaving)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppearOnce {
            viewModel.input.viewDidLoad.send(())
        }
        .errorAlert($viewModel.output.error)
    }
}

#Preview {
    ItemDetailView(viewModel: ItemDetailViewModel(
        itemId: "1",
        environment: SamplerEnvironment.shared)
    )
}
