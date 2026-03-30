//
//  SamplerLikeManagerMock.swift
//  Sampler
//
//  Created by Daniel on 2026-03-30.
//

import Foundation
@testable import Sampler

@Observable
final class SamplerLikeManagerMock: LikeManagerContract {
    var likedItemIds: Set<String> = []

    func loadLikes() {
        likedItemIds = likedItemIds
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
    }
}
