import UIKit

/// BaseViewController for using as a base place for common and repeateble functions and parameters
class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    @available(*, unavailable, message: "Conformance to NSCoding is disabled for this type")
    required convenience init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
