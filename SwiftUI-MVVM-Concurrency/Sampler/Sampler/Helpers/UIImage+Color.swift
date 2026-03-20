//
//  UIImage+Color.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import UIKit

extension UIImage {
    static func solid(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
