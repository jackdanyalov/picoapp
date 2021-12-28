import UIKit
import CocoaLumberjack

// I think this is a good idea how to use Factory pattern to build every
// screen with all needed dependencies.

/// Main factory which builds MainViewController with all needed dependencies.
final class MainFactory {
    static func make() -> UIViewController {
        let api = APIClient()
        let localStorage = LocalStorage()
        let dataFetcher = DataFetcher(api: api)
        let viewModel = MainViewModel(dataFetcher: dataFetcher, localStorage: localStorage)
        let viewController = MainViewController(viewModel: viewModel)
        return viewController
    }
}
