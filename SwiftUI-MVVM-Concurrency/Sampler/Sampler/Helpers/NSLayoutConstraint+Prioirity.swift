//
//  UIView+NSLayout.swift
//  Sampler
//
//  Created by Daniel on 2026-02-01.
//

import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
