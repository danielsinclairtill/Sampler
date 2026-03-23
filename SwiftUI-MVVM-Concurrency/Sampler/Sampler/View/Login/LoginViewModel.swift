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
    protocol Contract: SamplerViewModelContract where Output == LoginViewModelBinding.Output {
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
        
        init(loginbuttonEnabled: Bool = false,
             error: String? = nil) {
            self.loginButtonEnabled = loginbuttonEnabled
            self.error = error
        }
    }
}

// MARK: ViewModel
class LoginViewModel: ObservableViewModel, LoginViewModelBinding.Contract {
    var output = LoginViewModelBinding.Output()
    private var cancelBag = Set<AnyCancellable>()

    private let environment: any EnvironmentContract
    
    init(environment: any EnvironmentContract,
         output: LoginViewModelBinding.Output = .init()) {
        self.output = output
        self.environment = environment
        
        super.init()
        // bind inputs and outputs
        listenInput()
    }
    
    private func listenInput() {
        observe { [weak self] in
            _ = self?.output.username
            _ = self?.output.password
        } onChange: { [weak self] in
            guard let self else { return }
            self.output.loginButtonEnabled = !self.output.username.isEmpty && !self.output.password.isEmpty
        }
    }
    
    private func login(username: String, password: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let response = try await self.environment.api.request(LoginAPIRequest.Login(username: username,
                                                                                            password: password))
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
