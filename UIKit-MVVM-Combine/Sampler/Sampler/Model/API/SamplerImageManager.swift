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
    
    func setImage(imageView: UIImageView,
                  url: URL?,
                  placeholder: UIImage? = nil) {
        imageView.sd_setImage(with: url,
                              placeholderImage: placeholder,
                              options: [.continueInBackground])
    }
    
    func cancelImage(imageView: UIImageView) {
        imageView.sd_cancelCurrentImageLoad()
    }
}
