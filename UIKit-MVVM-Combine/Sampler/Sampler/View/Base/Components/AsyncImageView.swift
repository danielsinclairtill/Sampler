//
//  AsyncImageView.swift
//  Sampler
//
//
//

import Foundation
import UIKit
import Combine


/// An image view which loads an image from an URL. It may also show a placeholder image while the image from the URL is loading.
class AsyncImageView: UIImageView {
    /// An image view which loads an image from an URL. It may also show a placeholder image while the image from the URL is loading.
    /// - Parameters:
    ///   - placeholderImage: Placeholder image to show while the image from the URL is loading.
    ///   - cornerRadius: Corner radius of the image.
    ///   - frame: Frame of the image.
    required init(placeholderImage: UIImage?,
                  cornerRadius: CGFloat = 0.0,
                  frame: CGRect = .zero) {
        super.init(frame: frame)
                
        backgroundColor = .clear
        clipsToBounds = true
        image = nil
        contentMode = .scaleAspectFill
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The the image from an URL to load. Requires an ImageManager to load the image.
    func setImage(url: URL,
                  placeholder: UIImage? = UIImage.solid(color: SamplerDesign.shared.theme.attributes.colors.temporary()),
                  imageManager: ImageManagerContract) {
        imageManager.setImage(imageView: self,
                              url: url,
                              placeholder: placeholder)
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    /// Remove and clear the image from the view.
    func clearImage(imageManager: ImageManagerContract? = nil) {
        imageManager?.cancelImage(imageView: self)
        image = nil
    }
}
