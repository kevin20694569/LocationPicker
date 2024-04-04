import UIKit
import AVFoundation

class WholePlayerLayerCollectionCell: PlayerLayerCollectionCell {
    
    override var cornerRadiusfloat: CGFloat {
        return 0
    }
    
    override func layoutSoundImageView() {
        soundImageview = UIImageView()
        soundImageview.isHidden = true
    }

    
    override func layoutPlayerlayer(media: Media) {
        super.layoutPlayerlayer(media: media)
        playerLayer.cornerRadius = cornerRadiusfloat
        
    }

}
