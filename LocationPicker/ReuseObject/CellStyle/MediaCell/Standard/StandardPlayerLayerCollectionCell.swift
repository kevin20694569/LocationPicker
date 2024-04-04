import UIKit

class StandardPlayerLayerCollectionCell:  PlayerLayerCollectionCell {
    override var cornerRadiusfloat: CGFloat {
        return 0
    }
    override func layoutPlayerlayer(media: Media) {
        super.layoutPlayerlayer(media: media)
        self.playerLayer.cornerRadius = cornerRadiusfloat
        self.layoutIfNeeded()
    }

}
