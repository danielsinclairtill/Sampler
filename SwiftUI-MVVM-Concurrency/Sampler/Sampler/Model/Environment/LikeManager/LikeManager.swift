//
//  LikeManager.swift
//  Sampler
//
//  Created by Daniel on 2026-03-26.
//

import Foundation

protocol LikeManagerContract {
    var likedItemIds: [String] { get }
    func loadLikes()
    func isLiked(_ id: String) -> Bool
    func toggleLike(_ id: String)
}

@Observable
final class LikeManager: LikeManagerContract {
    private(set) var likedItemIds: [String] = []
    private let state: any SamplerStateContract

    init(state: any SamplerStateContract) {
        self.state = state
    }

    func loadLikes() {
        likedItemIds = state.likedItemIds
    }

    func isLiked(_ id: String) -> Bool {
        likedItemIds.contains { $0 == id }
    }

    func toggleLike(_ id: String) {
        if isLiked(id) {
            likedItemIds.removeAll(where: { $0 == id })
        } else {
            likedItemIds.append(id)
        }
        state.likedItemIds = likedItemIds
    }
}
