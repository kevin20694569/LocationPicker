import UIKit

class FriendTableCell : UITableViewCell {
    
    var user : User! = User()
    
    var userImageView : UIImageView! = UIImageView()
    
    var userNameLabel : UILabel! = UILabel()
    
    
    
    var mainButton : ZoomAnimatedButton! = ZoomAnimatedButton(frame: .zero)
    
    weak var delegate : ShowViewControllerDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGesture()
        setupLayout()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(friend : Friend) {
        
        self.user = friend.user
        if let image = friend.user.image {
            self.userImageView.image = image
        } else {
            Task {
                let image = try await user.imageURL?.getImageFromURL()
                friend.user.image  = image
                self.userImageView.image = image
            }
        }
        self.userNameLabel.text = friend.user.name
        if friend.user.isFriend {
            self.mainButton.configuration?.baseBackgroundColor = .secondaryLabelColor
            self.mainButton.configuration?.title = ""
            self.mainButton.configuration?.baseForegroundColor = .secondaryBackgroundColor
            self.mainButton.configuration?.image = UIImage(systemName: "checkmark.message.fill")
            self.mainButton.removeTarget(self, action: #selector(sendFriendRequest(_ :)), for: .touchUpInside)
            self.mainButton.addTarget(self, action: #selector(showMessageViewController( _ :)), for: .touchUpInside)
        } else {
            self.mainButton.configuration?.baseBackgroundColor = .tintOrange
            self.mainButton.configuration?.image = nil
            self.mainButton.configuration?.baseForegroundColor = .white
            self.mainButton.configuration?.title = "加朋友"
            self.mainButton.removeTarget(self, action: #selector(showMessageViewController(_ :)), for: .touchUpInside)
            self.mainButton.addTarget(self, action: #selector(sendFriendRequest( _ :)), for: .touchUpInside)
        }
    }
    
    @objc func showUserProfileController( _ gesture : UITapGestureRecognizer) {
        let controller = MainUserProfileViewController(presentForTabBarLessView: delegate?.presentForTabBarLessView ?? false, user: user, user_id: user.user_id)
        delegate?.show(controller, sender: nil)
    }
    
    func setupLayout() {
        setupImageView()
        setupLabel()
        setupButton()

        self.isUserInteractionEnabled = true
        self.contentView.addSubview(userImageView)
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(mainButton)
        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 1),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: mainButton.leadingAnchor, constant: -12),
            mainButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            mainButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            mainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    func setupImageView() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 16
        
    }
    
    func setupLabel() {
        
        userNameLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
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
        let attrString = AttributedString("", attributes: AttributeContainer([.font : UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .medium)]) )
        config.attributedTitle = attrString
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
        config.baseBackgroundColor = .secondaryBackgroundColor
        config.baseForegroundColor = .white
        mainButton.configuration = config
        mainButton.addTarget(self, action: #selector(sendFriendRequest( _ :)), for: .touchUpInside)
        
    }
    
    @objc func sendFriendRequest( _ button : UIButton) {
        Task {
            do {
                try await FriendsManager.shared.sendFriendRequest(from: Constant.user_id, to: self.user.user_id)
            } catch {
                print(error)
            }
        }
    }
    
    @objc func showMessageViewController( _ button : UIButton) {
        let controller = MessageViewController(chatRoomUser_ids: [user.user_id, Constant.user_id])
        delegate?.show(controller, sender: nil)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = nil
    }
}
