import UIKit

class RhsShareRestaurantCell : RhsMessageTableViewCell, MessageShareRestaurantCell  {
    var showRestaurantDetailGesture: UITapGestureRecognizer! = UITapGestureRecognizer()
    
    var sharedRestaurantImageView: UIImageView! = UIImageView()
    
    var restaurantNameLabel: UILabel! = UILabel()
    
    var sharedRestaurant : Restaurant!
    
    var restaurantAdddressLabel : UILabel! = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSharedUserSubviews()
        setGesture()
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        
        self.sharedRestaurant = message.sharedRestaurant
        self.restaurantNameLabel.text = message.sharedRestaurant?.name
        self.restaurantAdddressLabel.text = message.sharedRestaurant?.Address
        self.sharedRestaurantImageView.image = nil
        if let snapshotImage = message.snapshotImage {
            self.sharedRestaurantImageView.image = snapshotImage
        } else {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                if let image = try? await message.snapshotImageURL?.getImageFromURL() {
                    message.snapshotImage = image
                    if let urlstring = self.sharedRestaurant.imageURL  {
                        if message.snapshotImageURL == urlstring {
                            self.sharedRestaurantImageView.image = image
                        }
                    }
                   
                }
            }
        }
    }
    
    
    override func mainViewTapped() {
        guard let restaurant = messageInstance.sharedRestaurant else {
            return
        }
        
        self.showRestaurantDetailViewController(restaurant_id: restaurant.ID, restaurant: restaurant)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.sharedRestaurantImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func layoutSharedUserSubviews() {
        let bounds = UIScreen.main.bounds
        restaurantNameLabel.textColor = .label
        restaurantNameLabel.font = .weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        restaurantNameLabel.numberOfLines = 1
        self.contentView.addSubview(restaurantNameLabel)
        
        restaurantAdddressLabel.textColor = .secondaryLabel
        restaurantAdddressLabel.font = .weightSystemSizeFont(systemFontStyle: .footnote, weight: .regular)
        restaurantAdddressLabel.numberOfLines = 1
        
        self.contentView.addSubview(restaurantAdddressLabel)
        
        sharedRestaurantImageView.contentMode = .scaleAspectFill
        sharedRestaurantImageView.layer.cornerRadius = 8
        sharedRestaurantImageView.clipsToBounds = true
        sharedRestaurantImageView.backgroundColor = .secondaryLabelColor
        
        self.contentView.addSubview(sharedRestaurantImageView)

        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let labelHorOffset : CGFloat = 10
        let labelVerOffset : CGFloat = 8
        let imageViewHeight :CGFloat =  bounds.height * 0.05
        NSLayoutConstraint.activate([
            sharedRestaurantImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: labelVerOffset),
            sharedRestaurantImageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),
            sharedRestaurantImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            sharedRestaurantImageView.trailingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor, constant: -labelHorOffset),
            
            sharedRestaurantImageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            sharedRestaurantImageView.widthAnchor.constraint(equalTo: sharedRestaurantImageView.heightAnchor, multiplier: 1),
           
            restaurantNameLabel.centerYAnchor.constraint(equalTo: sharedRestaurantImageView.topAnchor, constant:   imageViewHeight / 4),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: sharedRestaurantImageView.trailingAnchor, constant: labelHorOffset),
         
            restaurantNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),
           
            restaurantAdddressLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            restaurantAdddressLabel.centerYAnchor.constraint(equalTo: sharedRestaurantImageView.bottomAnchor, constant: -imageViewHeight / 4),
            
            restaurantAdddressLabel.trailingAnchor.constraint(equalTo: restaurantNameLabel.trailingAnchor)
        ])
    }
    
    
    
}

class LhsShareRestaurantCell : LhsMessageTableViewCell, MessageShareRestaurantCell {
    var showRestaurantDetailGesture: UITapGestureRecognizer! = UITapGestureRecognizer()
    
    var sharedRestaurantImageView: UIImageView! = UIImageView()
    
    var restaurantNameLabel: UILabel! = UILabel()
    
    var sharedRestaurant : Restaurant!
    
    var restaurantAdddressLabel : UILabel! = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSharedUserSubviews()
        setGesture()
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        
        self.sharedRestaurant = message.sharedRestaurant
        self.restaurantNameLabel.text = message.sharedRestaurant?.name
        self.restaurantAdddressLabel.text = message.sharedRestaurant?.Address
        self.sharedRestaurantImageView.image = nil

        if let snapshotImage = message.snapshotImage {
            self.sharedRestaurantImageView.image = snapshotImage
        } else {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                if let image = try? await message.snapshotImageURL?.getImageFromURL() {
                    message.snapshotImage = image
                    if let urlstring = self.sharedRestaurant.imageURL  {
                        if message.snapshotImageURL == urlstring {
                            self.sharedRestaurantImageView.image = image
                        }
                    }
                   
                }
            }
        }
    }

    
    override func mainViewTapped() {
        guard let restaurant = messageInstance.sharedRestaurant else {
            return
        }
        
        self.showRestaurantDetailViewController(restaurant_id: restaurant.ID, restaurant: restaurant)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.sharedRestaurantImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func layoutSharedUserSubviews() {
        let bounds = UIScreen.main.bounds
        restaurantNameLabel.textColor = .label
        restaurantNameLabel.font = .weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        restaurantNameLabel.numberOfLines = 1
        self.contentView.addSubview(restaurantNameLabel)
        
        restaurantAdddressLabel.textColor = .secondaryLabel
        restaurantAdddressLabel.font = .weightSystemSizeFont(systemFontStyle: .footnote, weight: .regular)
        restaurantAdddressLabel.numberOfLines = 1
        
        self.contentView.addSubview(restaurantAdddressLabel)
        
        sharedRestaurantImageView.contentMode = .scaleAspectFill
        sharedRestaurantImageView.layer.cornerRadius = 8
        sharedRestaurantImageView.clipsToBounds = true
        sharedRestaurantImageView.backgroundColor = .secondaryLabelColor
        
        self.contentView.addSubview(sharedRestaurantImageView)

        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let labelHorOffset : CGFloat = 10
        let labelVerOffset : CGFloat = 8
        let imageViewHeight :CGFloat =  bounds.height * 0.05
        NSLayoutConstraint.activate([
            
            sharedRestaurantImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: labelVerOffset),
            sharedRestaurantImageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),
            sharedRestaurantImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            sharedRestaurantImageView.trailingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor, constant: -labelHorOffset),
            
            sharedRestaurantImageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            sharedRestaurantImageView.widthAnchor.constraint(equalTo: sharedRestaurantImageView.heightAnchor, multiplier: 1),
            
            restaurantNameLabel.centerYAnchor.constraint(equalTo: sharedRestaurantImageView.topAnchor, constant:   imageViewHeight / 4),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: sharedRestaurantImageView.trailingAnchor, constant: labelHorOffset),
            
            restaurantNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),
            
            restaurantAdddressLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            restaurantAdddressLabel.centerYAnchor.constraint(equalTo: sharedRestaurantImageView.bottomAnchor, constant: -imageViewHeight / 4),
            
            restaurantAdddressLabel.trailingAnchor.constraint(equalTo: restaurantNameLabel.trailingAnchor)
            
            /*sharedRestaurantImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: labelVerOffset),
             sharedRestaurantImageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),
             sharedRestaurantImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            sharedRestaurantImageView.trailingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor, constant: -labelHorOffset),
            sharedRestaurantImageView.heightAnchor.constraint(equalToConstant: bounds.height * 0.05),
            sharedRestaurantImageView.widthAnchor.constraint(equalTo: sharedRestaurantImageView.heightAnchor, multiplier: 1),
            
            restaurantNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),*/
            
            
        ])
    }
}
