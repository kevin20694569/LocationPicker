import UIKit

class StandardImageViewCollectionCell : ImageViewCollectionCell {
    override var cornerRadiusfloat: CGFloat {
        return 0
    }
    override func layoutImageView(media: Media) {
        super.layoutImageView(media: media)
        self.imageView.layer.cornerRadius = cornerRadiusfloat
        self.layoutIfNeeded()
    }
}
