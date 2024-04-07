
import UIKit

class CollectionViewButtonCell : UICollectionViewCell {
    var button : ZoomAnimatedButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutButton()
    }

    func configure(buttonIndex : Int, text : String, image : UIImage) {
        self.button.tag = buttonIndex
        var config = UIButton.Configuration.bordered()
        config.cornerStyle = .fixed
        config.titleAlignment = .center
        config.buttonSize = .medium
        
        config.baseBackgroundColor = .secondaryBackgroundColor
        config.baseForegroundColor = .white
        config.image = image.withConfiguration(UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .caption1, weight: .bold)))
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .bold))
        config.imagePadding = 4
        let attributedString = NSAttributedString(string: text, attributes: [
            .font : UIFont.weightSystemSizeFont(systemFontStyle: .footnote , weight: .medium),
        
        ])

        config.attributedTitle =  AttributedString(attributedString)
        button.configuration = config
    }
    
    func layoutButton() {
        button = ZoomAnimatedButton(frame: contentView.bounds)
        button.clipsToBounds = true
        button.layer.cornerRadius = 12
        self.contentView.addSubview(button)
    }
}
