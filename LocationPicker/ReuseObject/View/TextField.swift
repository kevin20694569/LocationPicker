import UIKit

class RoundedTextField: UITextField {
    

    let padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        self.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        
    }
}

class RoundedTextView : UITextView {
    let padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.textContainerInset = padding
        self.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        
    }
}

class AddMediaImageView : UIImageView {
    var collectionViewCellcornerRadiusfloat : CGFloat {
        return Constant.standardCornerRadius
    }
    var uploadMediaGesture : UITapGestureRecognizer!
    
    weak var PhotpPostViewControllerDelegate : PhotoPostViewControllerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func layoutImageView(frame: CGRect) {
        uploadMediaGesture =  UITapGestureRecognizer(target: self, action: #selector(phpPickerPresent( _ : )) )
        self.layer.borderColor = UIColor.secondaryBackgroundColor.cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        self.layer.cornerRadius = collectionViewCellcornerRadiusfloat
        self.frame = frame
        self.contentMode = .center

        self.isUserInteractionEnabled = true
        self.image = UIImage(systemName: "plus")?.withTintColor(.label, renderingMode: .alwaysOriginal).scale(newWidth: frame.width * 0.2 )
        self.addGestureRecognizer(uploadMediaGesture)

    }
    
    @objc func phpPickerPresent(_ gesture : UITapGestureRecognizer) {
        PhotpPostViewControllerDelegate?.selectPHPickerImage()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}
