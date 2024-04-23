import UIKit

class ProfileMainCell: UICollectionViewCell, UIViewControllerTransitioningDelegate {
    
    var mainView : UIView! = UIView()
    weak var delegate : ProfileMainCellDelegate?
    
    var userImageView : UIImageView! = UIImageView()
    
    var leftButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var shareButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    let profileDetailButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var leftLeftPairButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var leftRightPairButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var detailStackView : UIStackView! = UIStackView()
    
    var buttonStackView : UIStackView! = UIStackView()
    
    var postCountStackView : UIStackView! = UIStackView()
    var friendCountStackView : UIStackView! = UIStackView()
    var playlistCountStackView : UIStackView! = UIStackView()
    
    var postCountLabel : UILabel! = UILabel() { didSet {
        postCountLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
    }}
    var friendCountLabel : UILabel! = UILabel() { didSet {
        friendCountLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
    }}
    var playlistCountLabel : UILabel! = UILabel() { didSet {
        playlistCountLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
    }}
    
    var userProfile : UserProfile!
    
    var countStackViews : [(title : String , stackView :  UIStackView, label : UILabel)]! {
        return [("貼文", postCountStackView, postCountLabel) , ("朋友", friendCountStackView, friendCountLabel), ("清單", playlistCountStackView, playlistCountLabel)]
    }
    
    func setGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showFriendsViewController ( _: )))
        friendCountStackView.isUserInteractionEnabled = true
        self.friendCountStackView.addGestureRecognizer(gesture)
    }
    
    @objc func showFriendsViewController( _ gesture : UITapGestureRecognizer) {
        let controller = FriendViewController(presentForTabBarLessView: self.delegate?.presentForTabBarLessView ?? false, user: self.userProfile.user)
        delegate?.show(controller, sender: nil)
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainView.backgroundColor = .secondaryBackgroundColor
        self.contentView.backgroundColor = .backgroundPrimary
        layoutButtons()
        layoutDetailStackView()
        layout()
        imageViewSetup()
        setGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutButtons() {
        var leftConfig = UIButton.Configuration.filled()


        leftConfig.titleAlignment = .center
        
        leftConfig.imagePlacement = .trailing
        leftConfig.baseBackgroundColor = .tintOrange
        leftConfig.title = nil
        self.leftButton.configuration = leftConfig
        leftButton.addTarget(self, action: #selector(leftButtonTapped ( _ : )), for: .touchUpInside)
        
        shareButton.addTarget(self, action: #selector(showShareController( _ :) ), for: .touchUpInside)
        
        buttonStackView.spacing = 16
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .center
        self.buttonStackView.addArrangedSubview(leftButton)
        self.leftButton.configuration = leftConfig
        
        var smallButtonConfig = UIButton.Configuration.filled()

        smallButtonConfig.baseBackgroundColor = .tintOrange
        smallButtonConfig.title = nil
        
        smallButtonConfig.imagePlacement = .all
        smallButtonConfig.baseBackgroundColor = .gray
        smallButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .body, weight: .bold))

        [profileDetailButton, shareButton].enumerated().forEach() { (index, button) in
            if index == 0 {
                smallButtonConfig.image = UIImage(systemName: "person.crop.circle.fill")
            } else if index == 1 {
                smallButtonConfig.image = UIImage(systemName: "square.and.arrow.up.fill")
            }
            button.configuration = smallButtonConfig
            self.buttonStackView.addArrangedSubview(button)
        }
        
        let pairButtonAttrContainer = AttributeContainer([.font : UIFont.weightSystemSizeFont(systemFontStyle: .footnote  , weight: .medium)
        ])
        
        
        var leftPairButtonConfig = UIButton.Configuration.filled()

        leftPairButtonConfig.baseBackgroundColor = .white
        leftPairButtonConfig.attributedTitle = AttributedString("接受", attributes: pairButtonAttrContainer)
        leftPairButtonConfig.image = UIImage(systemName: "checkmark")
        leftPairButtonConfig.imagePlacement = .leading
        leftPairButtonConfig.imagePadding = 4
        leftPairButtonConfig.baseBackgroundColor = .tintOrange
        leftPairButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout, weight: .bold))
        leftLeftPairButton.addTarget(self, action: #selector(leftLeftPaitButtonTapped(_ :)), for: .touchUpInside)
        leftLeftPairButton.configuration = leftPairButtonConfig
        var rightPairButtonConfig = UIButton.Configuration.filled()

        rightPairButtonConfig.baseBackgroundColor = .white
        rightPairButtonConfig.attributedTitle = AttributedString("取消", attributes: pairButtonAttrContainer)
        rightPairButtonConfig.image = UIImage(systemName: "xmark")
        rightPairButtonConfig.imagePadding = 4
        rightPairButtonConfig.imagePlacement = .leading
        rightPairButtonConfig.baseBackgroundColor = .secondaryLabelColor
        rightPairButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout, weight: .bold))
        leftRightPairButton.addTarget(self, action: #selector(leftRightPaitButtonTapped(_ :)), for: .touchUpInside)
        leftRightPairButton.configuration = rightPairButtonConfig

    }
    
    @objc func leftButtonTapped(_ sender : UIView) {
        switch self.userProfile.friendStatus {
        case .notFriend :
            Task {
                await sendFriendRequest()
            }
        case .isFriend :
            self.delegate?.showMessageViewController(user_ids: [self.userProfile.user.id, Constant.user_id])
        case .hasBeenSentRequest :
            Task {
                await self.cancelFriendRequest()
                self.userProfile.friendStatus = .notFriend
                
                updateLeftButton()
            }
        case .isSelf :
            delegate?.showEditUserProfileViewController(userProfile: self.userProfile)
            break
        case .none:
            break
        case .some(.requestNeedRespond):
            break
        case .some(.default):
            break
        }
        
    }
    
    @objc func leftLeftPaitButtonTapped( _ button : UIButton) {
        Task {
            await self.acceptFriendRequest()
        }
        
    }
    
    @objc func leftRightPaitButtonTapped( _ button : UIButton) {
        Task {
            await self.cancelFriendRequest()
        }
    }
            
    
    func cancelFriendRequest() async {
        do {
            try await FriendManager.shared.cancelFriendRequest(from: Constant.user_id, to: self.userProfile.user.id)
            self.userProfile.friendStatus = .notFriend
            self.configure(userProfile: userProfile)
        } catch {
            print(error)
        }
        
    }
    
    
    
    func acceptFriendRequest() async {
        do {
            try await FriendManager.shared.acceptFriendRequestByEachUserID(accept_user_id: Constant.user_id, sentReqeust_user_id: self.userProfile.user.id)
            self.userProfile.friendStatus = .isFriend
            self.configure(userProfile: userProfile)
        } catch {
            print(error)
        }
            
    }
    @objc func sendFriendRequest() async  {
        Task {
            do {
                try await FriendManager.shared.sendFriendRequest(from: Constant.user_id, to: self.userProfile.user.id)
                self.userProfile.friendStatus = .hasBeenSentRequest
                self.configure(userProfile: userProfile)
            } catch {
                print(error)
            }
        }
    }
    

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let bounds = UIScreen.main.bounds
        
        let maxWidth = bounds.width - 16
        var maxHeight : CGFloat! = bounds.height * 0.5
        if presented is ShareViewController {
            maxHeight =  bounds.height * 0.7
        }
        return MaxFramePresentedViewPresentationController(presentedViewController: presented, presenting: presenting, maxWidth: maxWidth, maxHeight: maxHeight)
    }
    
    @objc func showShareController( _ button : UIButton) {
        let controller = ShareUserController(user: userProfile.user)
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        self.delegate?.present(controller, animated: true)
    }
    
    func layoutDetailStackView() {
        countStackViews.forEach() { title, stackView, label in
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .medium)
            titleLabel.textAlignment = .center
            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .subheadline, weight: .medium)
            stackView.addArrangedSubview(titleLabel)
            stackView.spacing = 6
            stackView.addArrangedSubview(label)
            stackView.axis = .vertical
            label.text = ""
            stackView.distribution = .fillEqually
            stackView.alignment = .center
            detailStackView.addArrangedSubview(stackView)
        }
        detailStackView.axis = .horizontal
        detailStackView.alignment = .center
        detailStackView.distribution = .fillEqually
    }
    
    func layout() {

        self.contentView.addSubview(mainView)
        self.mainView.addSubview(userImageView)
        self.mainView.addSubview(detailStackView)
        self.mainView.addSubview(buttonStackView)
        self.mainView.addSubview(leftButton)
        self.mainView.addSubview(leftLeftPairButton)
        self.mainView.addSubview(leftRightPairButton)
        
        self.mainView.translatesAutoresizingMaskIntoConstraints = false
        self.userImageView.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        leftLeftPairButton.translatesAutoresizingMaskIntoConstraints = false
        leftRightPairButton.translatesAutoresizingMaskIntoConstraints = false
        profileDetailButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
             mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
             mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
             mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
             userImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12),
             userImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 30),
             userImageView.trailingAnchor.constraint(equalTo: detailStackView.leadingAnchor, constant: -24),
             userImageView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.54),
             userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 1),
             detailStackView.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
             detailStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -24),
             
             
             leftButton.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10 ),
             leftButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
             
             leftButton.trailingAnchor.constraint(equalTo: mainView.centerXAnchor, constant: -8),
             leftButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10),
             
             profileDetailButton.heightAnchor.constraint(equalTo: leftButton.heightAnchor),
             shareButton.heightAnchor.constraint(equalTo: leftButton.heightAnchor),
             
             buttonStackView.centerYAnchor.constraint(equalTo: leftButton.centerYAnchor),
            
             buttonStackView.leadingAnchor.constraint(equalTo: mainView.centerXAnchor, constant: 8),
             buttonStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
             
             leftLeftPairButton.leadingAnchor.constraint(equalTo: leftButton.leadingAnchor),
             leftLeftPairButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 0.5, constant: -2),
             leftLeftPairButton.centerYAnchor.constraint(equalTo : leftButton.centerYAnchor),
             leftRightPairButton.leadingAnchor.constraint(equalTo: leftLeftPairButton.trailingAnchor, constant: 4),
             leftRightPairButton.trailingAnchor.constraint(equalTo : leftButton.trailingAnchor),
             leftRightPairButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 0.5, constant: -2),
             leftRightPairButton.centerYAnchor.constraint(equalTo : leftButton.centerYAnchor),
             
             
             
         ])
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
    }
    
    func imageViewSetup() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 12.0
        userImageView.backgroundColor = .secondaryLabelColor
        userImageView.contentMode = .scaleAspectFill
    }
    
    func configure(userProfile : UserProfile ) {
        self.userProfile = userProfile
        if let userImage = userProfile.user.image {
            userImageView.image = userImage
        } else {
            if let imageURL = userProfile.user.imageURL {
                Task {
                    let image = try await imageURL.getImageFromURL()
                    self.userProfile.user.image = image
                    userImageView.image = image
                }
            }
        }
        if let friends_count = userProfile.user.friends_count {
            self.friendCountLabel.text = String(friends_count)
        }
        if let posts_count = userProfile.user.posts_count {
            self.postCountLabel.text = String(posts_count)
        }
        
        updateLeftButton()
        
    }
    
    func updateLeftButton() {
        
        if self.userProfile.friendStatus == .requestNeedRespond {
            self.leftButton.isHidden = true
            self.leftLeftPairButton.isHidden = false
            self.leftRightPairButton.isHidden = false
        } else {
            self.leftButton.isHidden = false
            self.leftLeftPairButton.isHidden = true
            self.leftRightPairButton.isHidden = true
            if var leftConfig = leftButton.configuration {
                let arrtri = AttributedString( userProfile.friendStatus.mainButtonTitle, attributes: AttributeContainer([
                    .font : UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .bold),
                ]))
                
                leftConfig.baseBackgroundColor = userProfile.friendStatus.backgroundColor
                leftConfig.baseForegroundColor = userProfile.friendStatus.mainColor
                leftConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout, weight: .bold))
                leftConfig.image = userProfile.friendStatus.mainImage
                leftConfig.attributedTitle = arrtri
                self.leftButton.configuration = leftConfig
                
            }
        }
        
        
        
    }
    
    

}
