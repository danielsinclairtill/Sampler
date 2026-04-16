//
//  ItemDetailView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ItemDetailView: View {
    @State private var viewModel: any ItemDetailViewModelBinding.Contract
    
    init(viewModel: any ItemDetailViewModelBinding.Contract) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Item Image
            AsyncImageView(
                url: viewModel.output.item?.image,
            )
            .frame(width: 240, height: 240)
            .cornerRadius(12)
            .clipped()
            
            // Item Title
            Text(viewModel.output.item?.name ?? " ")
                .font(.title)
                .fontWeight(.bold)
                .lineLimit(2)
            
            // Author Info
            HStack(spacing: 12) {
                CircularImageView(
                    url: viewModel.output.item?.user?.image,
                    placeholder: Image("UnkownUser"),
                    size: 40
                )
                
                VStack(alignment: .leading) {
                    Text(viewModel.output.item?.user?.username ?? " ")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                Spacer()
                Button(action: {
                    viewModel.tappedLikeButton()
                }) {
                    Image(systemName: viewModel.output.isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                }
            }
            .padding(.vertical, 8)
            
            // Description
            Text(viewModel.output.item?.ingredients?.joined(separator: ", ") ?? "")
                .font(.body)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.tappedPostButton()
                    }
                } label: {
                    Text("com.danielsinclairtill.Sampler.itemDetail.postButton.title")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button {
                    Task {
                        await viewModel.tappedSaveButton()
                    }
                } label: {
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
        .onAppearOnce {
            Task {
                await viewModel.viewDidLoad()
            }
        }
        .errorAlert(viewModel.output.error)
    }
}

#if DEBUG
struct ItemDetailPreview: View {
    let output: ItemDetailViewModelBinding.Output

    var body: some View {
        ItemDetailView(viewModel: ItemDetailViewModelBindingMock(output: output))
    }
}

#Preview("Blank") {
    ItemDetailPreview(
        output: .init(
            item: .init(
                name: nil,
                ingredients: [],
                difficulty: nil,
                tags: [],
                image: nil
            ),
            isSaved: false,
            isSaving: false,
            isLiked: false
        )
    )
}


#Preview("Standard") {
    ItemDetailPreview(
        output: .init(
            item: .init(
                name: "Pasta Dish",
                ingredients: ["Tomato", "Basil", "Cheese"],
                difficulty: "Easy",
                tags: ["Dinner"],
                image: nil
            ),
            isSaved: false,
            isSaving: false,
            isLiked: false
        )
    )
}

#Preview("Saved") {
    ItemDetailPreview(
        output: .init(
            item: .init(
                name: "Pasta Dish",
                ingredients: ["Tomato", "Basil", "Cheese"],
                difficulty: "Easy",
                tags: ["Dinner"],
                image: nil
            ),
            isSaved: true,
            isSaving: false,
            isLiked: false
        )
    )
}

#Preview("Saving") {
    ItemDetailPreview(
        output: .init(
            item: .init(
                name: "Pasta Dish",
                ingredients: ["Tomato", "Basil", "Cheese"],
                difficulty: "Easy",
                tags: ["Dinner"],
                image: nil
            ),
            isSaved: false,
            isSaving: true,
            isLiked: false
        )
    )
}
    
#Preview("Liked") {
    ItemDetailPreview(
        output: .init(
            item: .init(
                name: "Pasta Dish",
                ingredients: ["Tomato", "Basil", "Cheese"],
                difficulty: "Easy",
                tags: ["Dinner"],
                image: nil
            ),
            isSaved: false,
            isSaving: false,
            isLiked: true
        )
    )
}
#endif
