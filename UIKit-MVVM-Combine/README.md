# Sampler - UIKit + MVVM + Combine

A scalable and testable iOS application demonstrating the MVVM (Model-View-ViewModel) architectural pattern combined with Apple's Combine framework for reactive programming, all built with UIKit.

## Architectural Components

### MVVM Pattern

This project implements the Model-View-ViewModel (MVVM) pattern, which separates the application into three distinct layers:

- **Model**: Contains business logic, data models, and data persistence
- **View**: UIKit-based UI components that display data
- **ViewModel**: Acts as a bridge between the Model and View, handling user interactions and preparing data for display

#### Component Communication

```
┌─────────────────────────────────────────────────────────┐
│                   UIViewController                      │
│                    (View Layer)                         │
│                                                         │
│  - Displays data from ViewModel.output                  │
│  - Sends user interactions to ViewModel.input           │
│  - Observes @Published properties via Combine           │
└─────────────────────────────────────────────────────────┘
                           ↕
                      (Combine)
                           ↕
┌─────────────────────────────────────────────────────────┐
│                       ViewModel                         │
│  (Business Logic & State Management)                    │
│                                                         │
│  - Input: PassthroughSubject channels for user events   │
│  - Output: @Published properties for view binding       │
│  - Processes business logic and data transformation     │
└─────────────────────────────────────────────────────────┘
                           ↕
                (Combine / Completion Block)
                           ↕
┌─────────────────────────────────────────────────────────┐
│                    Model Layer                          │
│  (API, Store, State Management)                         │
│                                                         │
│  - API: Network requests via URLSession                 │
│  - Store: Local data persistence using CoreData         │
│  - State: Manages application state (user, theme, etc)  │
└─────────────────────────────────────────────────────────┘
```

### **Data Layer**
- **API**: Network requests with async/await patterns via URLSession
- **Store**: CoreData-based persistence with type-safe requests
- **Environment**: Dependency injection container providing API, Store, and State
- **State**: Application-wide state management (user authentication, theme selection)

### **Coordinator Pattern**
The app uses the Coordinator pattern for navigation:
- **Coordinator**: Base protocol defining navigation responsibilities
- **TabCoordinator**: Manages tab bar navigation between major sections
- **ItemsListCoordinator**: Handles navigation within the items list flow
- **ItemSearchCoordinator**: Manages the search feature navigation

Coordinators decouple view controllers from navigation logic, making the app more modular and testable.

---

## Third Party Dependencies

- **SDWebImage** (^5.0+) - Asynchronous image downloading and caching for recipe and user profile images
- **Lottie** (^4.0+) - Vector-based animations from JSON files for loading states and UI feedback
- **SnapshotTesting** (^1.0+) - Snapshot testing for UI validation (test target only)

---

## Getting Started

### Requirements
- iOS 13.0+
- Swift 5.5+
- Xcode 14.0+

### Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:danielsinclairtill/Sampler.git
   cd Sampler/UIKit-MVVM-Combine
   ```

2. Open the project:
   ```bash
   open Sampler.xcodeproj
   ```

3. Build and Run:
   - Select the "Sampler" scheme
   - Build with ⌘B or run with ⌘R

### Testing

Run the test suite:
   - Select the "Sampler" scheme
   - Test with ⌘U
---
