//
//  LoginView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State var viewModel: any LoginViewModelBinding.Contract
    
    init(viewModel: any LoginViewModelBinding.Contract) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Spacer()
                
                // Title
                Text("com.danielsinclairtill.Sampler.login.title")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(SamplerDesign.shared.theme.attributes.colors.primaryFill()))
                    .padding(.bottom, 48)
                
                // Username TextField
                TextField(String(localized: "com.danielsinclairtill.Sampler.login.usernameField.placeholder"),
                          text: $viewModel.output.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 24)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                // Password TextField
                SecureField(String(localized: "com.danielsinclairtill.Sampler.login.passwordField.placholder"),
                            text: $viewModel.output.password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 48)
                
                // Login Button
                Button(action: {
                    viewModel.loginTapped()
                }) {
                    Text("com.danielsinclairtill.Sampler.login.loginButton.title")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .disabled(!viewModel.output.loginButtonEnabled)
                .buttonStyle(.borderedProminent)
                
                // Skip Button
                Button(action: {
                    viewModel.skipLoginTapped()
                }) {
                    Text("com.danielsinclairtill.Sampler.login.skipLoginButton.title")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(Color(SamplerDesign.shared.theme.attributes.colors.primaryFill()))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.vertical, 24)
        }
        .errorAlert(viewModel.output.error)
    }
}

#if DEBUG
struct LoginViewPreview: View {
    let output: LoginViewModelBinding.Output
    
    var body: some View {
        LoginView(viewModel: LoginViewModelBindingMock(output: output))
    }
}

#Preview("Blank") {
    LoginViewPreview(
        output: .init(loginbuttonEnabled: false)
    )
}

#Preview("Filled") {
    LoginViewPreview(
        output: .init(username: "username",
                      password: "password",
                      loginbuttonEnabled: true)
    )
}
#endif
