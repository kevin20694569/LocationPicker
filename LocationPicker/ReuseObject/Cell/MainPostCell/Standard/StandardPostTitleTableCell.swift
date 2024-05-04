
import UIKit
class StandardPostTitleTableCell : StandardPostTableCell {

    var postTitleLabel : UILabel! = UILabel()
    
    override var timeStampTopAnchor : NSLayoutConstraint!  {
        timeStampLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: timeStampVerConstant)
    }
    
    override func configureData(post: Post) {
        super.configureData(post: post)
        if let title = currentPost.postTitle {
            self.postTitleLabel.text = title
        }
    }
    
    override func viewLayoutSetup() {
        self.contentView.addSubview(postTitleLabel)
        postTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        super.viewLayoutSetup()

        NSLayoutConstraint.activate([
            postTitleLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: postTitleLabelTopConstant),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: textLabelHorConstant),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -textLabelHorConstant),
        ])
    }
    
    override func labelSetup() {
        super.labelSetup()
        postTitleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
        postTitleLabel.textColor = .label
    }
}


class StandardPostContentTableCell : StandardPostTableCell {
    var postsContentLabelHeightAnchor : NSLayoutConstraint!

    var postContentLabel : UILabel! = UILabel()
    
    
    var postContentTopAnchor : NSLayoutConstraint!  {
        postContentLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 6)
       
    }
    
    override var timeStampTopAnchor : NSLayoutConstraint!  {
        timeStampLabel.topAnchor.constraint(equalTo: postContentLabel.bottomAnchor, constant: timeStampVerConstant)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        postsContentLabelHeightAnchor = self.postContentLabel?.heightAnchor.constraint(equalToConstant: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewLayoutSetup() {
        self.contentView.addSubview(postContentLabel)
        postContentLabel.translatesAutoresizingMaskIntoConstraints = false
        super.viewLayoutSetup()

        NSLayoutConstraint.activate([
            postContentTopAnchor,
            postContentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: textLabelHorConstant),
            postContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -textLabelHorConstant),
        ])
    }
    
    override func configureData(post: Post) {
        super.configureData(post: post)

        if let content = currentPost.postContent {
            self.postContentLabel.text = content
        }
    }
    
    override func labelSetup() {
        super.labelSetup()
        postContentLabel.numberOfLines = 3
        postContentLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .regular)
        postContentLabel.isUserInteractionEnabled = true
        postContentLabel.contentMode = .topLeft 
    }
    
    override func setGestureTarget() {
        super.setGestureTarget()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(postsContentExpand))
        postContentLabel.addGestureRecognizer(gesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postContentLabel?.numberOfLines = 3
        postContentLabel?.frame.size.height = 0
        postsContentLabelHeightAnchor.isActive = false
        contentView.layoutIfNeeded()
        self.standardPostCellDelegate?.cellRowHeightSizeFit()
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
        if (self.contentView.frame.height - postContentLabel.frame.height + actualSize.height) > standardPostCellDelegate?.tableView.frame.height ?? 0  {

            return
        }
        NSLayoutConstraint.activate([
            postsContentLabelHeightAnchor
        ])
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations:  { [self] in
            postsContentLabelHeightAnchor.constant = actualSize.height
            contentView.layoutIfNeeded()
            self.standardPostCellDelegate?.cellRowHeightSizeFit()
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
    }
    

    
}

class StandardPostAllTextTableCell : StandardPostContentTableCell {
    var postTitleLabel : UILabel! = UILabel()
    
    override var postContentTopAnchor : NSLayoutConstraint!  {
        postContentLabel.topAnchor.constraint(equalTo: postTitleLabel.bottomAnchor, constant: 6)
    }
    
    override var timeStampTopAnchor : NSLayoutConstraint!  {
        timeStampLabel.topAnchor.constraint(equalTo: postContentLabel.bottomAnchor, constant: timeStampVerConstant)
    }
    
    override func viewLayoutSetup() {
        self.contentView.addSubview(postTitleLabel)
        postTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        super.viewLayoutSetup()
        

        NSLayoutConstraint.activate([
            postTitleLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: postTitleLabelTopConstant),
            postTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: textLabelHorConstant),
            postTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: textLabelHorConstant),

        ])
    }
    
    override func labelSetup() {
        super.labelSetup()
        postTitleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
        postTitleLabel.textColor = .label
    }
    
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
