//
//  ItemDetailViewController.swift
//  Sampler
//
//  Created by Daniel Till on 2023-08-22.
//

import Foundation
import UIKit
import Combine

class ItemDetailViewController: UIViewController {
    private let viewModel: any ItemDetailViewModelBinding.Contract
    private var cancelBag = Set<AnyCancellable>()

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16.0
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var itemCover = AsyncImageView(placeholderImage: nil,
                                                 cornerRadius: SamplerDesign.shared.theme.attributes.dimensions.photoCornerRadius())
    
    private lazy var itemTitle: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var avatarView: AvatarView = {
        let avatar = AvatarView(placeholderImage: UIImage(named: "UnkownUser"),
                                size: SamplerDesign.shared.theme.attributes.dimensions.avatarSizeSmall())
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        return avatar
    }()
    
    private lazy var descrptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8.0
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var authorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    
    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var authorTitle: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var descriptionTitle: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())
        button.configuration?.title = "com.danielsinclairtill.Sampler.itemDetail.postButton.title".localized()
        button.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())
        button.configuration?.title = "com.danielsinclairtill.Sampler.itemDetail.saveButton.title.save".localized()
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        
        return button
    }()
    
    init(viewModel: any ItemDetailViewModelBinding.Contract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupDesign()
        bindViewModel()
   
        // load item detail
        viewModel.input.viewDidLoad.send(())
    }
    
    private func setupConstraints() {
        // layout subviews
        // rootStackView
        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
            rootStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            rootStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)
        ])
        
        // item cover and title
        rootStackView.addArrangedSubview(itemCover)
        NSLayoutConstraint.activate([
            itemCover.widthAnchor.constraint(equalTo: itemCover.heightAnchor, multiplier: 0.64),
            itemCover.widthAnchor.constraint(equalToConstant: 150)
        ])
        rootStackView.addArrangedSubview(itemTitle)
        
        // description section
        rootStackView.addArrangedSubview(descrptionStackView)
        NSLayoutConstraint.activate([
            descrptionStackView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor),
        ])
        // author
        authorStackView.addArrangedSubview(avatarView)
        authorStackView.addArrangedSubview(authorTitle)
        descrptionStackView.addArrangedSubview(authorStackView)

        // description
        // make the descriptionTitle be the first the compress if the vertical spacing cannot fit all elements
        descriptionTitle.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        descrptionStackView.addArrangedSubview(descriptionTitle)
        
        // action section
        rootStackView.addArrangedSubview(actionStackView)
        
        // buttons
        actionStackView.addArrangedSubview(postButton)
        actionStackView.addArrangedSubview(saveButton)
    }
    
    private func setupDesign() {
        SamplerDesign.shared.$theme
            .sink { [weak self] theme in
                guard let strongSelf = self else { return }
                strongSelf.view.backgroundColor = theme.attributes.colors.primary()
                strongSelf.itemTitle.font = theme.attributes.fonts.primaryTitleLarge()
                strongSelf.itemTitle.textColor = theme.attributes.colors.primaryFill()
                strongSelf.authorTitle.font = theme.attributes.fonts.primaryTitle()
                strongSelf.authorTitle.textColor = theme.attributes.colors.primaryFill()
                strongSelf.descriptionTitle.font = theme.attributes.fonts.body()
                strongSelf.descriptionTitle.textColor = theme.attributes.colors.primaryFill()
                
                strongSelf.postButton.configurationUpdateHandler = { button in
                    switch button.state {
                    case .highlighted:
                        button.configuration?.baseForegroundColor = theme.attributes.colors.primaryFill().withAlphaComponent(0.8)
                        button.configuration?.background.backgroundColor = theme.attributes.colors.secondary().withAlphaComponent(0.8)
                    default:
                        button.configuration?.baseForegroundColor = theme.attributes.colors.primaryFill()
                        button.configuration?.background.backgroundColor = theme.attributes.colors.secondary()
                    }
                }
                strongSelf.saveButton.configurationUpdateHandler = { button in
                    switch button.state {
                    case .highlighted:
                        button.configuration?.baseForegroundColor = .white.withAlphaComponent(0.8)
                        button.configuration?.background.backgroundColor = .systemGreen.withAlphaComponent(0.8)
                    default:
                        button.configuration?.baseForegroundColor = .white
                        button.configuration?.background.backgroundColor = .systemGreen
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
    private func bindViewModel() {
        viewModel.output.$item
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.setItem(item: item)
            }
            .store(in: &cancelBag)

        viewModel.output.$error
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] message in
                self?.presentError(message: message)
            }
            .store(in: &cancelBag)
        
        viewModel.output.$isSaved
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSaved in
                self?.setIsSaved(isSaved)
            }
            .store(in: &cancelBag)
    }
    
    private func setItem(item: Item?) {
        if let url = item?.image {
            itemCover.setImage(url: url, imageManager: viewModel.imageManager)
        }

        itemTitle.text = item?.name ?? "..."
        descriptionTitle.text = item?.ingredients?.joined(separator: ", ") ?? "..."
        
        setUser(user: item?.user)
    }
    
    private func setUser(user: User?) {
        if let url = user?.image {
            avatarView.setImage(url: url,
                                placeholder: .unkownUser,
                                imageManager: viewModel.imageManager)
        }
        authorTitle.text = user?.username ?? "..."
    }
    
    private func setIsSaved(_ isSaved: Bool) {
        saveButton.configuration?.title = isSaved ?
        "com.danielsinclairtill.Sampler.itemDetail.saveButton.title.saved".localized() :
        "com.danielsinclairtill.Sampler.itemDetail.saveButton.title.save".localized()
        saveButton.configuration?.background.backgroundColorTransformer = UIConfigurationColorTransformer { color in
            isSaved ? color.withAlphaComponent(0.3) : color
        }
        saveButton.isEnabled = !isSaved
    }
    
    private func presentError(message: String) {
        let alert = AlertFactory.createAPIError(message: message, refreshHandler: nil)
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func didTapPostButton() {
        viewModel.input.tappedPostButton.send(())
    }
    
    @objc
    private func didTapSaveButton() {
        viewModel.input.tappedSaveButton.send(())
    }
}
