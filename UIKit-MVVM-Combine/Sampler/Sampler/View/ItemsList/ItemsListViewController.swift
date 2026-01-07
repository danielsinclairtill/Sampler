//
//  SamplerListViewController.swift
//  Sampler
//
//
//

import UIKit
import Lottie
import Combine

class SamplerListViewController: UIViewController,
                                  UICollectionViewDelegateFlowLayout,
                                  UICollectionViewDelegate,
                                  UIScrollViewDelegate {
    private let cellIdentifier = "SamplerListViewControllerCell"
    private let viewModel: any SamplerListViewModelContract
    
    private enum SectionKind: Int, CaseIterable, Hashable {
        case main
    }
    private typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionKind, Item>
    private var dataSource: DataSource?
    
    private enum Sizes {
        static let animation = 100.0
        static let empty = 25.0
    }
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .clear
        collectionView.alpha = 0.0
        collectionView.register(SamplerListCell.self,
                                forCellWithReuseIdentifier: cellIdentifier)
        return collectionView
    }()

    private lazy var loadingAnimationView: LottieAnimationView = {
        let loadingAnimationView = LottieAnimationView(name: "loading_animation")
        loadingAnimationView.isHidden = false
        loadingAnimationView.backgroundBehavior = .pauseAndRestore
        return loadingAnimationView
    }()
    
    private lazy var emptyView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "empty"))
        image.isUserInteractionEnabled = false
        image.alpha = 0.0
        return image
    }()
    private let refreshControl = UIRefreshControl()
    private var observation: NSKeyValueObservation?
    private var cancelBag = Set<AnyCancellable>()

    init(viewModel: any SamplerListViewModelContract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "com.danielsinclairtill.Sampler.itemsList.title".localized()
        
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

        viewModel.input.viewDidLoad.send(())
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
        // refresh control
        refreshControl.addTarget(self, action: #selector(self.didPullRefresh(_:)), for: .valueChanged)
        viewModel.output.$isLoading
            .filter { !$0 }
            .sink(receiveValue: { [weak self] isLoading in
                self?.collectionView.refreshControl?.endRefreshing()
            })
            .store(in: &cancelBag)
        
        // loading list animation
        viewModel.output.$isLoading
            .dropFirst()
            .removeDuplicates()
            // make sure animating between loading states is buffered by at least 0.8 seconds
            .throttle(for: 0.8,
                      scheduler: DispatchQueue.main,
                      latest: false)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.initiateLoadingList()
                } else {
                    self?.finishLoadingList()
                }
            })
            .store(in: &cancelBag)
        
        // stories collection
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { [weak self] collectionView, indexPath, item in
            guard let strongSelf = self else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: strongSelf.cellIdentifier,
                                                                for: indexPath) as? SamplerListCell else {
                assertionFailure("could not dequeue cell")
                return UICollectionViewCell()
            }
            
            cell.setUpWith(item: item,
                           imageManager: strongSelf.viewModel.imageManager)
            
            return cell
        })
        collectionView.dataSource = dataSource
        viewModel.output.$items
            .sink { [weak self] items in
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(items)
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancelBag)
        
        // scrolling
        observation = collectionView.observe(\.contentOffset, options: .new) { [weak self] collectionView, change in
            guard let strongSelf = self else { return }
            
            // is at top of the list
            strongSelf.viewModel.input.isTopOfPage = strongSelf.collectionView.contentOffset == .zero
        }
        viewModel.output.scrollToTop
            .sink(receiveValue: { [weak self] in
                self?.viewModel.input.isScrolling = true
                self?.collectionView.setContentOffset(.zero, animated: true)
            })
            .store(in: &cancelBag)

        // error message
        viewModel.output.$error
            .filter { !$0.isEmpty }
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
    private func getCellSize() -> CGSize {
        // large width class devices (ex. iPad) should show two columns in the collection view
        let isLargeWidth = UITraitCollection.current.horizontalSizeClass == .regular
        let width = isLargeWidth ? collectionView.bounds.width / 2 : collectionView.bounds.width
        let height = SamplerListCell.cellHeight
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.cellTapped.send(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
        AnimationController.fadeInView(loadingAnimationView, completion: nil)
    }
    
    private func finishLoadingList() {
        AnimationController.fadeOutView(loadingAnimationView,
                                        completion: { [weak self] completed in
            if completed {
                self?.loadingAnimationView.stop()
                self?.loadingAnimationView.isHidden = true
            }
        })
        AnimationController.fadeInView(collectionView) { [weak self] completed in
            self?.collectionView.isScrollEnabled = true
        }
        if viewModel.output.items.isEmpty {
            AnimationController.fadeInView(emptyView)
        }
    }
}
