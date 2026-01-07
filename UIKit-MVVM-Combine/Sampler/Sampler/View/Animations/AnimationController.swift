//
//  AnimationController.swift
//  Sampler
//
//
//

import Foundation
import UIKit

class AnimationController {
    static private let fadeDuration = 0.5
    static private let bounceDuration = 0.5
    static private let quickTapDuration = 0.15
    static private let springDamping: CGFloat = 0.5
    static private let initialSpringVelocity: CGFloat = 15.0
    static private let pressedOnScale: CGFloat = 0.9
    
    private var isSelected = false
    
    // MARK: Resizing
    static func shrinkView(_ view: UIView,
                           duration: TimeInterval,
                           completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [.allowUserInteraction, .curveEaseOut],
            animations: { view.transform = CGAffineTransform(scaleX: pressedOnScale, y: pressedOnScale) },
            completion: completion
        )
    }
    
    static func expandView(_ view: UIView,
                           duration: TimeInterval,
                           completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [.allowUserInteraction, .curveEaseOut],
            animations: { view.transform = .identity },
            completion: completion
        )
    }
    
    // MARK: Fades
    /// Fade in a view changing the alpha value over a time interval.
    /// - Parameters:
    ///   - view: The view to fade in.
    ///   - delay: The time it takes for the fade.
    ///   - completion: Completion block to call after the fade completes.
    static func fadeInView(_ view: UIView,
                           delay: TimeInterval = 0.0,
                           completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationController.fadeDuration,
            delay: delay,
            options: [.curveEaseInOut],
            animations: { view.alpha = 1.0 },
            completion: completion
        )
    }
    
    /// Fade out a view changing the alpha value over a time interval.
    /// - Parameters:
    ///   - view: The view to fade out.
    ///   - delay: The time it takes for the fade.
    ///   - completion: Completion block to call after the fade completes.
    static func fadeOutView(_ view: UIView,
                            delay: TimeInterval = 0.0,
                            completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationController.fadeDuration,
            delay: delay,
            options: [.curveEaseInOut],
            animations: { view.alpha = 0.0 },
            completion: completion
        )
    }
}

// MARK: Tap Bounce
extension AnimationController {
    func createTapBounceAnitmationOnTouchBeganTo(view: UIView) {
        isSelected = true
        AnimationController.shrinkView(view, duration: AnimationController.quickTapDuration, completion: { [weak self] completed in
            if completed && !(self?.isSelected ?? false) {
                AnimationController.expandView(view, duration: AnimationController.quickTapDuration, completion: nil)
            }
        })
    }
    
    func createTapBounceAnitmationOnTouchEndedTo(view: UIView) {
        isSelected = false
        if view.layer.animationKeys()?.isEmpty ?? true {
            AnimationController.expandView(view, duration: AnimationController.bounceDuration, completion: nil)
        }
    }
    
    func createTapBounceAnitmationOnTouchCancelledTo(view: UIView) {
        isSelected = false
        AnimationController.expandView(view, duration: AnimationController.bounceDuration, completion: nil)
    }
}
