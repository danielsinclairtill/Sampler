//
//  SamplerAPIImageManager.swift
//  Sampler
//
//
//
//

import Foundation
import UIKit
import SDWebImage

class SamplerAPIImageManager: ImageManagerContract {
    private var prefetchTask: SDWebImagePrefetchToken?
    
    func prefetchImages(_ urls: [URL], reset: Bool) {
        if reset {
            // cancel current image prefetch task
            prefetchTask?.cancel()
            prefetchTask = nil
        }
        
        // prefetch images for current list provided
        prefetchTask = SDWebImagePrefetcher.shared.prefetchURLs(urls)
    }
    
    private func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: url,
                                           options: [],
                                           progress: nil)
        { (image, data, error, cacheType, finished, url) in
            guard error == nil else { return }
            if let image = image {
                // call on main thread
                completion(image)
            }
        }
    }
    
    func setImageView(imageView: UIImageView, url: URL?) {
        guard let imageUrl = url else { return }
        let fetchTime = Date()
        
        fetchImage(url: imageUrl) { (image) in
            guard let image = image else { return }
            let imageFetchTime = Date().timeIntervalSince(fetchTime)
            
            imageView.image = image
            if imageFetchTime > 0.25 {
                AnimationController.fadeInView(imageView)
            } else {
                imageView.alpha = 1.0
            }
        }
    }
}
