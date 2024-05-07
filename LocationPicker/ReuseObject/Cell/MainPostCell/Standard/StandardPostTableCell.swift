import UIKit
import AVFoundation

class StandardPostTableCell : MainPostTableCell , StandardEmojiReactionObject, StandardPostTableCellProtocol {
    
    deinit {
        self.currentPost.media.forEach() {
           $0.player?.seek(to: CMTime.zero)
       }
    }
    
    var textLabelHorConstant : CGFloat! = 20
    
    var timeStampVerConstant : CGFloat! = 12
    
    var postTitleLabelTopConstant : CGFloat! = 10
    
    var timeStampTopAnchor : NSLayoutConstraint!  {
        timeStampLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: timeStampVerConstant)
    }

    var collectionViewHeight : CGFloat! = Constant.standardMinimumTableCellCollectionViewHeight
    
    weak var standardPostCellDelegate : StandardPostCellDelegate?
    
    var emojiButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var userNameLabel : UILabel! = UILabel()
    
    var settingButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var isEmojiViewAnimated : Bool! = false
    
    var extendedEmojiBlurView : UIVisualEffectView?
    
    
    override func getEmojiButtonConfig(image : UIImage) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.background.image = image
        config.background.imageContentMode = .scaleAspectFit
        config.contentInsets = NSDirectionalEdgeInsets.zero
        return config
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        emojiReactionsStackView?.isHidden = true
        buttonSetup()
        
    }

    override func configureData(post : Post) {
        currentPost = post
        self.collectionView.reloadSections([0])
        self.currentEmojiTag = post.selfReaction?.reactionType?.reactionTag
        self.updateEmojiButtonImage(targetTag: post.selfReaction?.reactionType?.reactionTag)
        setHeartButtonStatus()
        updateCellPageControll(currentCollectionIndexPath: IndexPath(row: post.CurrentIndex, section: self.currentMediaIndexPath.section))

        if let userImage = currentPost.user?.image {
            userImageView?.image = userImage
        } else {
            Task {
                let userImage = try await currentPost.user?.imageURL?.getImageFromURL()
                currentPost.user?.image = userImage
                userImageView?.image = userImage
            }
        }
        pageControll?.numberOfPages = post.media.count
        timeStampLabel.text = post.timestamp?.timeAgeFromStringOrDateString()
        userNameLabel.text = post.user?.name
        if let grade = post.grade {
            gradeStackView.isHidden = false
            self.gradeLabel?.text = String(grade)
        } else {
            gradeStackView.isHidden = true
        }
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.currentMediaIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func registerCollectionCell() {
        super.registerCollectionCell()
        self.collectionView.register(StandardImageViewCollectionCell.self, forCellWithReuseIdentifier: "StandardImageViewCollectionCell")
        self.collectionView.register(StandardPlayerLayerCollectionCell.self, forCellWithReuseIdentifier: "StandardPlayerLayerCollectionCell")
    }
    
    override func buttonSetup() {
        super.buttonSetup()
        let screenBounds = UIScreen.main.bounds
        var heartConfig = UIButton.Configuration.filled()
        heartConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        heartConfig.image = UIImage(systemName: "heart")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        heartConfig.baseForegroundColor = .label
        heartConfig.baseBackgroundColor = .clear
        
        heartButton.configuration = heartConfig
        
        var emojiConfig = UIButton.Configuration.filled()
       
        emojiConfig.background.image = UIImage(systemName: "smiley")?.scale(newWidth: screenBounds.width * 0.08).withTintColor(.label, renderingMode: .alwaysOriginal)
        emojiConfig.background.imageContentMode = .scaleAspectFit
        emojiConfig.baseForegroundColor = .label
    
        emojiConfig.baseBackgroundColor = .clear

        emojiButton.configuration = emojiConfig
        emojiButton.tag = -1
        
        
        
        var settingConfig = UIButton.Configuration.filled()
       
        settingConfig.background.image = UIImage(systemName: "ellipsis")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        settingConfig.background.imageContentMode = .scaleAspectFit
        settingConfig.baseBackgroundColor = .clear

        settingButton.configuration = settingConfig
        settingButton.isHidden = true
        
    }
    
    override func labelSetup() {
        super.labelSetup()
        timeStampLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote, weight: .medium)
        timeStampLabel.textColor = .secondaryLabelColor
        userNameLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .subheadline, weight: .medium)
        userNameLabel.textColor = .label
        
    }

    override func setGestureTarget() {
        super.setGestureTarget()
        
        self.emojiButton.addTarget(self, action: #selector(emojiButtonTapped( _ : )), for: .touchUpInside)
        for (index, button) in emojiTargetButtons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(emojiTargetTapped(_ : )), for: .touchUpInside)
        }
        settingButton.addTarget(self, action: #selector(presentEditPostOptionViewController (_ : )), for: .touchUpInside)

        let userNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_ :)))
        self.userNameLabel.addGestureRecognizer(userNameLabelGesture)

        userNameLabel.isUserInteractionEnabled = true
    }
    
    @objc func presentEditPostOptionViewController(_ button : UIButton) {
        let controller = EditPostOptionViewController(post: currentPost)
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.postTableViewController = self.standardPostCellDelegate
        controller.tableViewCell = self
        self.standardPostCellDelegate?.present(controller, animated: true)
    }
    
    func refreshData() async {
        do {
            let post = try await PostManager.shared.getPostDetail(post_id: self.currentPost.id, request_user_id: Constant.user_id)
            self.configureData(post: post)
        } catch {
            print(error)
        }
    }
    
    override func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let bounds = UIScreen.main.bounds
        
        let maxWidth = bounds.width - 16
        var maxHeight : CGFloat! = bounds.height * 0.5

        if presented is EditPostOptionViewController {
            maxHeight =  bounds.height * 0.3
            self.mediaTableCellDelegate?.pauseCurrentMedia()
            return MaxFramePresentedViewPresentationController(presentedViewController: presented, presenting: presenting, maxWidth: maxWidth, maxHeight: maxHeight)
        }
        return super.presentationController(forPresented: presented, presenting: presenting, source: source)
    }
    
    override func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self.standardPostCellDelegate?.gestureStatusToggle(isTopViewController: true)
        return super.animationController(forDismissed: dismissed)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.currentPost.media[indexPath.row]
        if media.isImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardImageViewCollectionCell", for: indexPath) as! StandardImageViewCollectionCell
            cell.configure(media: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardPlayerLayerCollectionCell", for: indexPath) as! StandardPlayerLayerCollectionCell
            cell.configure(media: media)
            return cell
        }
    }
    
    override func updateEmojiButtonImage(targetTag : Int?) {
        if let targetTag = targetTag {
            let image = self.emojiTargetButtons[targetTag].configuration?.background.image
            self.emojiButton.configuration?.background.image = image
        } else {
            self.emojiButton.configuration?.background.image = UIImage(systemName: "smiley")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        }
    }

    
    
    override func collectionViewFlowSetup() {
       DispatchQueue.main.async { [self] in
            let flow = UICollectionViewFlowLayout()
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            flow.itemSize = CGSize(width: width , height: height )
            flow.minimumLineSpacing = 0
            flow.minimumInteritemSpacing = 0
            flow.scrollDirection = .horizontal
            collectionView.collectionViewLayout = flow
        }
    }
    
    override func setHeartButtonStatus() {
        
        self.heartButton.configuration?.image =  currentPost.liked ? UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal) :  UIImage(systemName: "heart")?.withTintColor(.label, renderingMode: .alwaysOriginal)
    }

    
    @objc func emojiButtonTapped( _ button : UIButton) {
        if extendedEmojiBlurView == nil {
            startEmojiExtendAnimation()
        } else {
            startReactionTargetAnimation(targetTag: nil)
        }
    }
    
    @objc override func emojiTargetTapped(_ button: UIButton) {

        let tag = button.tag
        if self.currentPost.selfReaction?.reactionType?.reactionTag == tag {
            currentEmojiTag = nil
        } else {
            currentEmojiTag = tag
        }
        
        if canPostReaction {
            self.initNewReaction(reactionTag: currentEmojiTag, liked: currentPost.liked)
        }
        startReactionTargetAnimation(targetTag: currentEmojiTag)
    }
    

    
    
    func startEmojiExtendAnimation() {
        guard !isEmojiViewAnimated else {
            return
        }
        isEmojiViewAnimated = true
        let bounds = contentView.bounds
        let emojiButtonFrameInContentView = self.emojiButton.superview!.convert(self.emojiButton.frame, to: contentView)

        let frame = CGRect(origin: emojiButtonFrameInContentView.origin, size: CGSize(width: bounds.width * 0.8, height: emojiButtonFrameInContentView.height * 1.8))
        extendedEmojiBlurView = UIVisualEffectView(frame:  frame, style: .dark)
        
        let emojiButtonCenterInContentView = self.emojiButton.superview!.convert(self.emojiButton.center, to: contentView)
        guard let extendedEmojiBlurView = extendedEmojiBlurView else {
            return
        }
        extendedEmojiBlurView.translatesAutoresizingMaskIntoConstraints = true
        extendedEmojiBlurView.clipsToBounds = true
        self.contentView.addSubview(extendedEmojiBlurView)

        extendedEmojiBlurView.alpha = 0

        let blurViewWidth = bounds.width * 0.7
        
        let blurViewXOffset : CGFloat = 12
        let zoomInTransform = CGAffineTransform(scaleX: 1, y: 1)
        
        let zoomOutTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        let collectionViewFrame = self.collectionView.superview!.convert(collectionView.frame, to: contentView)
        let offset : CGFloat = 4
        let targetBlurFrame = CGRect(x: emojiButtonCenterInContentView.x, y: collectionViewFrame.maxY - extendedEmojiBlurView.frame.height - offset , width: blurViewWidth, height: extendedEmojiBlurView.frame.height)

        emojiTargetButtons.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = true
            $0.frame = emojiButtonFrameInContentView
            $0.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            $0.alpha = 0
            self.contentView.addSubview($0)
        }
        
        extendedEmojiBlurView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        extendedEmojiBlurView.center.x = emojiButtonCenterInContentView.x
        
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations:  {

            extendedEmojiBlurView.transform = .identity
            extendedEmojiBlurView.frame = targetBlurFrame
            extendedEmojiBlurView.layer.cornerRadius = 20
            self.emojiTargetButtons.forEach() {
                
                $0.transform = .identity
            }
            let tag = self.currentPost.selfReaction?.reactionType?.reactionTag
            let emojiTargetWidth =  (blurViewWidth - ( blurViewXOffset * 2 )) / 5
 
            self.emojiTargetButtons.forEach() {
                

                let x = targetBlurFrame.minX + blurViewXOffset + emojiTargetWidth * CGFloat($0.tag)
                $0.frame = CGRect(origin: .zero, size: CGSize(width: emojiTargetWidth, height: $0.frame.height))
                $0.center.y = targetBlurFrame.midY

                $0.frame.origin.x = x
                if tag != nil {

                    if tag == $0.tag {
                        
                        $0.transform = zoomInTransform
                        $0.alpha = 1
                    } else {
                        $0.transform = zoomOutTransform
                        $0.alpha = 0.5
                    }

                } else {
                    $0.alpha = 1
                }
            }
            extendedEmojiBlurView.alpha = 1
        }) { bool in
            self.isEmojiViewAnimated = false
            self.emojiButton.isUserInteractionEnabled = true
        }
    }
    
    
    
    override func startReactionTargetAnimation(targetTag : Int?) {
        guard !isEmojiViewAnimated else {
            return
        }
        guard let extendedEmojiView = extendedEmojiBlurView else {
            return
        }
        isEmojiViewAnimated = true
        self.emojiButton.isUserInteractionEnabled = false
        let frame = self.emojiButton.superview!.convert(emojiButton.frame, to: self.collectionView)
        let centerInFrame = self.emojiButton.superview!.convert(emojiButton.center, to: contentView)
        let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height * 0.8)
        if currentEmojiTag == nil {
            if targetTag != nil {
                self.emojiButton.alpha = 0
            }
            if emojiButton?.configuration?.background.image != UIImage(systemName: "smiley")?.withTintColor(.label, renderingMode: .alwaysOriginal) {
                self.updateEmojiButtonImage(targetTag: currentEmojiTag)
            }
        }
        let zoomOutTransForm = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations:  {

            self.emojiTargetButtons.forEach() {
                if let targetTag = targetTag {
                    self.emojiButton.alpha = 0
                    if $0.tag == targetTag {
                        $0.alpha = 1
                    } else {
                        $0.alpha = 0
                    }
                    $0.transform = .identity
                    $0.center = centerInFrame
                    return
                } else {
                    self.emojiButton.alpha = 1
                    $0.alpha = 0
                }
                $0.transform = zoomOutTransForm
                $0.center = centerInFrame
            }
            extendedEmojiView.frame = newFrame
            extendedEmojiView.center = centerInFrame
            extendedEmojiView.layer.cornerRadius = 6
            extendedEmojiView.transform = zoomOutTransForm
            extendedEmojiView.alpha = 1
        }) { bool in
            self.updateEmojiButtonImage(targetTag: self.currentEmojiTag)
            self.emojiButton.alpha = 1
            self.emojiTargetButtons.forEach() {
                $0.transform = .identity
                $0.removeFromSuperview()
            }
            self.extendedEmojiBlurView?.removeFromSuperview()
            self.extendedEmojiBlurView = nil
            self.emojiButton.isUserInteractionEnabled = true
            self.isEmojiViewAnimated = false
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.currentEmojiTag = nil
        self.emojiButton.configuration?.background.image = UIImage(systemName: "smiley")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        
        Task(priority: .low) { [weak self] in
            guard let self = self else {
                return
            }
            self.currentPost.media.forEach() {
               $0.player?.seek(to: CMTime.zero)
           }
        }
    }

    override func viewLayoutSetup() {
        
        contentView.addSubview(collectionView)
        contentView.addSubview(userImageView)
        contentView.addSubview(heartButton)
        contentView.addSubview(gradeStackView)
        contentView.addSubview(pageControll)
        contentView.addSubview(collectButton)
        contentView.addSubview(shareButton)
        contentView.addSubview(restaurantNameLabel)
        contentView.addSubview(distanceLabel)
        
        contentView.addSubview(emojiReactionsStackView)
        contentView.addSubview(timeStampLabel)
        contentView.addSubview(emojiButton)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(settingButton)
        
        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  16),
            userImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.08),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: gradeStackView.leadingAnchor, constant: -6),
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),

            gradeStackView.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            gradeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            pageControll.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            pageControll.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            pageControll.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControll.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.3),
            
            collectionView.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 6),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            
            shareButton.centerYAnchor.constraint(equalTo: pageControll  .centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            collectButton.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            collectButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -8),
            
            heartButton.centerYAnchor.constraint(equalTo: pageControll.centerYAnchor),
            
            heartButton.trailingAnchor.constraint(equalTo: collectButton.leadingAnchor, constant: -8),
            
            emojiButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.08),
            emojiButton.heightAnchor.constraint(equalTo: emojiButton.widthAnchor, multiplier: 1),
            emojiButton.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            emojiButton.centerYAnchor.constraint(equalTo: pageControll.centerYAnchor),
            
            timeStampTopAnchor,
            timeStampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor , constant: -timeStampVerConstant),
            timeStampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: textLabelHorConstant),
            
            settingButton.centerYAnchor.constraint(equalTo: timeStampLabel.centerYAnchor),
            settingButton.centerXAnchor.constraint(equalTo: shareButton.centerXAnchor),

            settingButton.widthAnchor.constraint(equalTo: shareButton.widthAnchor),
            settingButton.heightAnchor.constraint(equalTo: settingButton.widthAnchor, multiplier: 1)
        ])
        gradeStackView.layoutIfNeeded()
    }
}
