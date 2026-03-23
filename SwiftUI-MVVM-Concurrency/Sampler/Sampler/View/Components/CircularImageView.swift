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
    let placeholder: Image?
    let size: CGFloat
    
    init(url: URL?,
         placeholder: Image? = nil,
         size: CGFloat) {
        self.url = url
        self.placeholder = placeholder
        self.size = size
    }

    var body: some View {
        AsyncImageView(url: url,
                       placeholder: placeholder)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

#Preview {
    CircularImageView(url: nil, size: 40)
}
