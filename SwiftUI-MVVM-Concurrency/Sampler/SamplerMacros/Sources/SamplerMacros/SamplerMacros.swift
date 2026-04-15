// The Swift Programming Language
// https://docs.swift.org/swift-book

/// Attach to any protocol to generate a `Mock{ProtocolName}` class
/// that implements all functions as no-ops. Primarily used for view model classes.
///
/// Usage:
///
///     @Mockable
///     enum ItemDetailViewModelBinding {
///         protocol Contract: ItemDetailViewModelBinding.Input where Output == ItemDetailViewModelBinding.Output { }
///         ...
/// Generates:
///
///     class MockItemDetailViewModel: ItemDetailViewModelBinding.Contract {
///         func viewDidLoad() async { }
///         func tappedButton() { }
///         ...
///     }
@attached(peer, names: suffixed(Mock))
public macro Mockable() = #externalMacro(
    module: "SamplerMacrosImpl",
    type: "MockableMacro"
)
