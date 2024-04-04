
import UIKit

class UploadMediaDetailPlayerLayerCollectionCell : PlayerLayerCollectionCell, UploadMediaTextFieldProtocol {
    var textField : RoundedTextField!
    var contentModeToggleTapGesture : UITapGestureRecognizer!
    var BehindPlayerLayerView : UIView!
    
    var textFieldDelegate : UITextFieldDelegate!
        
    var mediaHeightScale : Double!
    
    override var cornerRadiusfloat: CGFloat! {
        return 16
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        BehindPlayerLayerView = UIView()
        self.contentView.addSubview(BehindPlayerLayerView)

        textField = RoundedTextField()
        self.contentView.addSubview(textField)
        setGesture()
    }
    
    func setGesture() {
        contentModeToggleTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentModeToggle))
        BehindPlayerLayerView.addGestureRecognizer(contentModeToggleTapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func contentModeToggle() {
        if self.playerLayer.videoGravity == .resizeAspectFill {
            self.playerLayer.videoGravity = .resizeAspect
        } else {
            self.playerLayer.videoGravity = .resizeAspectFill
        }
    }
    
    
    
    
    
    override func layoutSoundImageView() {
        super.layoutSoundImageView()
        self.soundViewIncludeBlur.forEach() {
            $0.isHidden = true
        }
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()


    }

    
    override func layoutPlayerlayer(media: Media) {
        super.layoutPlayerlayer(media: media)
        playerLayer.backgroundColor = UIColor.secondaryBackgroundColor.cgColor
        self.playerLayer.player?.isMuted = true
        self.textField.text = media.title
        self.playerLayer.player = media.player
        textField.delegate = self.textFieldDelegate
        DispatchQueue.main.async {
            
            let bounds = self.contentView.bounds
            let frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width , height: bounds.height * self.mediaHeightScale)
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            
            self.BehindPlayerLayerView.frame = frame
            self.playerLayer.frame = frame
            self.BehindPlayerLayerView.layer.addSublayer(self.playerLayer)
            self.playerLayer.isHidden = false
            CATransaction.commit()
            self.layoutTextField()
        }
    }
    
    func layoutTextField() {
        textField.backgroundColor = .secondaryBackgroundColor
        textField.layer.cornerRadius = 8
        let heightScale = 0.15
        let offsetYScale = (1 - mediaHeightScale - heightScale) / 2 + mediaHeightScale
        let widthScale = 0.9
        let offsetXScale = (1 - widthScale) / 2
        let bounds = contentView.bounds
        let frame = CGRect(x: bounds.width * offsetXScale, y: bounds.height * offsetYScale, width: bounds.width * widthScale, height: bounds.height * heightScale )
        textField.frame = frame
    }
    
}
