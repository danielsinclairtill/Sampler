//
//  RootView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI

/// Root view that manages navigation between Login and Main app screens
struct RootView: View {
    @Environment(SamplerEnvironment.self) var environment
    @StateObject private var tabRouter = TabRouter()
    
    var body: some View {
        ZStack {
            TabView(selection: $tabRouter.selectedTab) {
                NavigationStack(path: $tabRouter.itemsListRouter.navigationPath) {
                    ItemsListView(viewModel: ItemsListViewModel(router: tabRouter.itemsListRouter))
                        .navigationDestination(for: ItemsListDestination.self) { destination in
                            switch destination {
                            case .itemDetail(let id):
                                EmptyView()
                            }
                        }
                }
                .tabItem { Label("com.danielsinclairtill.Sampler.itemsList.title", systemImage: "list.bullet") }
                .tag(0)
            }
        }
    }
}

#Preview {
    RootView()
        .environment(SamplerEnvironment.mock)
}
