import UIKit
let MainViewTopBottomAnchor : CGFloat = 8
let MainViewHorAnchorConstant : CGFloat = 12

class MessageTableViewCell: UITableViewCell, MessageTableCellProtocol {
    var mainViewCornerRadius : CGFloat! = 16

    
    var MainViewTopBottomAnchor : CGFloat {
        return 8
    }
    
    var MainViewHorAnchorConstant : CGFloat {
        return 12
    }
    
    var warningLabel : UILabel! = UILabel()

    var messageInstance : Message!
    
    var mainView : UIView! = UIView()
    
    weak var messageTableCellDelegate :  MessageTableCellDelegate?
    
    var mainViewTouchGesture : UITapGestureRecognizer!
    
    func configure(message : Message) {
        
        self.messageInstance = message
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initLayout()
        setGesture()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showUserProfileViewController(user_id : String, user : User?) {
        messageTableCellDelegate?.showUserProfile(user_id: user_id, user: user)
    }
    
    func showWholePageMediaViewController(post_id : String) {
        messageTableCellDelegate?.showWholePageMediaViewController(post_id: post_id)
    }
    
    func showRestaurantDetailViewController(restaurant_id : String, restaurant : Restaurant) {
        messageTableCellDelegate?.showRestaurantDetailViewController(restaurant_id: restaurant_id, restaurant: restaurant)
    }
    
    func initLayout() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.backgroundColor = .secondaryBackgroundColor
        self.contentView.addSubview(mainView)
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = mainViewCornerRadius
    }
    
    
   
    
    @objc func mainViewTapped( ) {
        
    }
    
    
    func setGesture() {
        mainViewTouchGesture = UITapGestureRecognizer(target: self, action: #selector(mainViewTapped))
        mainView.isUserInteractionEnabled = true
        self.mainView.addGestureRecognizer(mainViewTouchGesture)

    }
    

}

class RhsMessageTableViewCell : MessageTableViewCell {
    
    var sentSuccessActivityView : UIActivityIndicatorView! = UIActivityIndicatorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initActivityView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initLayout() {
        super.initLayout()
        
        contentView.addSubview(sentSuccessActivityView)
        sentSuccessActivityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 80),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -MainViewTopBottomAnchor * 2),
            
            sentSuccessActivityView.trailingAnchor.constraint(equalTo: mainView.leadingAnchor, constant : -4),
            sentSuccessActivityView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -4),
            
        ])
    }
    
    func initActivityView() {
       // sentSuccessActivityView.backgroundColor = .red
       // sentSuccessActivityView.
       
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        if !message.successSent {
            sentSuccessActivityView.isHidden = false
            sentSuccessActivityView.startAnimating()
        } else {
            sentSuccessActivityView.isHidden = true
            sentSuccessActivityView.stopAnimating()
        }
    }
    

}

class LhsMessageTableViewCell : MessageTableViewCell {
    
    var userImageView : UIImageView! = UIImageView()

    override func configure(message: Message) {
        super.configure(message: message)
        if let image = message.userImage {
            self.userImageView.image = image
        } else {
            if let url = message.senderUser?.imageURL {
                Task {
                    if let image = try? await url.getImageFromURL() {
                        message.userImage = image
                        self.userImageView.image = image
                    }
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setGesture()

    }
    


    
    override func initLayout() {
        super.initLayout()
        layoutImageView()
        NSLayoutConstraint.activate([
            mainView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -80),
            mainView.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: MainViewHorAnchorConstant),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -MainViewTopBottomAnchor * 2),
        ])
    }
    
    func layoutImageView() {
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .secondaryBackgroundColor
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(userImageView)
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: MainViewHorAnchorConstant),
            userImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.09),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor, multiplier: 1),
            
        ])
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        userImageView.layer.cornerRadius = self.userImageView.bounds.height / 2
    }
    
    func hiddenSenderUserImageView(_ bool : Bool) {
        self.userImageView.isHidden = bool
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





class RhsTextViewMessageTableViewCell : RhsMessageTableViewCell, MessageTextViewCell {
    
    
    
    var messageTextView : UITextView! = UITextView()

    override func configure(message : Message) {
        super.configure(message: message)
        self.messageTextView.text = message.message
    }
    
    func layoutMessageTextView() {
        messageTextView.isEditable = false
        messageTextView.adjustsFontForContentSizeCategory = true
        messageTextView.backgroundColor = .clear
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .regular)
        messageTextView.textColor = .label
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(messageTextView)
        
        let offset : CGFloat = 6
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: offset),
            messageTextView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -offset),
            messageTextView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: offset / 2),
            messageTextView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -offset / 2),
        ])
    }
    
    override func initLayout() {
        super.initLayout()
        layoutMessageTextView()
        
    }
    
    
}



class LhsTextViewMessageTableViewCell: LhsMessageTableViewCell , MessageTextViewCell {
    
    var messageTextView : UITextView! = UITextView()
    
    
    
    override func configure(message: Message) {
        super.configure(message: message)
        self.messageTextView.text = message.message
    }
    
    func layoutMessageTextView() {
        messageTextView.isEditable = false
        messageTextView.adjustsFontForContentSizeCategory = true
        messageTextView.backgroundColor = .clear
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .regular)
        messageTextView.textColor = .label
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(messageTextView)
        
        let offset : CGFloat = 6
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: offset),
            messageTextView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -offset),
            messageTextView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: offset / 2),
            messageTextView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -offset / 2),
        ])
    }
    
    override func initLayout() {
        super.initLayout()
        layoutMessageTextView()
        

    }
    

}
