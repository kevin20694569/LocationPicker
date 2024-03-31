import UIKit

class PlaylistImageCollectionCell: UICollectionViewCell {
    
    let cornerRadius: CGFloat = 15
    
    @IBOutlet var imageView : UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = cornerRadius
    }
    
}
