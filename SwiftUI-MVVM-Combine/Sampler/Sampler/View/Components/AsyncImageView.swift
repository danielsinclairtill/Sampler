//
//  AsyncImageView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Kingfisher

struct AsyncImageView: View {
    let url: URL?
    let placeholder: Image?
    
    init(url: URL?,
         placeholder: Image? = nil) {
        self.url = url
        self.placeholder = placeholder
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        if let placeholder {
            placeholder
                .resizable()
                .scaledToFit()
        } else {
            Color(.systemGray6)
        }
    }

    var body: some View {
        if SamplerEnvironment.isTesting {
            placeholderView
        } else {
            KFImage(url)
                .placeholder {
                    placeholderView
                }
                .fade(duration: 0.25)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    AsyncImageView(url: nil)
        .frame(height: 200)
}
