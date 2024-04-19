
import UIKit

class UploadMediaDetailImageViewCollectionCell  : ImageViewCollectionCell, UploadMediaTextFieldProtocol {
    

    
    var textField : RoundedTextField!
    
    override var cornerRadiusfloat: CGFloat! {
        return 16
    }
    
    var characterLimit : Int = 16
    
    var textFieldDelegate : UITextFieldDelegate!
    
    var contentModeToggleTapGesture : UITapGestureRecognizer!
    
    var mediaHeightScale : Double!
    
    var validStackView : UIStackView! = UIStackView()
    
    var validMessageLabel : UILabel! = UILabel()
    
    var validImageView : UIImageView! = UIImageView()
    
    var validBackgroundView : UIVisualEffectView! = UIVisualEffectView(frame: .zero, style: .systemChromeMaterialDark)
    
    var messageStackViewBottomConstant : CGFloat = 6
    
     
    

    
    func validMessageViewSetup() {
        validImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        validImageView.tintColor = .systemRed
        validBackgroundView.clipsToBounds = true
        validBackgroundView.layer.cornerRadius = 10
        validMessageLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        validMessageLabel.textColor = .white
        validMessageLabel.text = "超過8個字元"
        validImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(validBackgroundView)
        self.contentView.addSubview(validStackView)
        validBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        validStackView.axis = .horizontal
        validStackView.spacing = 2
        validStackView.distribution = .equalSpacing
        validStackView.addArrangedSubview(validImageView)
        validStackView.addArrangedSubview(validMessageLabel)
        validStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            validStackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            validStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -messageStackViewBottomConstant),
            validStackView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: 0.7),
            validStackView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor , multiplier: 0.2),
            validBackgroundView.widthAnchor.constraint(equalTo: validStackView.widthAnchor, multiplier: 1.1),
            validBackgroundView.heightAnchor.constraint(equalTo: validStackView.heightAnchor, multiplier: 1.1),
            validBackgroundView.centerXAnchor.constraint(equalTo: validStackView.centerXAnchor),
            validBackgroundView.centerYAnchor.constraint(equalTo: validStackView.centerYAnchor),
        ])
        validStackView.isHidden = true
        validBackgroundView.isHidden = true
    }
    
    
    
    func updateTextFieldValidStatus(text: String?) -> Bool {
        let valid = ( text?.halfCount ?? 0 ) <= characterLimit
        self.validStackView.isHidden = valid
        validBackgroundView.isHidden = valid
        return valid
    }
    
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
        validMessageViewSetup()
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
        updateTextFieldValidStatus(text: textField.text)
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
