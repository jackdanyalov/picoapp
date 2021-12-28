import UIKit
import Kingfisher

class CollectionViewCell: UICollectionViewCell {
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        imageView.frame = contentView.frame
        activityIndicator.center = contentView.center
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        imageView.image = nil
        
        // Cancel image download if imaged already disappeared while scrolling
        imageView.kf.cancelDownloadTask()
    }
    
    public func configure(for data: Data) {
        imageView.image = UIImage(data: data)
    }
    
    public func configure(with urlString: String) {
        activityIndicator.startAnimating()
        let url = URL(string: urlString)
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
    }
    
}
