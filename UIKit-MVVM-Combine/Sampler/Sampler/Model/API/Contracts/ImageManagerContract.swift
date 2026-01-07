//
//  ImageManagerContract.swift
//  Sampler
//
//
//
//

import Foundation
import UIKit

public protocol ImageManagerContract {
    /**
     Prefetches a list of images given by URL.
     - Parameters:
        - urls: List of images given by URLs.
        - reset: Boolean value determining to reset and cancel all currently running prefetch jobs.
     */
    func prefetchImages(_ urls: [URL], reset: Bool)

    /**
     Set an image view with an image from a specified URL. This image could be downloaded or fetched from the cache.
     The image view should by set to alpha 0.0 before calling this.
     When the download is complete, the image from the url is set to the imageView, and alpha is set to 1.0 by this manager.
     This process is done asynchronously.
     - Parameters:
        - imageView: The UIImageView to set.
        - url: The URL of the image to be set to the imageView.
        - placeholder: The placholder image to be set if the image from the url fails.
     */
    func setImage(imageView: UIImageView,
                  url: URL?,
                  placeholder: UIImage?)
    
    /**
     Cancel any loading image within an image view.
     - Parameter imageView: The UIImageView to cancel.
     */
    func cancelImage(imageView: UIImageView)
}
