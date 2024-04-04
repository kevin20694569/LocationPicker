import UIKit

class BlurCollectionCell : UICollectionViewCell {
    var blurView : UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blurView = UIVisualEffectView(frame: self.bounds, style: .userInterfaceStyle)
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 16
        self.contentView.insertSubview(blurView, at: 0)
        self.contentView.backgroundColor = .secondaryBackgroundColor
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        blurView.frame = bounds
    }
}
