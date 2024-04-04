import UIKit
class ShareUserCollectionViewCell : UICollectionViewCell {
    
    var user : User!
    
    var userImageView : UIImageView! = UIImageView()
    
    var nameLabel : UILabel! = UILabel()
    
    var checkMarkImageView : UIImageView! = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)))!)

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    func configure(user : User) {
        self.user = user
        nameLabel.text = user.name
        if let image = user.image {
            userImageView.image = image
        } else {
            Task {
                let image = await user.imageURL?.getImageFromImageURL()
                userImageView.image = image
                user.image = image
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func beSelected(selected : Bool) {
        self.checkMarkImageView.isHidden = !selected
    }
    
    
    func layout() {
        
        self.contentView.addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.backgroundColor = .secondaryBackgroundColor
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 16
        userImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.font = .weightSystemSizeFont(systemFontStyle: .caption1, weight: .medium )
        
        self.contentView.addSubview(checkMarkImageView)
        checkMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageViewOffset : CGFloat = 12
        let labelVerOffset : CGFloat = 8
        let labelHorOffset : CGFloat = 4
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: imageViewOffset),
            userImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            userImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6),
            userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: labelVerOffset),
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -labelVerOffset),
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: labelHorOffset),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -labelHorOffset),
            
            checkMarkImageView.centerXAnchor.constraint(equalTo: self.userImageView.trailingAnchor, constant: -labelHorOffset),
            checkMarkImageView.centerYAnchor.constraint(equalTo: self.userImageView.bottomAnchor, constant: -labelHorOffset),
            checkMarkImageView.widthAnchor.constraint(equalTo : self.heightAnchor, multiplier: 0.15),
            checkMarkImageView.heightAnchor.constraint(equalTo: self.checkMarkImageView.widthAnchor),
            
        ])
        
        checkMarkImageView.tintColor = .white
        checkMarkImageView.backgroundColor = .tintOrange
        checkMarkImageView.contentMode = .scaleAspectFit
        checkMarkImageView.clipsToBounds = true
        checkMarkImageView.layer.cornerRadius = 6
        self.beSelected(selected: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        beSelected(selected: false)
    }
    
    
}
