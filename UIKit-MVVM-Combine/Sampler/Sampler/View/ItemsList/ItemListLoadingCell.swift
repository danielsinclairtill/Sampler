//
//  ItemListLoadingCell.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import Foundation
import UIKit
import Combine
import Lottie

final class ItemListLoadingCell: UICollectionViewCell {
    private enum Sizes {
        static let animation = 100.0
    }
    
    private lazy var spinner: LottieAnimationView = {
        let loadingAnimationView = LottieAnimationView(name: "loading_animation")
        loadingAnimationView.isHidden = false
        loadingAnimationView.backgroundBehavior = .pauseAndRestore
        return loadingAnimationView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: Sizes.animation),
            spinner.heightAnchor.constraint(equalToConstant: Sizes.animation)
        ])
        spinner.loopMode = .loop
        spinner.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ItemListLoadingCell: SizeProvidingCell {
    func sizeFor(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 100.0)
    }
}
