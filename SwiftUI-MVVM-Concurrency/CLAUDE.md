# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project — there is no Makefile or CLI build system.

- **Open project**: `open Sampler/Sampler.xcodeproj`
- **Build from CLI**: `xcodebuild -project Sampler/Sampler.xcodeproj -scheme Sampler -destination 'platform=iOS Simulator,name=iPhone 16' build`
- **Run tests**: `xcodebuild -project Sampler/Sampler.xcodeproj -scheme Sampler -destination 'platform=iOS Simulator,name=iPhone 16' test`
- **Run a single test**: `xcodebuild -project Sampler/Sampler.xcodeproj -scheme Sampler -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:SamplerTests/TargetTestClass/testMethodName`

The `SamplerMacros` Swift package (under `Sampler/SamplerMacros/`) is a local dependency — it is built automatically as part of the Xcode project.

## Architecture Overview

The app follows **MVVM + Repository + Protocol-based DI**, using Swift 5.9+ `@Observable` (not Combine).

### Layer Summary

| Layer | Location | Responsibility |
|---|---|---|
| Views + ViewModels | `Sampler/View/` | UI + feature logic |
| Repositories | `Sampler/Model/Repository/` | Data access (API + CoreData) |
| API client | `Sampler/Model/API/` | URLSession REST requests |
| CoreData store | `Sampler/Model/Store/` | Persistence via `SamplerStore` |
| State | `Sampler/Model/State/` | Auth state, theme, likes (UserDefaults) |
| DI container | `Sampler/Model/Environment/` | `SamplerEnvironment` singleton |
| Navigation | `Sampler/Router/` | Protocol-based routers with `NavigationPath` |

### ViewModel Input/Output Pattern

Every feature ViewModel is structured as a nested enum with three nested types:

```swift
enum ItemsListViewModelBinding {
    protocol Contract: Input { var output: Output { get } }
    protocol Input { func viewDidLoad(); func refresh(); ... }
    @Observable class Output { var items: [Item] = []; var isRefreshing = false }
}

@Observable
class ItemsListViewModel: ItemsListViewModelBinding.Contract { ... }
```

- **Input** — methods called by the View (user actions, lifecycle hooks)
- **Output** — `@Observable` class holding all view state
- **Contract** — combines Input + read-only `output` access; this is what Views hold

Views hold a `Contract` reference so they can be handed a mock in tests/previews.

### Dependency Injection

`SamplerEnvironment` is the single DI container (singleton). ViewModels declare their dependencies as a composed protocol typealias:

```swift
typealias Environment = ItemRepositoryProvider & LikeManagerProvider
```

Each provider protocol exposes one dependency (e.g., `var itemRepository: ItemRepository`). The ViewModel receives the environment at init. `SamplerTestEnvironment` provides test doubles.

### `@Observable` Reactivity

`ObserveBag` (in `Sampler/Helpers/ObserveBag.swift`) wraps `withObservationTracking` to observe `@Observable` objects from within ViewModels (not Views). Use it when a ViewModel needs to react to changes on another `@Observable` object (e.g., `LikeManager`).

### Repository / Data Flow

Repositories return `DataResult<T>`, which wraps the value with a `DataSource` tag (`.api` or `.store`). The typical strategy is: check CoreData first, fall back to the API, then persist the result.

### Navigation

Each feature has a `Router` conforming to `NavigationRouter`, with a `Destination` enum for type-safe push navigation. `TabRouter` owns the top-level tab state and child routers. Routers are `@MainActor`.

### Swift Macros

`@Mockable` (defined in `SamplerMacros`) generates no-op mock implementations of an `Input` protocol. Applied to the binding enum and only compiled in `DEBUG`. This enables SwiftUI previews and unit tests to use the mock without hand-writing stubs.

## Key Dependencies

- **Kingfisher** — image downloading/caching (`SamplerImageManager`)
- **Lottie** — animations
- **swift-snapshot-testing** — snapshot tests in `SamplerTests/`
- **SamplerMacros** — local Swift macro package (`Sampler/SamplerMacros/`)
