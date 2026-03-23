//
//  AlertFactory.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    var title: String
    var dismissButtonTitle: String
    var onDismiss: (() -> Void)? = nil

    @State private var isPresented: Bool = false

    func body(content: Content) -> some View {
        content
            .onChange(of: errorMessage) { _, newValue in
                isPresented = newValue != nil
            }
            .alert(String(localized: LocalizedStringResource(stringLiteral: title)),
                   isPresented: $isPresented) {
                Button(dismissButtonTitle) {
                    isPresented = false
                    onDismiss?()
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

extension View {
    func errorAlert(
        _ errorMessage: String?,
        title: String = "com.danielsinclairtill.Sampler.error.title",
        dismissButtonTitle: String = "OK",
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(
            ErrorAlertModifier(
                errorMessage: errorMessage,
                title: title,
                dismissButtonTitle: dismissButtonTitle,
                onDismiss: onDismiss
            )
        )
    }
}

struct APIErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    var onRefresh: (() -> Void)? = nil

    @State private var isPresented: Bool = false

    func body(content: Content) -> some View {
        content
            .onChange(of: errorMessage) { _, newValue in
                isPresented = newValue != nil
            }
            .alert("Error", isPresented: $isPresented) {
                if let onRefresh {
                    Button("Refresh") {
                        isPresented = false
                        onRefresh()
                    }
                }
                Button("OK") {
                    isPresented = false
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

extension View {
    func apiErrorAlert(
        _ errorMessage: String?,
        onRefresh: (() -> Void)? = nil
    ) -> some View {
        modifier(
            APIErrorAlertModifier(
                errorMessage: errorMessage,
                onRefresh: onRefresh
            )
        )
    }
}
