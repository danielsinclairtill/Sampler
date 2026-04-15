import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SamplerMacrosImpl)
import SamplerMacrosImpl
#endif

final class MockableMacrosTests: XCTestCase {
    func testGeneratesMock() {
        assertMacroExpansion(
            """
            @Mockable
            enum ItemDetailViewModelBinding {
                protocol Contract: ItemDetailViewModelBinding.Input where Output == ItemDetailViewModelBinding.Output { }
                
                protocol Input: SamplerViewModelContract {
                    /// The view did load.
                    func viewDidLoad() async
                    /// The post button was tapped.
                    func tappedPostButton() async
                    /// The save button was tapped.
                    func tappedSaveButton() async
                    /// The like button was tapped.
                    func tappedLikeButton()
                }
                
                class Output {
                    /// Show an error message to display over the item details.
                    var error: String?
                    /// If the item is saved on disk or not.
                    var isSaved: Bool = false
                    /// If the item is currently being saved or not.
                    var isSaving: Bool = false
                    /// If the item is liked.
                    var isLiked: Bool = false

                    
                    init(error: String? = nil,
                         isSaved: Bool = false,
                         isSaving: Bool = false,
                         isLiked: Bool = false) {
                        self.error = error
                        self.isSaved = isSaved
                        self.isSaving = isSaving
                        self.isLiked = isLiked
                    }
                }
            }
            """,
            expandedSource: """
            enum ItemDetailViewModelBinding {
                protocol Contract: ItemDetailViewModelBinding.Input where Output == ItemDetailViewModelBinding.Output { }
                
                protocol Input: SamplerViewModelContract {
                    /// The view did load.
                    func viewDidLoad() async
                    /// The post button was tapped.
                    func tappedPostButton() async
                    /// The save button was tapped.
                    func tappedSaveButton() async
                    /// The like button was tapped.
                    func tappedLikeButton()
                }
                
                class Output {
                    /// Show an error message to display over the item details.
                    var error: String?
                    /// If the item is saved on disk or not.
                    var isSaved: Bool = false
                    /// If the item is currently being saved or not.
                    var isSaving: Bool = false
                    /// If the item is liked.
                    var isLiked: Bool = false

                    
                    init(error: String? = nil,
                         isSaved: Bool = false,
                         isSaving: Bool = false,
                         isLiked: Bool = false) {
                        self.error = error
                        self.isSaved = isSaved
                        self.isSaving = isSaving
                        self.isLiked = isLiked
                    }
                }
            }
            
            #if DEBUG
            class ItemDetailViewModelBindingMock: ItemDetailViewModelBinding.Contract {
                var output: ItemDetailViewModelBinding.Output

                public required init(output: ItemDetailViewModelBinding.Output = .init()) {
                    self.output = output
                }

                // MARK: Input

                func viewDidLoad() async {
                }

                func tappedPostButton() async {
                }

                func tappedSaveButton() async {
                }

                func tappedLikeButton() {
                }
            }
            #endif
            """,
            macros: ["Mockable": MockableMacro.self]
        )
    }
}
