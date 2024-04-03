import UIKit
import AVFoundation

class StandardPostTableCell : MainPostTableCell , StandardEmojiReactionObject, StandardPostTableCellProtocol {
    
    deinit {
        self.currentPost.media.forEach() {
           $0.player?.seek(to: CMTime.zero)
       }
    }

    var collectionViewHeight : CGFloat!
    
    weak var standardPostCellDelegate : StandardPostCellDelegate!
    
    @IBOutlet weak var emojiButton : ZoomAnimatedButton! {didSet {
        emojiButton.tag = -1
    }}
    
    @IBOutlet weak var userNameLabel : UILabel! { didSet {
        userNameLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .medium)
    }}
    
    override  func getEmojiButtonConfig(image : UIImage) -> UIButton.Configuration {
        let bounds = UIScreen.main.bounds
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        
        config.image = image.scale(newWidth:  bounds.width * 0.08)
        return config
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutButton()
        distanceLabel = nil
        restaurantNameLabel = nil
    }
    
    
    override func registerCollectionCell() {
        super.registerCollectionCell()
        self.collectionView.register(StandardImageViewCollectionCell.self, forCellWithReuseIdentifier: "StandardImageViewCollectionCell")
        self.collectionView.register(StandardPlayerLayerCollectionCell.self, forCellWithReuseIdentifier: "StandardPlayerLayerCollectionCell")
    }
    
    
    override func setGesture() {
        super.setGesture()
        
        self.emojiButton.addTarget(self, action: #selector(emojiButtonTapped( _ : )), for: .touchUpInside)
        for (index, button) in emojiTargetButtons.enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(emojiTargetTapped(_ : )), for: .touchUpInside)
        }
        
        let userNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(segueToProFile(_ :)))
        self.userNameLabel.addGestureRecognizer(userNameLabelGesture)
        userNameLabel.isUserInteractionEnabled = true
    }
    
    
    func layoutButton() {
        let bounds = UIScreen.main.bounds
        var emojiConfig = UIButton.Configuration.filled()
        emojiConfig.image = UIImage(systemName: "smiley")?.scale(newWidth: bounds.width * 0.08).withTintColor(.label, renderingMode: .alwaysOriginal)

        emojiConfig.baseBackgroundColor = .clear
        emojiButton.configuration = emojiConfig
    }
    
    override func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self.standardPostCellDelegate.gestureStatusToggle(isTopViewController: true)
        return super.animationController(forDismissed: dismissed)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.currentPost.media[indexPath.row]
        if media.urlIsImage() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardImageViewCollectionCell", for: indexPath) as! StandardImageViewCollectionCell
            cell.layoutImageView(media: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardPlayerLayerCollectionCell", for: indexPath) as! StandardPlayerLayerCollectionCell
            cell.layoutPlayerlayer(media: media)
            return cell
        }
    }
    
    
    
    override func changeCurrentEmoji(emojiTag: Int?) {
        if let emojiTag = emojiTag {
            
            updateEmojiButtonImage(image: self.emojiTargetButtons[emojiTag].currentImage)
        }

    }
    
    func updateEmojiButtonImage(image : UIImage?) {
        if var config = self.emojiButton.configuration {
            let targeImage = image?.scale(newWidth: self.contentView.bounds.width * 0.08)
            config.image = targeImage
            
            self.emojiButton.configuration = config
        }
    }

    
    
    override func collectionViewFlowSet() {
        
        let flow = UICollectionViewFlowLayout()
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        flow.itemSize = CGSize(width: width   , height: height )
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        flow.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flow
    }
    
    
    override func configureData(post : Post) {
        currentPost = post
        NSLayoutConstraint.activate([
            self.collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
        ])
        self.collectionView.dataSource = self
        self.collectionView.delegate = self


        if let image = post.selfReaction?.reactionType?.reactionImage {
            self.currentEmojiTag = post.selfReaction?.reactionInt
            self.emojiButton.contentMode = .scaleAspectFit
            self.updateEmojiButtonImage(image: image)
        }
        setHeartImage()
        if let userImage = currentPost.user?.image {
            userImageView?.image = userImage
        } else {
            Task {
                let userImage = await currentPost.user?.imageURL?.getImageFromImageURL()
                currentPost.user?.image = userImage
                userImageView?.image = userImage
            }
        }

        pageControll?.numberOfPages = post.media.count
        self.userNameLabel.text = post.user?.name
        self.userNameLabel.textColor = .label

        if let grade = post.grade {
            self.gradeLabel?.text = String(grade)
        }


        updateCellPageControll(currentCollectionIndexPath: IndexPath(row: post.CurrentIndex, section: self.currentMediaIndexPath.section))
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.currentMediaIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    
         
    
    
    override func setHeartImage() {
        if currentPost.liked {
            self.heartImageView.image = UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        } else {
            heartImageView.image = UIImage(systemName: "heart")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        }
    }

    var extendedEmojiBlurView : UIVisualEffectView?
    
    override var emojiReactionsStackView: UIStackView? { didSet {
        emojiReactionsStackView?.isHidden = true
    }}
    
    @objc func emojiButtonTapped( _ button : UIButton) {
        if extendedEmojiBlurView == nil {
            startEmojiExtendAnimation()
        } else {
            startReactionTargetAnimation(targetTag: nil)
        }
    }
    
    @objc override func emojiTargetTapped(_ button: UIButton) {

        let tag = button.tag
        if self.currentPost.selfReaction?.reactionInt == tag {
            currentEmojiTag = nil
        } else {
            currentEmojiTag = tag
        }
        
        if canPostReaction {
            self.initNewReaction(reactionTag: currentEmojiTag, liked: currentPost.liked)
        }
        startReactionTargetAnimation(targetTag: currentEmojiTag)
    }
    
    var isEmojiViewAnimated : Bool! = false
    
    
    func startEmojiExtendAnimation() {
        
        
        guard !isEmojiViewAnimated else {
            return
        }
        isEmojiViewAnimated = true
        let bounds = contentView.bounds
        let emojiButtonFrameInContentView = self.emojiButton.imageView!.superview!.convert(self.emojiButton.imageView!.frame, to: contentView)

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
        let collectionViewFrame = self.collectionView.superview?.convert(collectionView.frame, to: contentView)
        let offset : CGFloat = 4
        let targetBlurFrame = CGRect(x: emojiButtonCenterInContentView.x, y: collectionViewFrame!.maxY - extendedEmojiBlurView.frame.height - offset , width: blurViewWidth, height: extendedEmojiBlurView.frame.height)

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
            let tag = self.currentPost.selfReaction?.reactionInt
            let emojiTargetWidth =  (blurViewWidth - ( blurViewXOffset * 2 )) / 5
 
            self.emojiTargetButtons.forEach() {
                $0.transform = .identity

                let x = targetBlurFrame.minX + blurViewXOffset + emojiTargetWidth * CGFloat($0.tag)
                $0.frame = CGRect(origin: .zero, size: CGSize(width: emojiTargetWidth, height: $0.frame.height))
                $0.center.y = collectionViewFrame!.maxY - extendedEmojiBlurView.frame.height - offset + extendedEmojiBlurView.frame.height / 2
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
        let frame = self.emojiButton.imageView!.superview!.convert(emojiButton.imageView!.frame, to: self.collectionView)
        let centerInFrame = self.emojiButton.superview!.convert(emojiButton.center, to: contentView)
        let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height * 0.8)
        if currentEmojiTag == nil {
            self.emojiButton.alpha = 0
            if emojiButton.imageView?.image != UIImage(systemName: "smiley") {
                self.updateEmojiButtonImage(image: UIImage(systemName: "smiley")!)
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
            if let currentEmojiTag = self.currentEmojiTag {
                
                let image = self.emojiTargetButtons[currentEmojiTag].configuration?.image
                self.updateEmojiButtonImage(image: image)
            }
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
        Task(priority: .low) { [weak self] in
            guard let self = self else {
                return
            }
            self.currentPost.media.forEach() {
               $0.player?.seek(to: CMTime.zero)
           }
        }
        
    }

    override func autoLayoutActive() {
        let width = collectionView.bounds.width
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        heartImageView.translatesAutoresizingMaskIntoConstraints  = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: width * 0.08),
            userImageView.heightAnchor.constraint(equalToConstant: width * 0.08),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)
        ])
    }
    

        
    
    
    
}
