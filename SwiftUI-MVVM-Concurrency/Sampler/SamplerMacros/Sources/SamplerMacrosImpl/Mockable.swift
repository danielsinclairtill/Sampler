//
//  Mockable.swift
//  SamplerMacros
//
//  Created by Daniel on 2026-04-15.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct MockableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Must be attached to an enum
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MockMacroError.notAnEnum
        }

        let enumName = enumDecl.name.trimmed.text

        // ItemDetailViewModelBinding → ItemDetailViewModelMock
        guard enumName.hasSuffix("Binding") else {
            throw MockMacroError.namingConvention(enumName)
        }
        let baseName      = enumName
        let mockClassName = "\(baseName)Mock"
        let conformance   = "\(enumName).Contract"
        let outputType    = "\(enumName).Output"

        // Find the Input protocol inside the enum
        guard let inputProto = enumDecl.memberBlock.members
            .compactMap({ $0.decl.as(ProtocolDeclSyntax.self) })
            .first(where: { $0.name.text == "Input" })
        else {
            throw MockMacroError.noInputProtocol
        }

        // Build no-op stubs for every function in Input
        let stubs = inputProto.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .map { buildStub($0) }
            .joined(separator: "\n\n")

        return [
            """
            #if DEBUG
            class \(raw: mockClassName): \(raw: conformance) {
                var output: \(raw: outputType)

                public required init(output: \(raw: outputType) = .init()) {
                    self.output = output
                }

                // MARK: Input

            \(raw: stubs)
            }
            #endif
            """
        ]
    }

    private static func buildStub(_ fn: FunctionDeclSyntax) -> String {
        let name     = fn.name.text
        let isAsync  = fn.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrows = fn.signature.effectSpecifiers?.throwsClause != nil

        let params = fn.signature.parameterClause.parameters.map { p -> String in
            let label = p.firstName.text
            let argName = p.secondName?.text
            let type  = p.type.trimmedDescription
            switch (label, argName) {
            case ("_", let n?): return "_ \(n): \(type)"
            case (let l, let n?): return "\(l) \(n): \(type)"
            default: return "\(label): \(type)"
            }
        }.joined(separator: ", ")

        let asyncKw      = isAsync  ? " async"  : ""
        let throwsKw     = isThrows ? " throws" : ""
        let returnClause = fn.signature.returnClause
            .map { " -> \($0.type.trimmedDescription)" } ?? ""

        return "    func \(name)(\(params))\(asyncKw)\(throwsKw)\(returnClause) { }"
    }
}

enum MockMacroError: Error, CustomStringConvertible {
    case notAnEnum
    case namingConvention(String)
    case noInputProtocol

    var description: String {
        switch self {
        case .notAnEnum:
            return "@Mockable must be applied to an enum"
        case .namingConvention(let name):
            return "@Mockable enum must end in 'Binding' (got '\(name)')"
        case .noInputProtocol:
            return "@Mockable enum must contain a nested 'Input' protocol"
        }
    }
}

@main
struct MockMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [MockableMacro.self]
}
