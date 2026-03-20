//
//  CircularImageView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Kingfisher

struct CircularImageView: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImageView(url: url)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

#Preview {
    CircularImageView(url: nil, size: 40)
}
