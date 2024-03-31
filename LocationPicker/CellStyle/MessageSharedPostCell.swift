import UIKit


class RhsMessageSharedPostCell : RhsMessageTableViewCell, MessageSharedPostCell {
    var showPostGesture: UITapGestureRecognizer! = UITapGestureRecognizer()
    
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
        self.restaurantNameLabel.text = message.restaurantJson?.restaurant_name
        self.postImageView.image = nil
       
        if let media = message.snapshotMedia {
            if let image = media.image {
                self.postImageView.image = image
            } else {
                Task { [self] in
                    let image = await Media.getSnapShot(media: media)
                    media.image = image
                    message.snapshotMedia = media
                    if media.DonwloadURL == URL(string : self.post.media!.first!.url) {
                        self.postImageView.image = image
                    }
                }
            }
        }
    }
    
    func setGesture() {
        showPostGesture.addTarget(self, action: #selector(showPost ( _ : )))
        self.mainView.addGestureRecognizer(showPostGesture)
        mainView.isUserInteractionEnabled = true
    }
    
    @objc func showPost( _ gesture : UITapGestureRecognizer) {
        self.messageTableCellDelegate?.showWholePageMediaViewController(cell: self)
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
    
    override func layoutImageView() {
        super.layoutImageView()
    }
    
    override func configure(message: Message) {
        super.configure(message: message)
        self.post = message.postJson
        self.restaurantNameLabel.text = message.restaurantJson?.restaurant_name
        self.postImageView.image = nil
        if let media = message.snapshotMedia {
            if let image = media.image {
                self.postImageView.image = image
            } else {
                Task {
                    let image = await Media.getSnapShot(media: media)
                    self.postImageView.image = image
                    media.image = image

                }
            }
        }
    }
    
    
    override func setGesture() {
        super.setGesture()
        showPostGesture.addTarget(self, action: #selector(showPost ( _ : )))
        self.mainView.addGestureRecognizer(showPostGesture)
        mainView.isUserInteractionEnabled = true
    }
    
    @objc func showPost( _ gesture : UITapGestureRecognizer) {
        self.messageTableCellDelegate?.showWholePageMediaViewController(cell: self)
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


