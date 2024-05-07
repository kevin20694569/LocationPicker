import UIKit
class PostDetailTextCell: UITableViewCell {
    
    @IBOutlet var mainTextLabel : UILabel!
    
    func configure(post : Post) {
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        labelSetup()
        self.backgroundColor = .clear
    }
    
    func labelSetup() {
        mainTextLabel.textColor = .white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

class PostTitleCell: PostDetailTextCell {
    override func labelSetup() {
        super.labelSetup()
        mainTextLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
    }
    

    
    override func configure(post: Post) {
        self.mainTextLabel.text = post.postTitle
    }
    
    
}

class PostContentCell: PostDetailTextCell {
    
    lazy var mainTextLabelHeightAnchor : NSLayoutConstraint! = self.mainTextLabel.heightAnchor.constraint(equalToConstant: 0)
    
    weak var postContentCellDelegate : ExtendLabelHeightTableCellDelegate?
    
    override var mainTextLabel: UILabel! { didSet {
        mainTextLabel.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(postsContentExpand))
        mainTextLabel.addGestureRecognizer(gesture)
    }}
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    override func configure(post: Post) {
        super.configure(post: post)
        self.mainTextLabel.text = post.postContent
    }
    
    override func labelSetup() {
        super.labelSetup()
        mainTextLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .regular)
    }
    
    @objc func postsContentExpand() {
        mainTextLabel.numberOfLines = 0
        
        let maxSize = CGSize(width: mainTextLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = mainTextLabel.sizeThatFits(maxSize)
        if mainTextLabel.frame.height == actualSize.height {
            return
        }
        NSLayoutConstraint.activate([
            mainTextLabelHeightAnchor
        ])
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations:  { [self] in
            mainTextLabelHeightAnchor.constant = actualSize.height
            
            contentView.layoutIfNeeded()
            self.postContentCellDelegate?.cellRowHeightSizeFit()
        })
    }
    
    
    
}





