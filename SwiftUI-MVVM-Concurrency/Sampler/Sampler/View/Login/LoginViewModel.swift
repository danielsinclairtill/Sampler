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
        
        /// When the skip login button is tapped.
        var skipLoginTapped = PassthroughSubject<Void, Never>()
    }

    class Output: ObservableObject {
        /// If the login button is enabled.
        @Published var loginButtonEnabled: Bool = false
        /// Show an error message to display over the item details.
        @Published var error: String?
        
        init(loginbuttonEnabled: Bool = false,
             error: String? = nil) {
            self.loginButtonEnabled = loginbuttonEnabled
            self.error = error
        }
    }
}

// MARK: ViewModel
class LoginViewModel: LoginViewModelBinding.Contract {
    @PublishedObject var input = LoginViewModelBinding.Input()
    @PublishedObject var output = LoginViewModelBinding.Output()
    private var cancelBag = Set<AnyCancellable>()
    
    private let environment: any EnvironmentContract
    
    init(environment: any EnvironmentContract) {
        self.environment = environment
        
        // bind inputs and outputs
        setLogin()
    }
    
    private func login(username: String, password: String) {
        environment.api.request(LoginAPIRequest.Login(username: username,
                                                      password: password)) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let response):
                strongSelf.environment.state.user = response
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
                strongSelf.login(username: strongSelf.input.username, password: strongSelf.input.password)
            }
            .store(in: &cancelBag)
        
        input.skipLoginTapped
            .sink { [weak self] _ in
                // Just used for testing purposes to login without credentials.
                // It's fine these credentials are exposed since we are using a test API.
                self?.login(username: "emilys", password: "emilyspass")
            }
            .store(in: &cancelBag)
    }
}
