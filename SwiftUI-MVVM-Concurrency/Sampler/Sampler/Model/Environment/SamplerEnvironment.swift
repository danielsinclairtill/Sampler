//
//  SamplerEnvironment.swift
//  Sampler
//
//
//

import Foundation
import Combine

class SamplerEnvironment: ObservableObject, EnvironmentContract {
    static let shared: any EnvironmentContract = {
        if SamplerEnvironment.isTesting {
            SamplerTestEnvironment()
        } else {
            SamplerEnvironment()
        }
    }()
    
    let api: APIContract = SamplerAPI()
    let store: StoreContract = SamplerStore(container: SamplerStore.persistentContainer())
    @Published var state: any SamplerStateContract
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let stateManager = SamplerStateManager()
        self.state = stateManager
        
        // Forward changes from the nested StateManager to this environment
        stateManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
