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
class AsyncImageView: UIView {
    private var cancelBag = Set<AnyCancellable>()
    private let placeholderImage: UIImage?
    private var cornerRadius: CGFloat
    
    private lazy var placeholder: UIImageView = {
        let placeholder = UIImageView()
        placeholder.image = placeholderImage
        placeholder.alpha = 1.0
        placeholder.backgroundColor = SamplerDesign.shared.theme.attributes.colors.temporary()
        placeholder.layer.cornerRadius = cornerRadius
        placeholder.clipsToBounds = true
        
        return placeholder
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = nil
        image.contentMode = .scaleAspectFill
        image.alpha = 0.0
        image.layer.cornerRadius = cornerRadius
        image.clipsToBounds = true
        
        return image
    }()
    
    /// An image view which loads an image from an URL. It may also show a placeholder image while the image from the URL is loading.
    /// - Parameters:
    ///   - placeholderImage: Placeholder image to show while the image from the URL is loading.
    ///   - cornerRadius: Corner radius of the image.
    ///   - frame: Frame of the image.
    required init(placeholderImage: UIImage?,
                  cornerRadius: CGFloat = 0.0,
                  frame: CGRect = .zero) {
        self.placeholderImage = placeholderImage
        self.cornerRadius = cornerRadius
        
        super.init(frame: frame)
        
        setDesign()
        
        backgroundColor = .clear
        clipsToBounds = true
        
        // layoutsubviews
        addSubview(placeholder)
        addSubview(image)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: topAnchor),
            placeholder.bottomAnchor.constraint(equalTo: bottomAnchor),
            placeholder.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholder.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.topAnchor.constraint(equalTo: topAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDesign() {
        SamplerDesign.shared.$theme
            .sink { [weak self] theme in
                self?.placeholder.backgroundColor = theme.attributes.colors.temporary()
            }
            .store(in: &cancelBag)
    }
    
    /// The the image from an URL to load. Requires an ImageManager to load the image.
    func setImage(url: URL,
                  imageManager: ImageManagerContract) {
        imageManager.setImageView(imageView: image,
                                  url: url)
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        cornerRadius = radius
        image.layer.cornerRadius = radius
        placeholder.layer.cornerRadius = radius
    }
    
    /// Remove and clear the image from the view.
    func clearImage() {
        image.image = nil
        image.alpha = 0.0
    }
}
