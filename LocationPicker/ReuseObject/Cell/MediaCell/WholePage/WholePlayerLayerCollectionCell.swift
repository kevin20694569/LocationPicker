import UIKit
import AVFoundation

class WholePlayerLayerCollectionCell: PlayerLayerCollectionCell {
    
    override var mediaCornerRadius: CGFloat {
        return 0
    }
    
    override func soundImageViewSetup() {
        soundImageview.isHidden = true
    }

}
