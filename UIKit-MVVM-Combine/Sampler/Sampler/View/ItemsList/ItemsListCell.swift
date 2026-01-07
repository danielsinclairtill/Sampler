//
//  SamplerListCell.swift
//  Sampler
//
//
//

import Foundation
import UIKit
import Combine

class SamplerListCell: UICollectionViewCell {
    static let cellHeight: CGFloat = 180
    private let animationController = AnimationController()
    private var cancelBag = Set<AnyCancellable>()
    
    private lazy var horizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .top
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        return stackView
    }()
    
    private lazy var detailStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = 8.0
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var userStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        return stackView
    }()
    
    private lazy var avatarView: AsyncImageView = {
        return AvatarView(placeholderImage: UIImage(named: "UnkownUser"),
                          size: SamplerDesign.shared.theme.attributes.dimensions.avatarSizeSmall())
    }()
    
    private lazy var username: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var photoView: AsyncImageView = {
        return AsyncImageView(placeholderImage: nil)
    }()
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var descriptionText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildViews() {
        // base container stack
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
        ])
        
        // photo
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 100),
            photoView.heightAnchor.constraint(equalToConstant: 150),
        ])
        
        horizontalStack.addArrangedSubview(photoView)
        
        // detail stack
        horizontalStack.addArrangedSubview(detailStack)
        
        // name
        detailStack.addArrangedSubview(name)
        
        // user
        detailStack.addArrangedSubview(userStack)
        
        // avatar
        userStack.addArrangedSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: SamplerDesign.shared.theme.attributes.dimensions.avatarSizeSmall()),
            avatarView.heightAnchor.constraint(equalToConstant: SamplerDesign.shared.theme.attributes.dimensions.avatarSizeSmall()),
        ])
        userStack.addArrangedSubview(username)
                
        // descriptionText
        descriptionText.setContentHuggingPriority(.defaultLow, for: .vertical)
        detailStack.addArrangedSubview(descriptionText)
    }
    
    private func setupDesign() {
        SamplerDesign.shared.$theme
            .sink { [weak self] theme in
                guard let strongSelf = self else { return }
                strongSelf.backgroundColor = theme.attributes.colors.primary()
                
                strongSelf.photoView.setCornerRadius(theme.attributes.dimensions.photoCornerRadius())
                
                strongSelf.name.font = theme.attributes.fonts.primaryTitle()
                strongSelf.name.textColor = theme.attributes.colors.primaryFill()
                strongSelf.username.font = theme.attributes.fonts.primaryTitle()
                strongSelf.username.textColor = theme.attributes.colors.primaryFill()
                strongSelf.descriptionText.font = theme.attributes.fonts.body()
                strongSelf.descriptionText.textColor = theme.attributes.colors.primaryFill()
            }
            .store(in: &cancelBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        name.text = ""
        username.text = ""
        descriptionText.text = ""
        photoView.clearImage()
        avatarView.clearImage()
        
        cancelBag = Set<AnyCancellable>()
    }
    
    func setUpWith(item: Item,
                   imageManager: ImageManagerContract) {
        name.text = item.title
        username.text = item.user?.name
        descriptionText.text = item.description
        
        if let photoUrl = item.cover {
            photoView.setImage(url: photoUrl,
                               imageManager: imageManager)
        }
        if let avatarUrl = item.user?.avatar {
            avatarView.setImage(url: avatarUrl,
                                imageManager: imageManager)
        }
        
        setupDesign()
    }
    
    // MARK:- Animations
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animationController.createTapBounceAnitmationOnTouchBeganTo(view: photoView)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animationController.createTapBounceAnitmationOnTouchEndedTo(view: photoView)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animationController.createTapBounceAnitmationOnTouchCancelledTo(view: photoView)
    }
}
