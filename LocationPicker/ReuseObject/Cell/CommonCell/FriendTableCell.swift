import UIKit

class FriendTableCell : UITableViewCell {
    
    
    var friend : Friend!
    
    var userImageView : UIImageView! = UIImageView()
    
    var userNameLabel : UILabel! = UILabel()
    
    let mainButtonAttributes = AttributeContainer([.font:  UIFont.weightSystemSizeFont(systemFontStyle: .body , weight: .medium)])
    
    let pairButtonAttributes = AttributeContainer([.font:  UIFont.weightSystemSizeFont(systemFontStyle: .body , weight: .medium)])

    var mainButton : ZoomAnimatedButton! = ZoomAnimatedButton(frame: .zero)
    
    weak var delegate : ShowViewControllerDelegate?
    
    var leftPairButton : ZoomAnimatedButton! = ZoomAnimatedButton(frame: .zero)
    var rightPairButton : ZoomAnimatedButton! = ZoomAnimatedButton(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGesture()
        setupLayout()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(friend : Friend) {
        
        self.friend = friend
        let status =  friend.friendStatus

        if let image = friend.user.image {
            self.userImageView.image = image
        } else {
            Task {
                let image = try await friend.user.imageURL?.getImageFromURL()
                friend.user.image  = image
                self.userImageView.image = image
            }
        }
        self.userNameLabel.text = friend.user.name
        switch status {


        case .requestNeedRespond :
            self.mainButton.isHidden = true
            self.leftPairButton.isHidden = false
            self.rightPairButton.isHidden = false
        case .hasBeenSentRequest :
            self.mainButton.isHidden = false
            self.leftPairButton.isHidden = true
            self.rightPairButton.isHidden = true
            self.mainButton.configuration?.baseBackgroundColor = status?.backgroundColor
            self.mainButton.configuration?.baseForegroundColor = status?.mainColor
            self.mainButton.configuration?.image = status?.mainImage
            if let title = status?.mainButtonTitle {
                mainButton.configuration?.attributedTitle = AttributedString(title, attributes: mainButtonAttributes)
            }
        default :
            self.mainButton.isHidden = false
            self.leftPairButton.isHidden = true
            self.rightPairButton.isHidden = true
            self.mainButton.configuration?.baseBackgroundColor = status?.backgroundColor
            self.mainButton.configuration?.baseForegroundColor = status?.mainColor
            self.mainButton.configuration?.image = status?.mainImage
            if let title = status?.mainButtonTitle {
                mainButton.configuration?.attributedTitle = AttributedString(title, attributes: mainButtonAttributes)
            }
        }
    }
    
    @objc func mainButtonTarget( _ button : UIButton)  {
        switch self.friend.friendStatus {
        case .isFriend :
            deleteFriendShip()
        case .notFriend :
            sendFriendRequest()
        case .hasBeenSentRequest :
            Task {
                await cancelFriendRequest()
            }
        case .requestNeedRespond :
            return
        case .isSelf :
            showUserProfileController(nil)
        case .none:
            return
        case .some(_):
            return
        }
    }
    
    @objc func leftPairButtonTapped( _ button  : UIButton) {
        if friend.friendStatus == .requestNeedRespond {
            Task {
                await acceptFriendRequest()
            }
        }
    }
    
    @objc func rightPairButtonTapped( _ button : UIButton) {
        if friend.friendStatus == .requestNeedRespond {
            Task {
                await cancelFriendRequest()
            }
        }
    }
    
    func cancelFriendRequest() async {
        do {
            try await FriendManager.shared.cancelFriendRequest(from: Constant.user_id, to: self.friend.user.id)
            self.friend.friendStatus = .notFriend
            self.configure(friend: friend)
        } catch {
            print(error)
        }
    }
    
    
    
    func acceptFriendRequest() async {
        do {
            try await FriendManager.shared.acceptFriendRequestByEachUserID(accept_user_id: Constant.user_id, sentReqeust_user_id: friend.user.id)
            self.friend.friendStatus = .isFriend
            self.configure(friend: friend)
        } catch {
            print(error)
        }
    }
    
    @objc func showUserProfileController( _ gesture : UITapGestureRecognizer?) {
        let controller = MainUserProfileViewController(presentForTabBarLessView: delegate?.presentForTabBarLessView ?? false, user: friend.user, user_id: friend.user.id)
        delegate?.show(controller, sender: nil)
    }
    @objc func sendFriendRequest() {
        Task {
            do {
                try await FriendManager.shared.sendFriendRequest(from: Constant.user_id, to: friend.user.id)
                self.friend.friendStatus = .hasBeenSentRequest
                self.configure(friend: friend)
            } catch {
                print(error)
            }
        }
    }
    
    @objc func deleteFriendShip() {
        guard friend.user.id != Constant.user_id,
        self.friend.friendStatus == .isFriend else {
            return
        }
        
    }
    
    func setupLayout() {
        setupImageView()
        setupLabel()
        setupButton()
        self.isUserInteractionEnabled = true
        self.contentView.addSubview(userImageView)
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(mainButton)
        self.contentView.addSubview(leftPairButton)
        self.contentView.addSubview(rightPairButton)
        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 1),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: mainButton.leadingAnchor, constant: -8),
            mainButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            mainButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            mainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            leftPairButton.leadingAnchor.constraint(equalTo: mainButton.leadingAnchor),
            leftPairButton.widthAnchor.constraint(equalTo: mainButton.widthAnchor, multiplier: 0.5, constant: -2),
            leftPairButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
            rightPairButton.trailingAnchor.constraint(equalTo: mainButton.trailingAnchor),
            rightPairButton.leadingAnchor.constraint(equalTo: leftPairButton.trailingAnchor, constant: 4),
            rightPairButton.widthAnchor.constraint(equalTo: mainButton.widthAnchor, multiplier: 0.5, constant: -2),
            rightPairButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),

            
        ])
    }
    
    func setupImageView() {
        userImageView.backgroundColor = .secondaryBackgroundColor
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 16
        
    }
    
    func setupLabel() {
        
        userNameLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .bold)
        userNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setupGesture() {
        let userImgaeViewGesture = UITapGestureRecognizer(target: self, action: #selector(showUserProfileController( _ :)))
        userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(userImgaeViewGesture)
        let nameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(showUserProfileController( _ :)))
        userNameLabel.isUserInteractionEnabled = true
        self.userNameLabel.addGestureRecognizer(nameLabelGesture)
    }
    
    func setupButton() {
        var config = UIButton.Configuration.filled()
      
        let attrString = AttributedString("", attributes:  mainButtonAttributes  )

        config.attributedTitle = attrString
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        config.imagePadding = 8
        config.titleAlignment = .center
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .caption1, weight: .medium))
        config.baseBackgroundColor = .secondaryBackgroundColor
        config.baseForegroundColor = .white
        mainButton.configuration = config
        mainButton.addTarget(self, action: #selector(mainButtonTarget( _ :)), for: .touchUpInside)
        
        var leftPairConfig = UIButton.Configuration.filled()
      
        let leftPairAttrString = AttributedString("接受", attributes:  pairButtonAttributes  )

        leftPairConfig.attributedTitle = leftPairAttrString
        leftPairConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        leftPairConfig.imagePadding = 2
        leftPairConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .caption2, weight: .regular))
        leftPairConfig.baseBackgroundColor = .tintOrange
        leftPairConfig.baseForegroundColor = .white
        
        leftPairButton.addTarget(self, action: #selector(leftPairButtonTapped( _ : )), for: .touchUpInside)
        leftPairButton.configuration = leftPairConfig
        
        var rightPairConfig = UIButton.Configuration.filled()
      
        let rightPairAttrString = AttributedString("取消", attributes:  pairButtonAttributes  )

        rightPairConfig.attributedTitle = rightPairAttrString
        rightPairConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        rightPairConfig.imagePadding = 2
        rightPairConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .caption2, weight: .regular))
        rightPairConfig.baseBackgroundColor = .secondaryLabelColor
        rightPairConfig.baseForegroundColor = .white
        rightPairButton.addTarget(self, action: #selector(rightPairButtonTapped( _ : )), for: .touchUpInside)
        

        rightPairButton.configuration = rightPairConfig
        
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = nil
    }
}
