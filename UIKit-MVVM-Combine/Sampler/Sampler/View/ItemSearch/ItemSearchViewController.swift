//
//  ItemSearchViewController.swift
//  Sampler
//
//  Created by Daniel on 2026-01-09.
//

import UIKit
import Combine
import Lottie

class ItemSearchViewController: UIViewController,
                                UICollectionViewDelegate,
                                UIScrollViewDelegate {
    private let itemCellIdentifier = "ItemListCell"
    private let itemLoadingCellIdentifier = "ItemListLoadCell"
    private let viewModel: any ItemSearchViewModelBinding.Contract
    
    private enum Sizes {
        static let animation = 100.0
        static let empty = 25.0
    }
    
    private enum Section: Hashable {
        case main
    }
    private enum Row: Hashable {
        case item(Item)
        case loading
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    private var dataSource: DataSource?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
                let isLargeWidth = UITraitCollection.current.horizontalSizeClass == .regular
            
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(isLargeWidth ? 0.5 : 1.0),
                    heightDimension: .estimated(150)   // your estimate
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(isLargeWidth ? 0.5 : 1.0),
                    heightDimension: .estimated(150)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.alpha = 0.0
        collectionView.register(ItemListCell.self,
                                forCellWithReuseIdentifier: itemCellIdentifier)
        collectionView.register(ItemListLoadingCell.self,
                                forCellWithReuseIdentifier: itemLoadingCellIdentifier)
        return collectionView
    }()

    private lazy var loadingAnimationView: LottieAnimationView = {
        let loadingAnimationView = LottieAnimationView(name: "loading_animation")
        loadingAnimationView.isHidden = true
        loadingAnimationView.backgroundBehavior = .pauseAndRestore
        return loadingAnimationView
    }()
    
    private lazy var emptyView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "empty"))
        image.isUserInteractionEnabled = false
        image.alpha = 1.0
        return image
    }()
    private var observation: NSKeyValueObservation?
    private var cancelBag = Set<AnyCancellable>()

    init(viewModel: any ItemSearchViewModelBinding.Contract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "com.danielsinclairtill.Sampler.itemSearch.title".localized()
        
        // search controller
        navigationItem.searchController = searchController
        
        // empty view
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.widthAnchor.constraint(equalToConstant: Sizes.empty),
            emptyView.heightAnchor.constraint(equalToConstant: Sizes.empty)
        ])

        // loading animation view
        view.addSubview(loadingAnimationView)
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimationView.widthAnchor.constraint(equalToConstant: Sizes.animation),
            loadingAnimationView.heightAnchor.constraint(equalToConstant: Sizes.animation)
        ])
        
        // collection view
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        bindViewModel()
        setupDesign()
    }
    
    @objc
    private func didPullRefresh(_ sender: AnyObject) {
        viewModel.input.refreshBegin.send(())
    }
    
    private func presentError(message: String) {
        let alert = AlertFactory.createAPIError(message: message,
                                                refreshHandler: { [weak self] _ in
            self?.viewModel.input.refreshBegin.send(())
        })
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Binding
    private func bindViewModel() {
        // loading list animation
        viewModel.output.$isRefreshing
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isRefreshing in
                if isRefreshing {
                    self?.initiateLoadingList()
                } else {
                    self?.finishLoadingList()
                }
            })
            .store(in: &cancelBag)
        
        // stories collection
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView,
                                                                      cellProvider: { [weak self] collectionView, indexPath, row in
            guard let strongSelf = self else { return UICollectionViewCell() }
            switch row {
            case .item(let item):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: strongSelf.itemCellIdentifier,
                                                                    for: indexPath) as? ItemListCell else {
                    assertionFailure("could not dequeue cell")
                    return UICollectionViewCell()
                }
                cell.setUpWith(item: item,
                               imageManager: strongSelf.viewModel.imageManager)
                
                return cell
            case .loading:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: strongSelf.itemLoadingCellIdentifier,
                                                                    for: indexPath) as? ItemListLoadingCell else {
                    assertionFailure("could not dequeue cell")
                    return UICollectionViewCell()
                }
                return cell
            }

        })
        collectionView.dataSource = dataSource
        viewModel.output.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let strongSelf = self else { return }
                
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(items.map { .item($0)}, toSection: .main)
                if let totalItems = self?.viewModel.output.total,
                   items.count > 0,
                   totalItems > 0,
                   items.count < totalItems  {
                    snapshot.appendItems([.loading], toSection: .main)
                }
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
                
                if items.isEmpty && strongSelf.emptyView.alpha == 0 {
                    AnimationController.fadeInView(strongSelf.emptyView)
                }
            }
            .store(in: &cancelBag)
        
        // scrolling
        observation = collectionView.observe(\.contentOffset, options: .new) { [weak self] collectionView, change in
            guard let strongSelf = self else { return }
            
            // is at top of the list
            strongSelf.viewModel.input.isTopOfPage = strongSelf.collectionView.contentOffset == .zero
        }
        viewModel.output.scrollToTop
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.viewModel.input.isScrolling = true
                self?.collectionView.setContentOffset(.zero, animated: true)
            })
            .store(in: &cancelBag)

        // error messagCe
        viewModel.output.$error
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.presentError(message: message)
            })
            .store(in: &cancelBag)
    }
    
    private func setupDesign() {
        emptyView.tintColor = SamplerDesign.shared.theme.attributes.colors.primaryFill()
        view.backgroundColor = SamplerDesign.shared.theme.attributes.colors.primary()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // change the layout for collection view on iPad rotations
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.cellTapped.send(indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let row = dataSource?.itemIdentifier(for: indexPath) else { return }
        if case .loading = row {
            viewModel.input.loadNextPage.send(())
        }
    }
        
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        viewModel.input.isScrolling = false
    }
    
    // MARK: List Loading Animations
    private func initiateLoadingList() {
        collectionView.isScrollEnabled = false
        loadingAnimationView.isHidden = false
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.play()
        AnimationController.fadeOutView(collectionView) { [weak self] completed in
            self?.viewModel.input.refresh.send(())
        }
        AnimationController.fadeOutView(emptyView)
        AnimationController.fadeInView(loadingAnimationView)
    }
    
    private func finishLoadingList() {
        AnimationController.fadeOutView(loadingAnimationView) { [weak self] completed in
            if completed {
                self?.loadingAnimationView.stop()
                self?.loadingAnimationView.isHidden = true
            }
        }
        AnimationController.fadeInView(collectionView) { [weak self] completed in
            self?.collectionView.isScrollEnabled = true
        }
    }
}

extension ItemSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.input.searchText = searchController.searchBar.text ?? ""
    }
}
