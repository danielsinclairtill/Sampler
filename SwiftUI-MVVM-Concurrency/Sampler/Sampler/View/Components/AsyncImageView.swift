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

    var body: some View {
        KFImage(url)
            .placeholder { Color(.systemGray6) }
            .fade(duration: 0.25)
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    AsyncImageView(url: nil)
        .frame(height: 200)
}
