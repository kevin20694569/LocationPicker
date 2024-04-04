import UIKit

class ChatRoomTableCell: UITableViewCell {
    
    var chatroomInstance : ChatRoom!
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var lastMessageLabel : UILabel!
    @IBOutlet weak var lastMessageTimeLabel : UILabel!
    @IBOutlet weak var roomImageView: UIImageView! { didSet {
        roomImageView?.layer.contentsGravity = .resizeAspectFill
        roomImageView?.layer.cornerRadius = (roomImageView?.frame.height)! / 2
        
    }}
    
    func configure(chatroom : ChatRoom) {
        self.chatroomInstance = chatroom
        self.nameLabel.text = chatroom.room_name
        self.lastMessageLabel.text = chatroom.lastMessage
        self.lastMessageTimeLabel.text = chatroom.lastTimeStamp?.timeAgoFromString()

        lastMessageLabel.textColor = chatroom.isRead ?? false ? .secondaryLabelColor : .label
        lastMessageLabel.font =  .weightSystemSizeFont(systemFontStyle: .callout , weight: chatroom.isRead ?? false ? .thin : .bold )
        Task {
            if let image = chatroom.user?.image {
                roomImageView?.image = image
            } else {
                if let imageURL = chatroom.user?.imageURL {
                    let image = await imageURL.getImageFromImageURL()
                    chatroom.user?.image = image
                    roomImageView?.image = image
                }
            }
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.lastMessageTimeLabel.text = ""
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layout()
    }
    
    func layout() {
        nameLabel.textColor = .label
        nameLabel.font = .weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)

      //  lastMessageLabel.font = .weightSystemSizeFont(systemFontStyle: .callout, weight: .regular)
        lastMessageTimeLabel.font = .weightSystemSizeFont(systemFontStyle: .footnote, weight: .regular)
        lastMessageTimeLabel.textColor = .secondaryLabelColor
    }
    
}
