import UIKit

class OptionTableCell : UITableViewCell {
    var backgroundCornerRadius : CGFloat! = 16
    
    var titleLabel : UILabel! = UILabel()
    
    var logoImageView : UIImageView! = UIImageView()
    
    var mainBackgroundView : UIView! = UIView()
    
    var backgroundViewHorConstant : CGFloat! = 20
    
    
    func configure(title : String, logoImage : UIImage) {
        titleLabel.text = title
        logoImageView.image = logoImage
    }
    
    func viewSetup() {
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        mainBackgroundView.clipsToBounds = true
        mainBackgroundView.backgroundColor = .thirdBackgroundColor
        mainBackgroundView.layer.cornerRadius = backgroundCornerRadius

    }
    
    func select(_ bool : Bool) {
        self.mainBackgroundView.backgroundColor = bool ? .secondaryLabelColor : .thirdBackgroundColor
    }
    
    func backgroundViewCorners(topCornerMask : Bool?) {

        if let topCornerMask = topCornerMask {
            mainBackgroundView.layer.maskedCorners = topCornerMask ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            mainBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func labelSetup() {
        titleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .medium)
    }
    
    func imageViewSetup() {
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .label
    }
    
    func initLayout() {
        contentView.addSubview(mainBackgroundView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)

        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            mainBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            mainBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: backgroundViewHorConstant),
            mainBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -backgroundViewHorConstant),
            
            logoImageView.leadingAnchor.constraint(equalTo: mainBackgroundView.leadingAnchor, constant: 16),
            logoImageView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 1.2),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 1),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -backgroundViewHorConstant),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
        contentView.backgroundColor = .clear
        
    }
    
    func separatorSetup() {
        self.separatorInset = UIEdgeInsets(top: 0, left: backgroundViewHorConstant, bottom: 0, right: backgroundViewHorConstant)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewSetup()
        labelSetup()
        imageViewSetup()
        separatorSetup()
        initLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
