//
//  LoginView.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var errorMessage = ""

    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(SamplerDesign.shared.theme.attributes.colors.primary()),
                    Color(SamplerDesign.shared.theme.attributes.colors.primary()).opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                // Title
                Text("Sampler")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(SamplerDesign.shared.theme.attributes.colors.primaryFill()))
                    .padding(.bottom, 48)
                
                // Username TextField
                TextField(String(localized: "com.danielsinclairtill.Sampler.login.usernameField.placeholder"),
                          text: $viewModel.input.username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 24)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                // Password TextField
                SecureField(String(localized: "com.danielsinclairtill.Sampler.login.passwordField.placeholder"),
                            text: $viewModel.input.password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 48)
                
                // Login Button
                Button(action: {
                    viewModel.input.loginTapped.send(())
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(SamplerDesign.shared.theme.attributes.colors.primaryFill()))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .disabled(!viewModel.output.loginButtonEnabled)
                .opacity(viewModel.output.loginButtonEnabled ? 1.0 : 0.5)
                
                // Skip Button
                Button(action: {
                    viewModel.input.skipLoginTapped.send(())
                }) {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(SamplerDesign.shared.theme.attributes.colors.primary()).opacity(0.3))
                        .foregroundColor(Color(SamplerDesign.shared.theme.attributes.colors.primaryFill()))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.vertical, 24)
        }
        .errorAlert($viewModel.output.error, title: "Login Failed")
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(environment: SamplerEnvironment.shared))
}
