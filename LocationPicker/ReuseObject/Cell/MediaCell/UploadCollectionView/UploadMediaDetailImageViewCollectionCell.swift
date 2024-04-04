
import UIKit

class UploadMediaDetailImageViewCollectionCell  : ImageViewCollectionCell, UploadMediaTextFieldProtocol {
    var textField : RoundedTextField!
    
    override var cornerRadiusfloat: CGFloat! {
        return 16
    }
    
    var textFieldDelegate : UITextFieldDelegate!
    
    var contentModeToggleTapGesture : UITapGestureRecognizer!
    
    var mediaHeightScale : Double!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.backgroundColor = .secondaryBackgroundColor
        contentModeToggleTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentModeToggle))
        self.imageView.addGestureRecognizer(contentModeToggleTapGesture)
        self.imageView.isUserInteractionEnabled = true
        textField = RoundedTextField()
        textField.backgroundColor = .secondaryBackgroundColor
        textField.layer.cornerRadius = 8
        self.contentView.addSubview(textField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        DispatchQueue.main.async {

            let bounds = self.contentView.bounds
            self.imageView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width , height: bounds.height * self.mediaHeightScale)

        }
    }
    
    override func layoutImageView(media: Media) {
        super.layoutImageView(media: media)
        self.textField.text = media.title
        textField.delegate = self.textFieldDelegate
        self.layoutTextField()
    }
    
    
    
    
    @objc func contentModeToggle() {
        if self.imageView.contentMode == .scaleAspectFill {
            self.imageView.contentMode = .scaleAspectFit
        } else {
            self.imageView.contentMode = .scaleAspectFill
        }
    }

    
    func layoutTextField() {
        let heightScale = 0.15
        let offsetYScale = (1 - mediaHeightScale - heightScale) / 2 + mediaHeightScale
        let widthScale = 0.9
        let offsetXScale = (1 - widthScale) / 2
        let bounds = contentView.bounds
        let frame = CGRect(x: bounds.width * offsetXScale, y: bounds.height * offsetYScale, width: bounds.width * widthScale, height: bounds.height * heightScale )
        textField.frame = frame
    }
}
