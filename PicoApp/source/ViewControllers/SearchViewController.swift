import UIKit

class SearchViewController: BaseViewController {
    
    private let viewModel: MainViewModelProtocol
    private var tableView: UITableView?
    private var filteredSearchTerms = [String]()
    private var isFiltering = false
    var handleSearch: ((String) -> Void)?
    
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func configureView() {
        tableView = UITableView(frame: .zero, style: .plain)
        guard let tv = tableView else { return }
        tv.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.tableViewCellId)
        tv.frame = view.bounds
        tv.delegate = self
        tv.dataSource = self
        view.addSubview(tv)
    }
    
    // Main part where we are going to search new images
    // While typing new search term if there is a previous search term
    // in local storage, we will filter them. Otherwise show all previous terms
    func printText(text: String, isSearchBarActive: Bool) {
        isFiltering = isSearchBarActive && !text.isEmpty
        filterSearchTerms(searchTerm: text)
    }
    
    func reloadTableView() {
        tableView?.reloadData()
    }

    private func filterSearchTerms(searchTerm: String) {
        filteredSearchTerms = viewModel.searchTerms
            .filter {
                $0.lowercased()
                .contains(searchTerm.lowercased())
            }
        if filteredSearchTerms.isEmpty {
            filteredSearchTerms = viewModel.searchTerms
        }
        tableView?.reloadData()
    }
    
    private func getFilteredSearchTerms(by indexPath: IndexPath) -> String {
        if isFiltering {
            return filteredSearchTerms[indexPath.item]
        } else {
            return viewModel.searchTerms[indexPath.item]
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSearch?(getFilteredSearchTerms(by: indexPath))
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredSearchTerms.count
        }
        return viewModel.searchTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.tableViewCellId, for: indexPath)
        cell.textLabel?.text = getFilteredSearchTerms(by: indexPath)
        return cell
    }
    
    
}
