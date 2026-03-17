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
    @StateObject var environment = SamplerEnvironment()
    
    var body: some Scene {
        WindowGroup {
            if !SamplerEnvironment.isTesting {
                RootView()
                    .environmentObject(environment)
            } else {
                EmptyView()
            }
        }
    }
}
