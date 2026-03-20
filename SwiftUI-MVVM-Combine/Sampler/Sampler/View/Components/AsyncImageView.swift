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

    var body: some View {
        KFImage(url)
            .placeholder {
                if let placeholder {
                    placeholder
                        .resizable()
                        .scaledToFit()
                } else {
                    Color(.systemGray6)
                }
            }
            .fade(duration: 0.25)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    AsyncImageView(url: nil)
        .frame(height: 200)
}
