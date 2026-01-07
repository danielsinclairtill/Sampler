//
//  SizeProvidingCell.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import UIKit

public protocol SizeProvidingCell {
    /// Gives the ideal size of a cell given the width it is allowed to be placed in.
    /// - Parameter width: The width it is allowed to be placed in.
    /// - Returns: The ideal size of a cell
    func sizeFor(width: CGFloat) -> CGSize
}
