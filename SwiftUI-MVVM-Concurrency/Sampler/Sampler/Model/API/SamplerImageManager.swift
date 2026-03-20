//
//  SamplerAPIImageManager.swift
//  Sampler
//
//
//
//

import Foundation
import Kingfisher

class SamplerAPIImageManager: ImageManagerContract {
    private var prefetcher: ImagePrefetcher?
    func prefetchImages(_ urls: [URL], reset: Bool) {
        if reset {
            prefetcher?.stop()
            prefetcher = nil
        }
        prefetcher = ImagePrefetcher(urls: urls)
        prefetcher?.start()
    }
}
