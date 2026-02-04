//
//  Snapshotting.swift
//  Sampler
//
//  Created by Daniel on 2026-02-04.
//

import Foundation
import SnapshotTesting
import UIKit
import SwiftUI

// MARK: Recording
enum SnapshottingRecordState: String {
    case none = "NONE"
    case all = "ALL"
    case failed = "FAILED"
    
    var configuration: SnapshotTestingConfiguration.Record? {
        switch self {
        case .none:
            nil
        case .all:
            .all
        case .failed:
            .failed
        }
    }
}

public func assertSnapshotRecordable<Value, Format>(
  of value: Value,
  as snapshotting: Snapshotting<Value, Format>,
  named name: String? = nil,
  record recording: Bool? = nil,
  timeout: TimeInterval = 5,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column
) {
    guard let recordingStateRaw = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"],
          let recordingState = SnapshottingRecordState(rawValue: recordingStateRaw) else {
        fatalError("Ensure to set the RECORD_SNAPSHOTS environment variable for the test configuration.")
    }
    
    withSnapshotTesting(record: recordingState.configuration) {
        SnapshotTesting.assertSnapshot(of: value,
                                       as: snapshotting,
                                       named: name,
                                       record: recording,
                                       timeout: timeout,
                                       fileID: fileID,
                                       file: filePath,
                                       testName: testName,
                                       line: line,
                                       column: column)
    }
}

// MARK: UIView
public func assertSnapshotSuite<Value>(
    of value: Value,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
  ) where Value: UIView {
      assertSnapshotRecordable(of: value,
                               as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                               named: "light mode",
                               fileID: fileID,
                               file: filePath,
                               testName: testName,
                               line: line,
                               column: column)
      assertSnapshotRecordable(of: value,
                               as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                               named: "dark mode",
                               fileID: fileID,
                               file: filePath,
                               testName: testName,
                               line: line,
                               column: column)
}

// MARK: UIViewController
public func assertSnapshotSuite<Value>(
  of value: Value,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column
) where Value: UIViewController {
    assertSnapshotRecordable(of: value,
                             as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                             named: "light mode",
                             fileID: fileID,
                             file: filePath,
                             testName: testName,
                             line: line,
                             column: column)
    assertSnapshotRecordable(of: value,
                             as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                             named: "dark mode",
                             fileID: fileID,
                             file: filePath,
                             testName: testName,
                             line: line,
                             column: column)
}

// MARK: View
public func assertSnapshotSuite<Value>(
  of value: Value,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column
) where Value: View {
    assertSnapshotRecordable(of: value,
                             as: .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                             named: "light mode",
                             fileID: fileID,
                             file: filePath,
                             testName: testName,
                             line: line,
                             column: column)
    assertSnapshotRecordable(of: value,
                             as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)),
                             named: "dark mode",
                             fileID: fileID,
                             file: filePath,
                             testName: testName,
                             line: line,
                             column: column)
}
