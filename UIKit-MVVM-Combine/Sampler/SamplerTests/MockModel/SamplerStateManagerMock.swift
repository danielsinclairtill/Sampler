//
//  SamplerStateManagerMock.swift
//  SamplerTests
//
//
//

import Foundation
@testable import Sampler

class SamplerStateManagerMock: SamplerStateContract {
    var user: Sampler.AuthUser?
    var theme: SamplerDesignTheme = .plain
}
