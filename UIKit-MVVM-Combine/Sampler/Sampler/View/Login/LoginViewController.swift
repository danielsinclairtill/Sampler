//
//  LoginViewController.swift
//  Sampler
//
//  Created by Daniel on 2026-01-10.
//

import UIKit
import Combine

class LoginViewController: UIViewController,
                           UITextFieldDelegate {
    private let viewModel: any LoginViewModelBinding.Contract
    private var cancelBag = Set<AnyCancellable>()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sampler"
        label.textAlignment = .center
        label.font = SamplerDesign.shared.theme.attributes.fonts.primaryTitleLarge()
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, usernameField, passwordField, loginButton, skipButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(64, after: titleLabel)
        stackView.setCustomSpacing(64, after: passwordField)
        return stackView
    }()
    
    private lazy var usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "com.danielsinclairtill.Sampler.login.usernameField.placeholder".localized()
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        return textField
    }()
    
    private lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "com.danielsinclairtill.Sampler.login.passwordField.placholder".localized()
        textField.isSecureTextEntry = true
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("com.danielsinclairtill.Sampler.login.loginButton.title".localized(), for: .normal)
        button.configuration = .bordered()
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("com.danielsinclairtill.Sampler.login.skipLoginButton.title".localized(), for: .normal)
        button.configuration = .bordered()
        button.addTarget(self, action: #selector(didTapSkipLoginButton), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: any LoginViewModelBinding.Contract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SamplerDesign.shared.theme.attributes.colors.primary()
        
        layoutView()
        bindViewModel()
    }
    
    private func layoutView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    @objc
    private func didTapLoginButton() {
        viewModel.input.loginTapped.send(())
    }
    
    @objc
    private func didTapSkipLoginButton() {
        viewModel.input.skipLoginTapped.send(())
    }
    
    private func bindViewModel() {
        viewModel.output.$loginButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancelBag)
        
        // error message
        viewModel.output.$error
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.presentError(message: message)
            })
            .store(in: &cancelBag)
    }
    
    private func presentError(message: String) {
        let alert = AlertFactory.createError(message: message)
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == usernameField {
            viewModel.input.username = usernameField.text ?? ""
        } else if textField == passwordField {
            viewModel.input.password = passwordField.text ?? ""
        }
    }
}
