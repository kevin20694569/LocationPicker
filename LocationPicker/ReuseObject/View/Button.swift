import UIKit



class RoundedButton : ZoomAnimatedButton {
    init(frame : CGRect ,Title: String, backgroundColor: UIColor, tintColor : UIColor, font : UIFont, contentInsets : NSDirectionalEdgeInsets? = .init(top: 10, leading: 30, bottom: 10, trailing: 30), cornerRadius : CGFloat  ) {
        super.init(frame: frame)
        var config = UIButton.Configuration.bordered()
        config.cornerStyle = .fixed
        config.titleAlignment = .center
        config.buttonSize = .medium
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = tintColor
        config.contentInsets = contentInsets ?? .init(top: 10, leading: 30, bottom: 10, trailing: 30)
        let attributedString = NSAttributedString(string: Title, attributes: [
            .font : font
        ])
        config.attributedTitle =  AttributedString(attributedString)
        self.configuration = config
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    init() {
        super.init(frame: .zero)
        var config = UIButton.Configuration.bordered()
        config.cornerStyle = .fixed
        config.titleAlignment = .center
        config.buttonSize = .medium
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = tintColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30)
        config.attributedTitle =  AttributedString("")
        self.configuration = config
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        var config = UIButton.Configuration.bordered()
        config.cornerStyle = .fixed
        config.titleAlignment = .center
        config.buttonSize = .medium
        config.baseBackgroundColor = .tintColor
        config.baseForegroundColor = .label
        config.contentInsets = .init(top: 10, leading: 30, bottom: 10, trailing: 30)
        let attributedString = NSAttributedString(string: "", attributes: [
            .font : UIFont.weightSystemSizeFont(systemFontStyle: .subheadline, weight: .medium)
        ])
        config.attributedTitle =  AttributedString(attributedString)
        self.configuration = config
        layer.cornerRadius = 20
        clipsToBounds = true
        self.isUserInteractionEnabled = true
    }
    
    
    func updateTitle(Title: String, backgroundColor: UIColor, tintColor : UIColor, font : UIFont) {
        
        if var config = self.configuration {
            config.baseBackgroundColor = backgroundColor
            config.baseForegroundColor = tintColor
            let attributedString = NSAttributedString(string: Title, attributes: [
                .font : font,
            ])
            config.attributedTitle =  AttributedString(attributedString)
            self.configuration = config
        }
    }
}

class DarkBlurButton: RoundedButton {
    
    var blurView : UIVisualEffectView! = {
        
        let blurEffect = UIBlurEffect(style: .userInterfaceStyle )
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 10
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false

        return blurView
    }()

    override init(frame : CGRect ,Title: String, backgroundColor: UIColor, tintColor : UIColor, font : UIFont, contentInsets : NSDirectionalEdgeInsets? = .init(top: 8, leading: 16, bottom: 8, trailing: 16), cornerRadius : CGFloat  )  {
        super.init(frame: frame, Title: Title, backgroundColor: backgroundColor, tintColor: tintColor, font: font, contentInsets: contentInsets, cornerRadius: cornerRadius)

        setupBlurBackground(style: .systemUltraThinMaterialDark, cornerRadius: cornerRadius, frame: frame)
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBlurBackground(style: .systemUltraThinMaterialDark, cornerRadius: 10, frame: self.frame)
    }
    
    func setupBlurBackground(style : UIBlurEffect.Style, cornerRadius : CGFloat, frame : CGRect) {
        self.backgroundColor = .clear
        self.tintColor = .clear
        self.insertSubview(blurView, belowSubview: self.titleLabel ?? self)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }


}
