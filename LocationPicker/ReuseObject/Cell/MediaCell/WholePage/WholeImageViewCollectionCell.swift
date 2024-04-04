import UIKit
class WholeImageViewCollectionCell: ImageViewCollectionCell {
    
    override var cornerRadiusfloat: CGFloat {
        return 0
    }
    
    override func layoutImageView(media: Media) {
        super.layoutImageView(media: media)
        imageView.layer.cornerRadius = cornerRadiusfloat
    }

}
