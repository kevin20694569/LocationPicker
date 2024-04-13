

import UIKit

class LoadingCollectionCell : UICollectionViewCell {
    var indicatorView : UIActivityIndicatorView! = UIActivityIndicatorView(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
        indicatorView.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        indicatorView.stopAnimating()
    }
    
    func layoutSetup() {
        self.contentView.addSubview(indicatorView)
        indicatorView.style = .large
        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            indicatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        ])
    }
}
