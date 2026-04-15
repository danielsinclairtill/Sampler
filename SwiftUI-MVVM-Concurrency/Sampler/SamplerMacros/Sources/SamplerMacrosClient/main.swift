import SamplerMacros


protocol SamplerViewModelContract {
    associatedtype Output

    var output: Output { get set }
}

// MARK: Input + Output
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

// MARK: ViewModel
class ItemDetailViewModel: ItemDetailViewModelBinding.Contract {
    var output: Output
    
    public required init(output: Output = .init()) {
        self.output = output
    }
    
    // MARK: Input
    
    func viewDidLoad() async {
        print("stuff")
    }
    
    func tappedPostButton() async {
        print("stuff")

    }
    
    func tappedSaveButton() async {
        print("stuff")
    }
    
    func tappedLikeButton() {
        print("stuff")
    }
}
