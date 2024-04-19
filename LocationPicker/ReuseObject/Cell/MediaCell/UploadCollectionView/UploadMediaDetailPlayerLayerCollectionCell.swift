
import UIKit

class UploadMediaDetailPlayerLayerCollectionCell : PlayerLayerCollectionCell, UploadMediaTextFieldProtocol {

    
    
    var characterLimit : Int = 16
    
    var textField : RoundedTextField!
    var contentModeToggleTapGesture : UITapGestureRecognizer!
    var BehindPlayerLayerView : UIView!
    
    var textFieldDelegate : UITextFieldDelegate!
        
    var mediaHeightScale : Double!
    
    
    var validStackView : UIStackView! = UIStackView()
    
    var validMessageLabel : UILabel! = UILabel()
    
    var validImageView : UIImageView! = UIImageView()
    
    var validBackgroundView : UIVisualEffectView! = UIVisualEffectView(frame: .zero, style: .systemChromeMaterialDark)
    
    var messageStackViewBottomConstant : CGFloat = 6
    
     
    
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
        validMessageViewSetup()
    }
    
    func validMessageViewSetup() {
        validImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        validImageView.tintColor = .systemRed
        validBackgroundView.clipsToBounds = true
        validBackgroundView.layer.cornerRadius = 10
        validMessageLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        validMessageLabel.textColor = .white
        validMessageLabel.text = "超過8個字元"
        validImageView.contentMode = .scaleAspectFit
        self.BehindPlayerLayerView.addSubview(validBackgroundView)
        self.BehindPlayerLayerView.addSubview(validStackView)
        validBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        validStackView.axis = .horizontal
        validStackView.spacing = 2
        validStackView.distribution = .fill
        validStackView.addArrangedSubview(validImageView)
        validStackView.addArrangedSubview(validMessageLabel)
        validStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            validStackView.centerXAnchor.constraint(equalTo: self.BehindPlayerLayerView.centerXAnchor),
            validStackView.bottomAnchor.constraint(equalTo: BehindPlayerLayerView.bottomAnchor, constant: -messageStackViewBottomConstant),
            validStackView.widthAnchor.constraint(equalTo: BehindPlayerLayerView.heightAnchor, multiplier: 0.7),
            validStackView.heightAnchor.constraint(equalTo: BehindPlayerLayerView.heightAnchor , multiplier: 0.2),
            validBackgroundView.widthAnchor.constraint(equalTo: validStackView.widthAnchor, multiplier: 1.1),
            validBackgroundView.heightAnchor.constraint(equalTo: validStackView.heightAnchor, multiplier: 1.1),
            validBackgroundView.centerXAnchor.constraint(equalTo: validStackView.centerXAnchor),
            validBackgroundView.centerYAnchor.constraint(equalTo: validStackView.centerYAnchor),
        ])
        validStackView.isHidden = true
        validBackgroundView.isHidden = true
    }
    
    func updateTextFieldValidStatus(text : String?) -> Bool {
       
        let valid = text?.halfCount ?? 0 <= characterLimit
        self.validStackView.isHidden = valid
        validBackgroundView.isHidden = valid
        return valid
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
            self.BehindPlayerLayerView.layer.insertSublayer(self.playerLayer, at: 0)
            self.playerLayer.isHidden = false
            CATransaction.commit()
            self.layoutTextField()
        }
        updateTextFieldValidStatus(text: textField.text )
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
