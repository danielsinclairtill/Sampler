//
//  AvatarView.swift
//  Sampler
//
//  Created by Daniel Till on 2023-08-22.
//

import Foundation
import UIKit

class AvatarView: AsyncImageView {
    required init(placeholderImage: UIImage?,
                  size: CGFloat) {
        super.init(placeholderImage: placeholderImage)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor),
            widthAnchor.constraint(equalToConstant: size)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(placeholderImage: UIImage?, cornerRadius: CGFloat = 0.0, frame: CGRect = .zero) {
        fatalError("init(placeholderImage:cornerRadius:frame:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // make sure the avatar is circular
        layer.cornerRadius = frame.width / 2.0
    }
}
