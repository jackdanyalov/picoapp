import UIKit

extension UICollectionView {
    
    /// Show loading indicator while images are downloading
    func customBackgroundView() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        self.backgroundView = activityIndicator
    }
    
    func restoreBackgroundView() {
        self.backgroundView = nil
    }
    
}
