//
//  SamplerApp.swift
//  Sampler
//
//  Created by Daniel on 2026-03-17.
//

import SwiftUI
import CoreData

@main
struct SamplerApp: App {
    let environment = SamplerEnvironment.shared
    
    var body: some Scene {
        WindowGroup {
            if !SamplerEnvironment.isTesting {
                RootView()
                    .environment(environment)
            } else {
                EmptyView()
            }
        }
    }
}
