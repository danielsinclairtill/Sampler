//
//  LoginViewModel.swift
//  Sampler
//
//  Created by Daniel on 2026-01-10.
//

import Foundation
import Combine
import SamplerMacros

// MARK: Input + Output
@Mockable
enum LoginViewModelBinding {
    protocol Contract: SamplerViewModelContract,
                        LoginViewModelBinding.Input where Output == LoginViewModelBinding.Output  { }
    
    protocol Input {
        /// When the login button is tapped.
        func loginTapped()
        /// When the skip login button is tapped.
        func skipLoginTapped()
    }

    @Observable
    class Output {
        /// The inputted email.
        var username: String = ""
        /// The inputted password.
        var password: String = ""
        /// If the login button is enabled.
        var loginButtonEnabled: Bool = false
        /// Show an error message to display over the item details.
        var error: String?
        
        init(username: String = "",
             password: String = "",
             loginbuttonEnabled: Bool = false,
             error: String? = nil) {
            self.username = username
            self.password = password
            self.loginButtonEnabled = loginbuttonEnabled
            self.error = error
        }
    }
}

// MARK: ViewModel
class LoginViewModel: LoginViewModelBinding.Contract,
                      LoginViewModelBinding.Input {
    var output: Output
    typealias Environment = AuthRepositoryProvider &
                            StateProvider
    private let environment: Environment
    
    private var observeBag = ObserveBag()
    
    init(environment: Environment,
         output: LoginViewModelBinding.Output = .init()) {
        self.output = output
        self.environment = environment
        
        // bind inputs and outputs
        listenInput()
    }
    
    // MARK: Input
    
    private func listenInput() {
        observeBag.add { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.output.loginButtonEnabled = !strongSelf.output.username.isEmpty && !strongSelf.output.password.isEmpty
        }
    }
    
    private func login(username: String, password: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            output.error = nil
            do {
                let response = try await self.environment.authRepository.login(username: username,
                                                                               password: password)
                self.environment.state.user = response
            } catch let error as APIError {
                // the API returns a `.requestError` when login credentials are not found
                if error == .requestError {
                    self.output.error = APIError.authentification.message
                } else {
                    self.output.error = error.message
                }
            }
        }
    }
    
    func loginTapped() {
        login(username: output.username, password: output.password)
    }
    
    func skipLoginTapped() {
        // Just used for testing purposes to login without credentials.
        // It's fine these credentials are exposed since we are using a test API.
        login(username: "emilys", password: "emilyspass")
    }
}
