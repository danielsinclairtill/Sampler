//
//  AlertFactory.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import SwiftUI
import Combine

/// A view modifier that displays an error alert when an error message is present
struct ErrorAlertModifier: ViewModifier {
    @Binding var errorMessage: String?
    var title: String
    var dismissButtonTitle: String
    var onDismiss: (() -> Void)? = nil
    
    var isPresented: Binding<Bool> {
        Binding(
            get: {
                guard let errorMessage else { return false }
                return !errorMessage.isEmpty
            },
            set: { if !$0 { errorMessage = nil } }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .alert(String(localized: LocalizedStringResource(stringLiteral: title)),
                   isPresented: isPresented) {
                Button(dismissButtonTitle) {
                    errorMessage = nil
                    onDismiss?()
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

/// Helper function to show an error alert
extension View {
    /// Displays an error alert when errorMessage is not empty
    /// - Parameters:
    ///   - errorMessage: Binding to error message string
    ///   - title: Alert title (default: "Error")
    ///   - dismissButtonTitle: Dismiss button text (default: "OK")
    ///   - onDismiss: Optional callback when alert is dismissed
    func errorAlert(
        _ errorMessage: Binding<String?>,
        title: String = "com.danielsinclairtill.Sampler.errir.title",
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

/// Helper function for API errors with refresh option
struct APIErrorAlertModifier: ViewModifier {
    @Binding var errorMessage: String?
    var onRefresh: (() -> Void)? = nil
    
    var isPresented: Binding<Bool> {
        Binding(
            get: {
                guard let errorMessage else { return false }
                return !errorMessage.isEmpty
            },
            set: { if !$0 { errorMessage = nil } }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: isPresented) {
                if let onRefresh = onRefresh {
                    Button("Refresh") {
                        onRefresh()
                    }
                }
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

extension View {
    /// Displays an error alert with optional refresh button for API errors
    /// - Parameters:
    ///   - errorMessage: Binding to error message string
    ///   - onRefresh: Optional callback for refresh button action
    func apiErrorAlert(
        _ errorMessage: Binding<String?>,
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
