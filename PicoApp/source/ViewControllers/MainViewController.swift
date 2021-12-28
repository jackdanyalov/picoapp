import UIKit

class MainViewController: BaseViewController {
    
    private let viewModel: MainViewModelProtocol
    private var collectionView: UICollectionView?
    private var searchController: UISearchController?
    private var refreshControl: UIRefreshControl?
    private var searchViewController: SearchViewController?
    private var isPageRefresh = false
    private var pageNumber = 1
    private var searchTerm = Constants.API.defaultSearchTerm {
        didSet {
            search()
        }
    }

    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        title = "PICO"
        configureSearchController()
        configureCollectionView()
        configureRefreshControl()
        fetch()
    }
    
    private func configureSearchController() {
        searchViewController = SearchViewController(viewModel: viewModel)
        searchViewController?.handleSearch = { [weak self] searchTerm in
            self?.searchTerm = searchTerm
        }
        searchController = UISearchController(searchResultsController: searchViewController)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        searchController?.searchBar.placeholder = "Let's find smth cool..."
        searchController?.obscuresBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
    }
    
    private func configureCollectionView() {
        let cellSize = CGSize(width: view.frame.size.width / 2, height: view.frame.size.width / 2)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let cv = collectionView else { return }
        cv.register(CollectionViewCell.self, forCellWithReuseIdentifier: Constants.Cell.collectionViewCellId)
        cv.dataSource = self
        cv.delegate = self
        cv.frame = view.bounds
        view.addSubview(cv)
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        collectionView?.alwaysBounceVertical = true
        refreshControl?.tintColor = .systemGray
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }

    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        fetch()
    }

    // Task waits until all data will be fetched and ready and updates UI main thread.
    private func fetch() {
        Task { [weak self] in
            let error = await viewModel.fetchRecentImages(searchTerm: searchTerm, page: pageNumber)
            
            // Not the best way to handle errors, but for the sake of simplicity
            // of the project I will do it in a trivial way
            if let error = error {
                showAlertView(with: error)
            } else {
                self?.refreshControl?.endRefreshing()
                self?.collectionView?.reloadData()
            }
        }
    }
    
    // After search request we must reset page number to 1 and clear all previous fetched urls
    // and scroll collection view to top.
    // searchController?.isActive = false - this line closes the search controller view
    private func search() {
        guard let cv = self.collectionView else { return }
        pageNumber = 1
        viewModel.reset()
        fetch()
        if cv.numberOfItems(inSection: 0) > 0 {
            cv.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
        searchController?.isActive = false
    }
    
    private func showAlertView(with error: Error) {
        let alertController = UIAlertController(title: "Alarm!!!", message: "Error occured while fetching data from the server! Error: \(error.localizedDescription)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Close", style: .cancel)
        let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.fetch()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        present(alertController, animated: false)
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.urlsCount
        count > 0 ? collectionView.restoreBackgroundView() : collectionView.customBackgroundView()
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.collectionViewCellId, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        if !viewModel.imageUrlStrings.isEmpty {
            cell.configure(with: viewModel.imageUrlStrings[indexPath.row])
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Logic for pagination. Before every 15 cells to scroll and before show
        // we send new request with next page
        if indexPath.row == viewModel.urlsCount - 15
            && pageNumber < viewModel.pagesCount
            && viewModel.urlsCount < viewModel.totalCount {

            pageNumber += 1
            fetch()
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    // Main part where we are going to search new images
    // While typing new search term if there is a previous search term
    // in local storage, we will filter them. Otherwise show all previous terms
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
              let vc = searchViewController else { return }
        vc.printText(text: text, isSearchBarActive: searchController.isActive)
    }
}

extension MainViewController: UISearchControllerDelegate {
    
    // Reload search terms history
    func didPresentSearchController(_ searchController: UISearchController) {
        guard let viewController = searchViewController else { return }
        viewController.reloadTableView()
    }
}

extension MainViewController: UISearchBarDelegate {
    
    // Searches new images and saves search term in local storage if it wasn't stored before
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        searchTerm = text
        viewModel.save(searchTerm: text)
    }
}
