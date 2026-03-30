//
//  LikeManager.swift
//  Sampler
//
//  Created by Daniel on 2026-03-26.
//

import Foundation

protocol LikeManagerContract: AnyObject, Observable {
    var likedItemIds: Set<String> { get }
    func loadLikes()
    func isLiked(_ id: String) -> Bool
    func toggleLike(_ id: String)
}

@Observable
final class LikeManager: LikeManagerContract {
    private(set) var likedItemIds: Set<String> = []
    private let state: any SamplerStateContract

    init(state: any SamplerStateContract) {
        self.state = state
    }

    func loadLikes() {
        likedItemIds = .init(state.likedItemIds)
    }

    func isLiked(_ id: String) -> Bool {
        likedItemIds.contains { $0 == id }
    }

    func toggleLike(_ id: String) {
        if isLiked(id) {
            likedItemIds.remove(id)
        } else {
            likedItemIds.insert(id)
        }
        state.likedItemIds = .init(likedItemIds)
    }
}
