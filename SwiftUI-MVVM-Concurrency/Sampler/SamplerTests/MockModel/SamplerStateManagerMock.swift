//
//  SamplerStateManagerMock.swift
//  SamplerTests
//
//
//

import Foundation
import Combine
@testable import Sampler

class SamplerStateManagerMock: SamplerStateContract {
    var user: Sampler.AuthUser?
    var theme: SamplerDesignTheme = .plain
    var likedItemIds: [String] = []
}
