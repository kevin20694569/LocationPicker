
import UIKit

class RhsMessageSharedUserCell : RhsMessageTableViewCell, MessageSharedUserCell {

    
    var showSharedUserProfileGesture: UITapGestureRecognizer! = UITapGestureRecognizer()
    
    var sharedUserImageView: UIImageView! = UIImageView()
    
    var userNameLabel: UILabel! = UILabel()
    
    var sharedUser : User!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSharedUserSubviews()
        setGesture()
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        
        self.sharedUser = message.sharedUser
        self.userNameLabel.text = message.sharedUser?.name
        self.sharedUserImageView.image = nil
        if let snapshotImage = message.snapshotImage {
            self.sharedUserImageView.image = snapshotImage
        } else {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                if let image = try? await message.snapshotImageURL?.getImageFromURL() {
                    message.snapshotImage = image
                    if let urlstring = self.sharedUser.imageURL  {
                        if message.snapshotImageURL == urlstring {
                            self.sharedUserImageView.image = image
                        }
                    }
                   
                }
            }
        }
    }
    
    override func setGesture() {
        showSharedUserProfileGesture.addTarget(self, action: #selector(showUserProfile ( _ : )))
        self.mainView.addGestureRecognizer(showSharedUserProfileGesture)
        mainView.isUserInteractionEnabled = true
    }
    
    @objc func showUserProfile( _ gesture : UITapGestureRecognizer) {
        guard let user = sharedUser else {
            return
        }
     
        self.messageTableCellDelegate?.showUserProfile(user_id: user.id, user: user) 
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.sharedUserImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func layoutSharedUserSubviews() {
        let bounds = UIScreen.main.bounds
        userNameLabel.textColor = .label
        userNameLabel.font = .weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)
        self.contentView.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.numberOfLines = 0
        sharedUserImageView.contentMode = .scaleAspectFill
        sharedUserImageView.layer.cornerRadius = 8
        sharedUserImageView.clipsToBounds = true
        sharedUserImageView.backgroundColor = .secondaryLabelColor
        
        self.mainView.addSubview(sharedUserImageView)
        sharedUserImageView.translatesAutoresizingMaskIntoConstraints = false
        let labelHorOffset : CGFloat = 10
        let labelVerOffset : CGFloat = 8
        NSLayoutConstraint.activate([
            sharedUserImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: labelVerOffset),
            sharedUserImageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),
            sharedUserImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            sharedUserImageView.trailingAnchor.constraint(equalTo: userNameLabel.leadingAnchor, constant: -labelHorOffset),
            

            
            sharedUserImageView.heightAnchor.constraint(equalToConstant: bounds.height * 0.05),
            sharedUserImageView.widthAnchor.constraint(equalTo: sharedUserImageView.heightAnchor, multiplier: 1),

            userNameLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),

            
        ])
    }
    
    
    
}

class LhsMessageSharedUserCell : LhsMessageTableViewCell, MessageSharedUserCell {
 //   var showUserProfileGesture: UITapGestureRecognizer!
    
    var sharedUserImageView: UIImageView! = UIImageView()
    
    var userNameLabel: UILabel! = UILabel()
    
    var sharedUser : User!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSharedUserSubviews()
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        
        self.sharedUser = message.sharedUser
        self.userNameLabel.text = message.sharedUser?.name
        self.sharedUserImageView.image = nil
        if let snapshotImage = message.snapshotImage {
            self.sharedUserImageView.image = snapshotImage
        } else {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                if let image = try? await message.snapshotImageURL?.getImageFromURL() {
                    message.snapshotImage = image
                    if let url = self.sharedUser.imageURL {
                        if message.snapshotImageURL == url {
                            self.sharedUserImageView.image = image
                        }
                    }
                    
                }
            }
        }
    }
    
    override func setGesture() {
        super.setGesture()
        showSharedUserProfileGesture.addTarget(self, action: #selector(showUserProfile ( _ : )))
        self.mainView.addGestureRecognizer(showSharedUserProfileGesture)
        mainView.isUserInteractionEnabled = true
    }
    
    @objc func showUserProfile( _ gesture : UITapGestureRecognizer) {
        guard let user = sharedUser else {
            return
        }
     
        self.messageTableCellDelegate?.showUserProfile(user_id: user.id, user: user)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.sharedUserImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func layoutSharedUserSubviews() {
        let bounds = UIScreen.main.bounds
        userNameLabel.textColor = .label
        userNameLabel.font = .weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)
        self.contentView.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.numberOfLines = 0
        sharedUserImageView.contentMode = .scaleAspectFill
        sharedUserImageView.layer.cornerRadius = 8
        sharedUserImageView.clipsToBounds = true
        sharedUserImageView.backgroundColor = .secondaryLabelColor
        
        self.mainView.addSubview(sharedUserImageView)
        sharedUserImageView.translatesAutoresizingMaskIntoConstraints = false
        let labelHorOffset : CGFloat = 10
        let labelVerOffset : CGFloat = 8
        
        
        NSLayoutConstraint.activate([
            sharedUserImageView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: labelVerOffset),
            sharedUserImageView.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: -labelVerOffset),
            sharedUserImageView.leadingAnchor.constraint(equalTo: self.mainView.leadingAnchor, constant: labelHorOffset),
            sharedUserImageView.trailingAnchor.constraint(equalTo: userNameLabel.leadingAnchor, constant: -labelHorOffset),
            sharedUserImageView.heightAnchor.constraint(equalToConstant: bounds.height * 0.05),
            sharedUserImageView.widthAnchor.constraint(equalTo: sharedUserImageView.heightAnchor, multiplier: 1),
            
            userNameLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: self.mainView.trailingAnchor, constant: -labelHorOffset),
            
            
        ])
    }
}
    


