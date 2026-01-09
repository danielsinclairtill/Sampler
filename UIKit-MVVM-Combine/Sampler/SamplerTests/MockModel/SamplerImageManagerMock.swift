//
//  SamplerImageManagerMock.swift
//  SamplerTests
//
//
//
//

import Foundation
@testable import Sampler
import UIKit

class SamplerImageManagerMock: ImageManagerContract {
    /// List of mock prefetch taks called during this API session in order.
    var mockPrefetchTaskURLs: [URL] = []
    
    func reset() {
        mockPrefetchTaskURLs = []
    }
    
    func prefetchImages(_ urls: [URL], reset: Bool) {
        if reset {
            mockPrefetchTaskURLs = []
        }
        mockPrefetchTaskURLs += urls
    }

    func setImage(imageView: UIImageView, url: URL?, placeholder: UIImage?) {
        return
    }
    
    
    func cancelImage(imageView: UIImageView) {
        return
    }
}
