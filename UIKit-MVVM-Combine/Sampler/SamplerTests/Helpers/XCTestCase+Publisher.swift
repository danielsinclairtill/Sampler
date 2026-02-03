//
//  XCTestCase+Publisher.swift
//  Sampler
//
//  Created by Daniel on 2026-02-02.
//

import XCTest
import Combine

extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This helper waits for the first emission
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    result = .failure(error)
                    expectation.fulfill()
                }
            },
            receiveValue: { value in
                result = .success(value)
                expectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        
        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        case .none: throw XCTSkip("Publisher did not emit within timeout")
        }
    }
    
    /// Waits for a publisher to emit a specific value (equatable).
    func waitForValue<T: Publisher>(
        _ publisher: T,
        toBe expectedValue: T.Output,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Output: Equatable {
        
        let expectation = self.expectation(description: "Wait for value \(expectedValue)")
        
        let cancellable = publisher
            .filter { $0 == expectedValue } // Only trigger if it matches
            .first() // Finish after the first match
            .sink(receiveCompletion: { _ in
                // If it finishes without emitting, we let the timeout handle failure
            }, receiveValue: { _ in
                expectation.fulfill()
            })
        
        // Wait
        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                // If we timed out, it means we never saw the value
                XCTFail("Timed out waiting for value to be \(expectedValue)", file: file, line: line)
            }
        }
        
        cancellable.cancel()
    }
}
