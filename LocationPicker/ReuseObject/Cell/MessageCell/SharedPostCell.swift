import UIKit


class RhsMessageSharedPostCell : RhsMessageTableViewCell, MessageSharedPostCell {
    
   
    
    var postImageView: UIImageView! = UIImageView()
    
    var restaurantNameLabel: UILabel! = UILabel()
    
    
    
    var post : PostDetailJson!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSharePostSubviews()
        setGesture()
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        
        self.post = message.postJson
    
        self.restaurantNameLabel.text = message.sharedPostRestaurant?.name
        self.postImageView.image = nil
        postImageView.contentMode = .scaleAspectFit
        if !self.post.isdeleted {
            if let snapshotImage = message.snapshotImage {
                self.postImageView.image = snapshotImage
            } else {
                Task { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if let image = try? await message.snapshotImageURL?.getImageFromURL() {
                        message.snapshotImage = image
                        if message.snapshotImageURL == URL(string : self.post.media!.first!.url) {
                            self.postImageView.image = image
                        }
                    }
                }
            }

        } else {
            postImageView.contentMode = .scaleAspectFit
            postImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(.tintOrange, renderingMode: .alwaysOriginal)

            
        }
    }
    
    override func mainViewTapped() {
        if self.post.isdeleted {
            guard let restaurant = messageInstance.sharedPostRestaurant else {
                return
            }
            
            self.showRestaurantDetailViewController(restaurant_id: restaurant.ID, restaurant: restaurant)
            
        } else {
            guard let post_id = self.post.id else {
                return
            }
            self.showWholePageMediaViewController(post_id: post_id)
        }
    }
        
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    func layoutSharePostSubviews() {
        let bounds = UIScreen.main.bounds
        restaurantNameLabel.textColor = .label
        restaurantNameLabel.font = .weightSystemSizeFont(systemFontStyle: .footnote, weight: .medium)
        self.contentView.addSubview(restaurantNameLabel)
        restaurantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurantNameLabel.numberOfLines = 0
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.backgroundColor = .secondaryLabelColor
        postImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title1, weight: .medium))
        
        self.mainView.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        let labelHorOffset : CGFloat = 12
        let labelVerOffset : CGFloat = 10
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: bounds.height * 0.3),
            postImageView.widthAnchor.constraint(equalTo: postImageView.heightAnchor   , multiplier:  3 / 4 ),
            restaurantNameLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: labelVerOffset),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),
            restaurantNameLabel.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),

        ])
    }
    
    
    
    
    
}

class LhsMessageSharedPostCell : LhsMessageTableViewCell, MessageSharedPostCell {

    var showPostGesture: UITapGestureRecognizer! = UITapGestureRecognizer()
    var postImageView: UIImageView! = UIImageView()
    
    var restaurantNameLabel: UILabel! = UILabel()
    
    var post : PostDetailJson!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSharePostSubviews()
        
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        self.post = message.postJson
        self.restaurantNameLabel.text = message.sharedPostRestaurant?.name
        self.postImageView.image = nil
        if let snapshotImage = message.snapshotImage {
            self.postImageView.image = snapshotImage
        } else {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                if let image = try? await message.snapshotImageURL?.getImageFromURL() {
                    message.snapshotImage = image
                    if message.snapshotImageURL == URL(string : self.post.media!.first!.url) {
                        self.postImageView.image = image
                    }
                }
            }
        }
    }
    
    
    override func mainViewTapped() {
        if self.post.isdeleted {
            guard let restaurant = messageInstance.sharedPostRestaurant else {
                return
            }
            
            self.showRestaurantDetailViewController(restaurant_id: restaurant.ID, restaurant: restaurant)
            
        } else {
            guard let post_id = self.post.id else {
                return
            }
            self.showWholePageMediaViewController(post_id: post_id)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func layoutSharePostSubviews() {
        let bounds = UIScreen.main.bounds
        restaurantNameLabel.textColor = .label
        restaurantNameLabel.font = .weightSystemSizeFont(systemFontStyle: .footnote, weight: .medium)
        self.contentView.addSubview(restaurantNameLabel)
        restaurantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        restaurantNameLabel.text = "jlkklnrwjlknsulojdfnheqoidhjqwoidhjoqwidhoqwjedwlijfweqhn"
        restaurantNameLabel.numberOfLines = 0
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.backgroundColor = .secondaryLabelColor
        self.mainView.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        let labelHorOffset : CGFloat = 12
        let labelVerOffset : CGFloat = 10
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: bounds.height * 0.3),
            postImageView.widthAnchor.constraint(equalTo: postImageView.heightAnchor   , multiplier:  3 / 4 ),
            restaurantNameLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: labelVerOffset),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),
            restaurantNameLabel.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),

        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImageView.image = nil
    }

}


