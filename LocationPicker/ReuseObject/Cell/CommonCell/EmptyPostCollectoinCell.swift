import UIKit

class EmptyPostCollectoinCell : UICollectionViewCell {
    var descriptionLabel : UILabel! = UILabel()
    
    var blurView : UIVisualEffectView = UIVisualEffectView(frame: .zero, style: .userInterfaceStyle)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSetup()
        labelSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title : String) {
        descriptionLabel.text = title
    }
    
    func layoutSetup() {
        blurView.clipsToBounds = true
        blurView.backgroundColor = .secondaryBackgroundColor
        blurView.layer.cornerRadius = 12
        self.contentView.addSubview(blurView)
        self.contentView.addSubview(descriptionLabel)
        
        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            blurView.centerXAnchor.constraint(equalTo: descriptionLabel.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
            blurView.widthAnchor.constraint(equalTo: descriptionLabel.widthAnchor, multiplier: 1.8),
            blurView.heightAnchor.constraint(equalTo: descriptionLabel.heightAnchor, multiplier: 1.8)
        ])
    }
    
    func labelSetup() {
        self.descriptionLabel.font = .weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)
       
    }
}
