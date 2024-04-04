import UIKit

class ProfileMainCell: UICollectionViewCell, UIViewControllerTransitioningDelegate {
    
    var mainView : UIView! = UIView() { didSet {

        mainView.backgroundColor = .secondaryBackgroundColor
    }}
    
    weak var delegate : ProfileMainCellDelegate?
    
    var userImageView : UIImageView! = UIImageView()  { didSet {
        userImageView.layer.cornerRadius = 8.0
        userImageView.contentMode = .scaleAspectFit
    }}
    
    var leftButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var shareButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    let profileDetailButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
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
    
    var user : User!
    
    var countStackViews : [(title : String , stackView :  UIStackView, label : UILabel)]! {
        return [("貼文", postCountStackView, postCountLabel) , ("朋友", friendCountStackView, friendCountLabel), ("清單", playlistCountStackView, playlistCountLabel)]
    }
    
    func setGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showFriendsViewController ( _: )))
        friendCountStackView.isUserInteractionEnabled = true
        self.friendCountStackView.addGestureRecognizer(gesture)
    }
    
    @objc func showFriendsViewController( _ gesture : UITapGestureRecognizer) {
        let controller = FriendViewController(presentForTabBarLessView: self.delegate?.presentForTabBarLessView ?? false, user: self.user)
        delegate?.show(controller, sender: nil)
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainView.backgroundColor = .secondaryBackgroundColor
        self.contentView.backgroundColor = .backgroundPrimary
        layoutButtons()
        layoutDetailStackView()
        layout()
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

    }
    
    @objc func leftButtonTapped(_ sender : UIView) {
        Task {
            await sendFriendRequest(to:   self.user.user_id)
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
        let controller = ShareUserController(user: user)
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        self.delegate?.present(controller, animated: true)
    }
    
    func sendFriendRequest(to to_user_id : Int) async {
        do {
            try await FriendsManager.shared.sendFriendRequest(from: Constant.user_id, to: to_user_id)
        } catch {
            print(error)
        }
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

        
        self.mainView.translatesAutoresizingMaskIntoConstraints = false
        self.userImageView.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
         NSLayoutConstraint.activate([
             mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
             mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
             mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
             mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
             userImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12),
             userImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 24),
             userImageView.trailingAnchor.constraint(equalTo: detailStackView.leadingAnchor, constant: -24),
             userImageView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.48),
             userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 1),
             detailStackView.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
             detailStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -24),
             
             
             leftButton.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 16 ),
             leftButton.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),

             leftButton.trailingAnchor.constraint(equalTo: mainView.centerXAnchor, constant: -8),
             leftButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -12),
             
             buttonStackView.centerYAnchor.constraint(equalTo: leftButton.centerYAnchor),
             
             buttonStackView.leadingAnchor.constraint(equalTo: mainView.centerXAnchor, constant: 8),
             buttonStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),

             
         ])
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
    }
    
    func configureBasic(user : User ) {
        self.user = user
        if let userImage = user.image {
            userImageView.image = userImage
        } else {
            if let imageURL = user.imageURL {
                Task {
                  
                    let image = await imageURL.getImageFromImageURL()
                    self.user.image = image
                    userImageView.image = image
                }
            }
        }
        if let friends_count = user.friends_count {
            self.friendCountLabel.text = String(friends_count)
        }
        if let posts_count = user.posts_count {
            self.postCountLabel.text = String(posts_count)
        }
    
        updateLeftButton()
        
    }
    
    func updateLeftButton() {
        let user = self.user!
        if var leftConfig = leftButton.configuration {
            let arrtri = AttributedString( user.userProfileStatus.mainButtonTitle, attributes: AttributeContainer([
                .font : UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .bold),
            ]))

            leftConfig.baseBackgroundColor = user.userProfileStatus.mainColor
            leftConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout, weight: .bold))
            leftConfig.image = user.userProfileStatus.mainImage
            leftConfig.attributedTitle = arrtri
            self.leftButton.configuration = leftConfig
        }
    }
    
    

}
