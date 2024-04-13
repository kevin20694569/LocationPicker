import UIKit
class FriendRequestsTableViewCell : UITableViewCell  {
    
    var pairButtonContainer : AttributeContainer = AttributeContainer([.font : UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)])
    
    
    var userRequestInstance : UserFriendRequest!
    
    weak var friendRequestsDelegate : FriendRequestsCellDelegate!
    
    var userImageView: UIImageView! = UIImageView() { didSet {
        userImageView.isUserInteractionEnabled = true
        userImageView.contentMode = .scaleAspectFit
        userImageView.layer.cornerRadius = 10.0
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .secondaryBackgroundColor
    }}
    var userNameLabel : UILabel! = UILabel() { didSet {
        userNameLabel.isUserInteractionEnabled  = true
    }}
    

    
    var sendTimeLabel : UILabel! = UILabel()
    
    var leftButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var rightButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var mainButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    @objc func segueToUserProfileView() {
        if self.userRequestInstance.friendStatus == .isFriend {
            friendRequestsDelegate.segueToUserProfileView(userRequst: self.userRequestInstance )
        }
    }
    
    func configure(userRequest: UserFriendRequest)  {

        userRequestInstance = userRequest
        self.checkIsResponsed(request: userRequest)
        userNameLabel.text = userRequest.user?.name
        sendTimeLabel.text = userRequest.sent_time.timeAgoFromString()
        let status = userRequest.friendStatus
        
        if status == .notFriend {
            self.mainButton.isHidden = false
            self.leftButton.isHidden = true
            self.rightButton.isHidden = true
            var config =  self.mainButton.configuration
            config?.attributedTitle = AttributedString("已移除", attributes: self.pairButtonContainer)
            self.mainButton.configuration = config
        } else if status == .isFriend {
            self.mainButton.isHidden = false
            self.leftButton.isHidden = true
            self.rightButton.isHidden = true
            var config =  self.mainButton.configuration
            config?.attributedTitle = AttributedString("查看個人檔案", attributes: self.pairButtonContainer)
            self.mainButton.configuration = config
        } else if status == .requestNeedRespond {
            self.mainButton.isHidden = true
            self.leftButton.isHidden = false
            self.rightButton.isHidden = false
            
        }
        

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.checkIsResponsed(request: self.userRequestInstance)
    }
    
    func checkIsResponsed(request : UserFriendRequest) {
        if request.isResponsed {
            self.leftButton.isHidden = true
            self.rightButton.isHidden = true
      //      let rect = buttonStackView.frame
        //    viewUserProfileButton.frame = rect
            mainButton.isHidden = false
        } else {
            self.leftButton.isHidden = false
            self.rightButton.isHidden = false
            mainButton.isHidden = true
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
        labelsSetup()
        buttonsSetup()
        gestureSetup()

       
    }
    
    
    func layoutSetup() {
        userImageView.backgroundColor = .secondaryBackgroundColor
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(sendTimeLabel)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
      
        contentView.addSubview(mainButton)
        
        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  20),
            
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant:  6),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:  -6),
            userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 1),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            
            sendTimeLabel.centerYAnchor.constraint(equalTo: rightButton.centerYAnchor),
            sendTimeLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            
            rightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rightButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant :  -10),
            rightButton.widthAnchor.constraint(equalToConstant: bounds.width * 0.3),
            
            leftButton.centerYAnchor.constraint(equalTo: rightButton.centerYAnchor),
            leftButton.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -4),
            leftButton.widthAnchor.constraint(equalTo: rightButton.widthAnchor),
            mainButton.centerYAnchor.constraint(equalTo: rightButton.centerYAnchor),
            mainButton.trailingAnchor.constraint(equalTo: rightButton.trailingAnchor),
            mainButton.leadingAnchor.constraint(equalTo: leftButton.leadingAnchor),
        ])
        self.userImageView.layoutIfNeeded()
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 2),
        ])
    }
    
    func labelsSetup() {
        self.userNameLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
        self.sendTimeLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote, weight: .regular)
        userNameLabel.textColor = .label
        sendTimeLabel.textColor = .secondaryLabelColor
    }
    
    func buttonsSetup() {
        var config = UIButton.Configuration.filled()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .body, weight: .medium))
        config.baseBackgroundColor = .secondaryBackgroundColor
        config.baseForegroundColor = .white
      

        config.titleAlignment = .center
        leftButton.configuration = config
        rightButton.configuration = config
        mainButton.configuration = config
        
        let pairButtonsInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        var leftConfig = leftButton.configuration
        let leftAttrString = AttributedString("接受", attributes:  pairButtonContainer    )
        leftConfig?.attributedTitle = leftAttrString
        leftConfig?.baseBackgroundColor = .tintOrange
        leftConfig?.contentInsets = pairButtonsInsets
        leftButton.configuration = leftConfig
        
        var rightConfig = rightButton.configuration
        let rightAttrString = AttributedString("拒絕", attributes:  pairButtonContainer    )
        rightConfig?.attributedTitle = rightAttrString
        rightConfig?.baseBackgroundColor = .secondaryBackgroundColor
        rightConfig?.contentInsets = pairButtonsInsets
        rightButton.configuration = rightConfig
        
        var showUserProfileConfig = mainButton.configuration
        let showUserProfileAttrString = AttributedString("查看個人檔案", attributes:  pairButtonContainer    )
        showUserProfileConfig?.attributedTitle = showUserProfileAttrString
        showUserProfileConfig?.contentInsets = NSDirectionalEdgeInsets(top: 8,  leading: 20, bottom: 9, trailing: 20)
        showUserProfileConfig?.baseBackgroundColor = .secondaryLabelColor
        mainButton.configuration = showUserProfileConfig
        leftButton.addTarget(self, action: #selector(leftButtonTapped( _ :)), for: .touchUpInside)
        
        rightButton.addTarget(self, action: #selector(rightButtonTapped(_:)), for: .touchUpInside)
        
        mainButton.addTarget(self, action: #selector(segueToUserProfileView), for: .touchUpInside)
    }
    
    
    func gestureSetup() {
        [self.userImageView, self.userNameLabel].forEach { view in
            let gesture = UITapGestureRecognizer(target: self, action: #selector(segueToUserProfileView ))
            view?.addGestureRecognizer(gesture)
            view?.isUserInteractionEnabled = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func leftButtonTapped(_ button: UIButton) {
        Task {
            guard let user_id = self.userRequestInstance.user?.user_id else {
                print("error ID錯誤")
                return
            }
            await self.acceptRequestToCreateFriendShip(accept_user_id: Constant.user_id, to_user_id: user_id)
        }
    }
    
    @objc func rightButtonTapped( _ button : UIButton) {
        Task {
            guard let user_id = self.userRequestInstance.user?.user_id else {
                print("error ID錯誤")
                return
            }
            await self.cacelFriendRequest(cacel_user_id: Constant.user_id, to_user_id: user_id)
        }
    }
    
    func cacelFriendRequest(cacel_user_id : Int, to_user_id : Int) async {
        do {
            try await FriendManager.shared.cancelFriendRequest(from: cacel_user_id, to: to_user_id)
            self.userRequestInstance.friendStatus = .notFriend
            self.configure(userRequest: userRequestInstance )
        } catch {
            
        }
    }
    
    func acceptRequestToCreateFriendShip(accept_user_id :Int , to_user_id : Int) async  {
        do {
           try await FriendManager.shared.acceptFriendRequestByEachUserID(accept_user_id: accept_user_id, sentReqeust_user_id: to_user_id)
            self.userRequestInstance.friendStatus = .isFriend
            self.configure(userRequest: userRequestInstance )
        } catch {
            print("error", error.localizedDescription)
        }
    }
    
    
    
    
    
}
