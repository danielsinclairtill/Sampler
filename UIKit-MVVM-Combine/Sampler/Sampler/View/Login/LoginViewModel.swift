//
//  LoginViewModel.swift
//  Sampler
//
//  Created by Daniel on 2026-01-10.
//

import Foundation
import Combine


// MARK: Input + Output
enum LoginViewModelBinding {
    protocol Contract: SamplerViewModelContract where Input == LoginViewModelBinding.Input,
                                                      Output == LoginViewModelBinding.Output { }
    
    class Input: ObservableObject {
        /// The inputted email.
        @Published var username: String = ""
        /// The inputted password.
        @Published var password: String = ""
        
        /// When the login button is tapped.
        var loginTapped = PassthroughSubject<Void, Never>()
    }

    class Output: ObservableObject {
        /// If the login button is enabled.
        @Published var loginButtonEnabled: Bool = false
        /// Show an error message to display over the item details.
        @Published var error: String = ""
        
        init(loginbuttonEnabled: Bool = false,
             error: String = "") {
            self.loginButtonEnabled = loginbuttonEnabled
            self.error = error
        }
    }
}

// MARK: ViewModel
class LoginViewModel: LoginViewModelBinding.Contract, ObservableObject {
    let input = LoginViewModelBinding.Input()
    let output = LoginViewModelBinding.Output()
    private var cancelBag = Set<AnyCancellable>()
    
    private let coordinator: any Coordinator
    private let environment: EnvironmentContract
    
    required init(environment: EnvironmentContract,
                  coordinator: Coordinator) {
        self.environment = environment
        self.coordinator = coordinator
        
        // bind inputs and outputs
        setLogin()
    }
    
    private func setLogin() {
        input.$username
            .combineLatest(input.$password)
            .sink { [weak self] username, password in
                self?.output.loginButtonEnabled = !username.isEmpty && !password.isEmpty
            }
            .store(in: &cancelBag)
        
        input.loginTapped
            .sink { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.environment.api.request(LoginRequest.Login(username: strongSelf.input.username,
                                                                      password: strongSelf.input.password)) { result in
                    switch result {
                    case .success(let response):
                        strongSelf.environment.state.user = response
                        strongSelf.coordinator.start()
                    case .failure(let error):
                        // the API returns a `.requestError` when login credentials are not found
                        if error == .requestError {
                            strongSelf.output.error = APIError.authentification.message
                        } else {
                            strongSelf.output.error = error.message
                        }
                    }
                }
            }
            .store(in: &cancelBag)
    }
}
