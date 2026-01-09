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
     Prefetches a list of images given by URLs.
     - Parameters:
        - urls: List of images given by URLs.
        - reset: Boolean value determining to reset and cancel all currently running prefetch jobs.
     */
    func prefetchImages(_ urls: [URL], reset: Bool)

    /**
     Set a UIImageView with an image from a specified URL. This image could be downloaded or fetched from the cache.
     This process is done asynchronously.
     - Parameters:
        - imageView: The UIImageView to set.
        - url: The URL of the image to be set to the UIImageView.
        - placeholder: The placholder image to be set if the image from the URL fails.
     */
    func setImage(imageView: UIImageView,
                  url: URL?,
                  placeholder: UIImage?)
    
    /**
     Cancel any loading and setting of an image within a UIImageView.
     - Parameter imageView: The UIImageView to cancel.
     */
    func cancelImage(imageView: UIImageView)
}
