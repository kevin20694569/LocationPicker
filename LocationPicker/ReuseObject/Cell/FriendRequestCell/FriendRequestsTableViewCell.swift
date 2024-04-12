import UIKit


class FriendRequestsTableViewCell : UITableViewCell  {
    
    
    var userRequestInstance : UserFriendRequest!
    
    weak var friendRequestsDelegate : FriendRequestsCellDelegate!
    
    @IBOutlet var userImageView: UIImageView! { didSet {
        userImageView.isUserInteractionEnabled = true
        userImageView.contentMode = .scaleAspectFit
        userImageView.layer.cornerRadius = 10.0
        userImageView.clipsToBounds = true
    }}
    @IBOutlet var userNameLabel : UILabel! { didSet {
        userNameLabel.isUserInteractionEnabled  = true
    }}
    

    
    @IBOutlet var sendTimeLabel : UILabel!
    
    @IBOutlet var acceptButton : UIButton! { didSet {
        acceptButton.isEnabled = true
        acceptButton.isUserInteractionEnabled = true
        acceptButton.addTarget(self, action: #selector(acceptRequest(_:)), for: .touchUpInside)
    }}
    
    @IBOutlet var ignoreButton : UIButton!
    @IBOutlet var buttonStackView : UIStackView!
    
    var viewUserProfileButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = true
        button.setTitle("查看個人檔案", for: .normal)
        button.tintColor = .secondaryLabelColor
        button.layer.cornerRadius = 10.0
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(segueToUserProfileView) , for: .touchUpInside)
        return button
    }()
    
    @objc func segueToUserProfileView() {
        friendRequestsDelegate.segueToUserProfileView(userRequst: self.userRequestInstance )
    }
    
    func configure(userRequest: UserFriendRequest)  {

        userRequestInstance = userRequest
        self.checkIsResponsed(request: userRequest)
        userNameLabel.text = userRequest.user?.name
        sendTimeLabel.text = userRequest.sent_time.timeAgoFromString()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.checkIsResponsed(request: self.userRequestInstance)
    }
    
    func checkIsResponsed(request : UserFriendRequest) {
        if request.isResponsed {
            self.acceptButton.isHidden = true
            self.ignoreButton.isHidden = true
            let rect = buttonStackView.frame
            viewUserProfileButton.frame = rect
            viewUserProfileButton.isHidden = false
        } else {
            self.acceptButton.isHidden = false
            self.ignoreButton.isHidden = false
            viewUserProfileButton.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [self.userImageView, self.userNameLabel].forEach { view in
            let gesture = UITapGestureRecognizer(target: self, action: #selector(segueToUserProfileView ))
            view?.addGestureRecognizer(gesture)
        }
        contentView.addSubview(self.viewUserProfileButton)
    }
    
    
    @objc func acceptRequest(_ button: UIButton) {
        Task {
            guard let user_id = self.userRequestInstance.user?.user_id,
                  let request_id = self.userRequestInstance.request_ID else {
                print("error ID錯誤")
                return
            }
            await self.acceptRequestToCreateFriendShip(request_id: request_id, accept_user_id: Constant.user_id)
        }
    }
    
    func acceptRequestToCreateFriendShip(request_id :Int , accept_user_id : Int) async  {
        do {
            let statusCode = try await FriendManager.shared.acceptFriendRequestFromRequestID(request_id: request_id, accept_user_id: accept_user_id)
            if 200...299 ~= statusCode {
                self.userRequestInstance.isResponsed = true
                checkIsResponsed(request: self.userRequestInstance)
            } else {
                throw FriendsAPIError.acceptFriendRequestError
            }
        } catch {
            print("error", error.localizedDescription)
        }
    }
    
    
    
    
    
}

