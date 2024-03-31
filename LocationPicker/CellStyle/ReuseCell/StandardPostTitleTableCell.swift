
import UIKit
class StandardPostTitleTableCell : StandardPostTableCell {

    @IBOutlet weak var postTitleLabel : UILabel! { didSet {
        postTitleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
    }}
    override func configureData(post: Post) {
        super.configureData(post: post)
        if let title = currentPost.postTitle {
            self.postTitleLabel.text = title

        }
    }
}


class StandardPostContentTableCell : StandardPostTableCell {
    var postsContentLabelHeightAnchor : NSLayoutConstraint!

    @IBOutlet weak var postContentLabel : UILabel! { didSet {
        postContentLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .regular)
        postContentLabel!.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(postsContentExpand))
        postContentLabel!.addGestureRecognizer(gesture)
    }}
    var postContentLabelBottomAnchor : NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        postContentLabel?.numberOfLines = 3
        postsContentLabelHeightAnchor = self.postContentLabel?.heightAnchor.constraint(equalToConstant: 0)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postContentLabel?.numberOfLines = 3
        postContentLabel?.frame.size.height = 0
        postsContentLabelHeightAnchor.isActive = false
        contentView.layoutIfNeeded()
        self.standardPostCellDelegate.cellRowHeightSizeFit()
    }
    @objc func postsContentExpand() {
        guard let postContentLabel = postContentLabel else {
            return
        }
        postContentLabel.numberOfLines = 0
        
        let maxSize = CGSize(width: postContentLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
        
        let actualSize = postContentLabel.sizeThatFits(maxSize)
        if postContentLabel.frame.height == actualSize.height {
            return
        }
        if (self.contentView.frame.height - postContentLabel.frame.height + actualSize.height) > standardPostCellDelegate.tableView.frame.height  {

            return
        }
        NSLayoutConstraint.activate([
            postsContentLabelHeightAnchor
        ])
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations:  { [self] in
            postsContentLabelHeightAnchor.constant = actualSize.height
            contentView.layoutIfNeeded()
            self.standardPostCellDelegate.cellRowHeightSizeFit()
        })
    }
    
    func expandLabel() {
        // 计算文字的高度
        guard let postContentLabel = postContentLabel else {
            return
        }
        let maxSize = CGSize(width: postContentLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = postContentLabel.sizeThatFits(maxSize)
        
        // 更新UILabel的高度
        postContentLabel.frame.size = actualSize
        
        // 创建新的UILabel显示剩余的文字
        let remainingLabel = UILabel(frame: CGRect(x: postContentLabel.frame.origin.x,
                                                   y: postContentLabel.frame.origin.y + postContentLabel.frame.height,
                                                   width: postContentLabel.frame.width,
                                                   height: actualSize.height))
        remainingLabel.text = postContentLabel.text
        remainingLabel.textColor = postContentLabel.textColor
        remainingLabel.font = postContentLabel.font
        remainingLabel.numberOfLines = 0
        self.postContentLabel = remainingLabel
        // 将新的UILabel添加到父视图中
        // contentView.addSubview(remainingLabel)
    }
    
    override func configureData(post: Post) {
        super.configureData(post: post)

        if let content = currentPost.postContent {
            self.postContentLabel.text = content
        }
    }
    
}

class StandardPostAllTextTableCell : StandardPostContentTableCell {
    @IBOutlet weak var postTitleLabel : UILabel! { didSet {
        postTitleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
    }}
    override func configureData(post: Post) {
        super.configureData(post: post)
        if let title = currentPost.postTitle {
            self.postTitleLabel.text = title

        }
        if let content = currentPost.postContent {
            self.postContentLabel.text = content
        }
    }
}
