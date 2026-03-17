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
}
