import UIKit
import AVFoundation

class MainPostTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, MediaCollectionCellDelegate, EmojiReactionObject, PostTableCell, UIViewControllerTransitioningDelegate     {
    weak var mediaTableCellDelegate : MediaTableCellDelegate?
    var canPostReaction : Bool!  {
        true
    }
    
    var currentSoundImageView : [UIView]? {
        if let playerLayerCell = currentCollectionCell as? PlayerLayerCollectionCell {
            return playerLayerCell.soundViewIncludeBlur
        }
        return nil
    }
    
    func registerCollectionCell() {
        self.collectionView.register(ImageViewCollectionCell.self, forCellWithReuseIdentifier: "ImageViewCollectionCell")
        self.collectionView.register(PlayerLayerCollectionCell.self, forCellWithReuseIdentifier: "PlayerLayerCollectionCell")
    }
    
    func playCurrentMedia() {
        if let cell = self.collectionView.cellForItem(at: self.currentMediaIndexPath) as? PlayerLayerCollectionCell {
            cell.play()
        }
    }
    func pauseCurrentMedia() {
        if let cell = self.collectionView.cellForItem(at: self.currentMediaIndexPath) as? PlayerLayerCollectionCell {
            cell.pause()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentPost.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.currentPost.media[indexPath.row]
        if media.isImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionCell", for: indexPath) as! ImageViewCollectionCell
            cell.layoutImageView(media: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerLayerCollectionCell", for: indexPath) as! PlayerLayerCollectionCell
            cell.layoutPlayerlayer(media: media)
            return cell
        }
    }
    
    var currentMediaIndexPath : IndexPath! = IndexPath(row: 0, section: 0)
    var pageviewcontrollerHeight : CGFloat?
    
    
    var currentPost : Post!
    
    
    
    var currentCollectionCell : UICollectionViewCell? {
        let cell =  collectionView.cellForItem(at: currentMediaIndexPath)
        return cell
    }
    
    @IBOutlet var collectionView : UICollectionView! { didSet {
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.clipsToBounds = true
    }}
    @IBOutlet weak var shareImageView : UIImageView! { didSet {
        shareImageView.isUserInteractionEnabled = true
    }}
    @IBOutlet weak var collectImageView : UIImageView! { didSet {
        collectImageView.isUserInteractionEnabled = true
    }}
    @IBOutlet weak var restaurantNameLabel : UILabel?
    @IBOutlet weak var userImageView: UIImageView! { didSet {
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius  = 8
        userImageView.isUserInteractionEnabled = true
    }}
    
    @IBOutlet weak var pageControll : UIPageControl! { didSet {
        pageControll?.hidesForSinglePage = true
    }}
    @IBOutlet weak var distanceLabel : UILabel?
    
    @IBOutlet weak var heartImageView : UIImageView! { didSet {
        heartImageView.isUserInteractionEnabled = true
        heartImageView.tintColor = .label
    }}
    
    @IBOutlet weak var emojiReactionsStackView : UIStackView? { didSet {
        emojiReactionsStackView?.layer.cornerRadius = 10.0
        emojiReactionsStackView?.layer.borderWidth = 1.0
        emojiReactionsStackView?.layer.borderColor = UIColor.secondaryLabelColor.cgColor
        emojiReactionsStackView?.isUserInteractionEnabled = true
    }}
    
    @IBOutlet var timeStampLabel : UILabel!
    
    var tapToProFileGesture : UITapGestureRecognizer!
    var doubleTapGesture : UITapGestureRecognizer!
    var longTapGesture : UILongPressGestureRecognizer!
    var muteTapGesture : UITapGestureRecognizer!
    var likeToggleGesture : UITapGestureRecognizer!
    
    var presentAddCollectViewControllerTapGesture : UITapGestureRecognizer!
    
    var presentShareViewControllerTapGesture : UITapGestureRecognizer!
    
    @IBOutlet var gradeLabel : UILabel?
    
    @IBOutlet var gradeStackView : UIStackView?
    
    
    func configureData(post: Post)  {
        currentPost = post
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.layoutIfNeeded()
        
        
        if let grade = post.grade {
            self.gradeLabel?.isHidden = false
            gradeStackView?.isHidden = false
            self.gradeLabel?.text = String(grade)
            self.gradeLabel?.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
        } else {
            gradeStackView?.isHidden = true
            self.gradeLabel?.isHidden = true
        }
        layoutSelfReaction(targetTag: post.selfReaction?.reactionInt)
        
        
        currentMediaIndexPath = IndexPath(row: post.CurrentIndex, section: 0)
        distanceLabel?.text = currentPost.distance?.milesTransform()
        restaurantNameLabel?.text = currentPost.restaurant?.name
        pageControll?.numberOfPages = currentPost.media.count
        setHeartImage()
        if let userImage = currentPost.user?.image {
            
            userImageView.image = userImage
        } else {
            Task(priority: .low) {
                let userImage = try await currentPost.user?.imageURL?.getImageFromURL()
                currentPost.user?.image = userImage
                userImageView.image = userImage
            }
        }
        timeStampLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .medium)
        timeStampLabel.textColor = .secondaryLabelColor
        self.timeStampLabel.text = post.timestamp.timeAgeFromStringOrDateString()
        self.updateVisibleCellsMuteStatus()
        self.collectionView.scrollToItem(at: IndexPath(row: self.currentPost.CurrentIndex, section: self.currentMediaIndexPath.section), at: .centeredHorizontally, animated: false)
        updateCellPageControll(currentCollectionIndexPath: IndexPath(row: currentPost.CurrentIndex, section: 0) )
        
    }
    
    
    
    func layoutSelfReaction(targetTag : Int?) {
        if let targetTag = targetTag {
            let label = self.emojiReactionsStackView!.arrangedSubviews[targetTag]
            let zoomInTransform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            let zoomOutTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
            label.transform = zoomInTransform
            label.alpha = 1
            self.emojiReactionsStackView!.arrangedSubviews.forEach { view in
                if view.tag == targetTag {
                    return
                }
                view.transform = zoomOutTransform
                view.alpha = 0.5
            }
        } else {
            self.emojiReactionsStackView!.arrangedSubviews.forEach { view in
                if view.tag == targetTag {
                    return
                }
                view.transform = .identity
                view.alpha = 1
            }
        }
    }
    
    func getEmojiButtonConfig(image : UIImage) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.image = image.scale(newWidth: self.emojiReactionsStackView!.frame.height * 0.55)
        return config
    }
    
    lazy var loveButton : ZoomAnimatedButton! = {
        let button = ZoomAnimatedButton()
        button.configuration = getEmojiButtonConfig(image: UIImage(named: "love")!)
        button.tag = 0
        return button
    }()
    
    lazy var vomitButton : ZoomAnimatedButton! = {
        let button = ZoomAnimatedButton()
        button.configuration = getEmojiButtonConfig(image: UIImage(named: "vomit")!)
        button.tag = 1
        return button
    }()
    lazy var angryButton : ZoomAnimatedButton! = {
        let button = ZoomAnimatedButton()
        button.configuration = getEmojiButtonConfig(image: UIImage(named: "angry")!)
        button.tag = 2
        return button
        
    }()
    lazy var sadButton : ZoomAnimatedButton! = {
        let button = ZoomAnimatedButton()
        button.configuration = getEmojiButtonConfig(image: UIImage(named: "sad")!)
        button.tag = 3
        return button
        
    }()
    lazy var surpriseButton : ZoomAnimatedButton! = {
        
        let button = ZoomAnimatedButton()
        button.configuration = getEmojiButtonConfig(image: UIImage(named: "surprise")!)
        button.tag = 4
        return button
        
    }()
    
    var emojiTargetButtons : [ZoomAnimatedButton]! {
        return [loveButton, vomitButton, angryButton, sadButton, surpriseButton]
    }
    
    func autoLayoutActive() {
        let width = collectionView.bounds.width
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        heartImageView.translatesAutoresizingMaskIntoConstraints  = false
        let scale = 0.04
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18 + width * scale),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18 + width * scale),
            heartImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18 - width * scale),
            heartImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18 + width * scale),
            heartImageView.widthAnchor.constraint(equalToConstant: 40),
            heartImageView.heightAnchor.constraint(equalToConstant: 40),
            userImageView.widthAnchor.constraint(equalToConstant: width * 0.1),
            userImageView.heightAnchor.constraint(equalToConstant: width * 0.1)
        ])
    }
    func setHeartImage() {
        if currentPost.liked {
            self.heartImageView.image = UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        } else {
            heartImageView.image = UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        collectionViewFlowSet()
    }
    
    func collectionViewFlowSet() {
        let flow = UICollectionViewFlowLayout()
        let height = collectionView.bounds.height
        let spacing = self.collectionView.bounds.width - height
        flow.itemSize = CGSize(width: height  , height: height )
        flow.minimumLineSpacing = spacing
        flow.minimumInteritemSpacing = 0
        flow.scrollDirection = .horizontal
        flow.sectionInset = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
        collectionView.collectionViewLayout = flow
    }
    
    var tapHeartGesture : UITapGestureRecognizer!
    
    func setGesture() {
        tapToProFileGesture = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_ : )))
        doubleTapGesture = {
            let DoubletapGesture = UITapGestureRecognizer(target: self, action: #selector(DoubleLike( _ : )))
            DoubletapGesture.numberOfTapsRequired = 2
            return DoubletapGesture
        }()
        longTapGesture = {
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(segueToDetail (_ :)))
            longTapGesture.minimumPressDuration = 0.5
            return longTapGesture
        }()
        muteTapGesture = UITapGestureRecognizer(target: self, action: #selector(MutedToggle( _ : )))
        tapHeartGesture = UITapGestureRecognizer(target: self, action: #selector(LikeToggle))
        
        presentAddCollectViewControllerTapGesture = UITapGestureRecognizer(target: self, action: #selector(presentAddCollectViewController(_ : )))
        self.collectImageView.addGestureRecognizer(presentAddCollectViewControllerTapGesture)
        presentShareViewControllerTapGesture = UITapGestureRecognizer(target: self, action: #selector(presentShareViewController(_ : )))
        self.shareImageView.addGestureRecognizer(presentShareViewControllerTapGesture)
        
        collectionView.addGestureRecognizer(muteTapGesture)
        collectionView.addGestureRecognizer(doubleTapGesture)
        collectionView.addGestureRecognizer(longTapGesture)
        muteTapGesture.require(toFail: doubleTapGesture)
        userImageView.addGestureRecognizer(tapToProFileGesture)
        heartImageView.addGestureRecognizer(tapHeartGesture)
        self.emojiTargetButtons.forEach() {
            $0.addTarget(self, action: #selector(emojiTargetTapped(_:)), for: .touchUpInside)
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.backgroundPrimary
        
        registerCollectionCell()
        autoLayoutActive()
        layoutEmojiStackView()
        setGesture()
        
    }
    
    func layoutEmojiStackView() {
        if let emojiReactionsStackView = emojiReactionsStackView {
            self.emojiTargetButtons.forEach() {
                emojiReactionsStackView.addArrangedSubview($0)
            }
        }
    }
    
    
    var currentEmojiTag: Int?
    
    
    @objc func emojiTargetTapped(_ button: UIButton) {
        
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
    
    func changeCurrentEmoji(emojiTag : Int?) {
        startReactionTargetAnimation(targetTag: emojiTag)
    }
    
    
    
    func startReactionTargetAnimation(targetTag : Int?) {
        
        if currentPost.selfReaction?.reactionInt == nil {
            
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut , animations: {
                self.emojiReactionsStackView!.arrangedSubviews.forEach { view in
                    view.transform = .identity
                    view.alpha = 1
                }
            })
            
        } else {
            let label = self.emojiReactionsStackView!.arrangedSubviews[(currentPost.selfReaction?.reactionInt)!]
            let zoomInTransform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            let zoomOutTransform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut , animations: {
                label.transform = zoomInTransform
                label.alpha = 1
                self.emojiReactionsStackView!.arrangedSubviews.forEach { view in
                    if view.tag == self.currentPost.selfReaction?.reactionInt {
                        return
                    }
                    view.transform = zoomOutTransform
                    view.alpha = 0.4
                }
            }) { bool in
                
            }
        }
        
    }
    
}

extension MainPostTableCell {
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetPostMediasPlayer()
        self.collectionView.dataSource = nil
        self.restaurantNameLabel?.text = ""
        self.distanceLabel?.text = ""
    }
    func resetPostMediasPlayer() {
        currentPost.media.forEach { Media in
            if let player = Media.player {
                player.seek(to: CMTime.zero)
            }
        }
    }
    
    
    
    func playCurrentMedia(indexPath : IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PlayerLayerCollectionCell {
            cell.play()
        }
    }
    
    
    func initNewReaction(reactionTag : Int?, liked : Bool ) {
        if canPostReaction {
            currentPost.initNewReaction(reactionTag: reactionTag, liked: liked)
        }
    }
    
    func updateCellPageControll(currentCollectionIndexPath: IndexPath) {
        self.currentMediaIndexPath.row = currentCollectionIndexPath.row
        self.pageControll?.currentPage = currentCollectionIndexPath.row
        
        self.pageControll?.layoutSubviews()
        
        self.currentPost.CurrentIndex = currentCollectionIndexPath.row
        
        if currentPost.media[currentCollectionIndexPath.row].isImage {
            self.muteTapGesture.isEnabled = false
        } else {
            self.muteTapGesture.isEnabled = true
            
        }
    }
    
    func setHeartTotal() {
        if currentPost.liked {
            currentPost.likedTotal += 1
        } else {
            currentPost.likedTotal -= 1
        }
    }
    
    @objc func segueToDetail(_ gesture : UILongPressGestureRecognizer) {
        if gesture.state == .began {
            mediaTableCellDelegate?.presentWholePageMediaViewController(post : currentPost)
        }
    }
    
    @objc func LikeToggle() {
        self.currentPost.liked.toggle()
        setHeartTotal()
        setHeartImage()
        if canPostReaction {
            self.initNewReaction(reactionTag: self.currentPost.selfReaction?.reactionInt, liked: currentPost.liked)
        }
    }
    
    @objc func DoubleLike(_ gesture : UITapGestureRecognizer) {
        self.currentPost.liked = true
        setHeartTotal()
        setHeartImage()
        if canPostReaction {
            self.initNewReaction(reactionTag: self.currentPost.selfReaction?.reactionInt, liked: currentPost.liked)
        }
    }
    
    
    
    @objc func showUserProfile(_ gesture: UITapGestureRecognizer) {
        guard let user = self.currentPost.user else {
            return
        }
        mediaTableCellDelegate?.showUserProfile(user: user)
    }

    @objc func MutedToggle(_ gesture: UITapGestureRecognizer? = nil) {
        UniqueVariable.IsMuted.toggle()
        mediaTableCellDelegate?.updateVisibleCellsMuteStatus()
        updateVisibleCellsMuteStatus()
    }
    
    func updateVisibleCellsMuteStatus() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? PlayerLayerCollectionCell {
                cell.updateMuteStatus()
            }
        }
    }
    
}


extension MainPostTableCell {
    
    
    func reloadCollectionCell(reloadIndexPath : IndexPath, scrollTo : IndexPath) {
        
        setHeartImage()
        self.startReactionTargetAnimation(targetTag: self.currentPost.selfReaction?.reactionInt)
        self.currentMediaIndexPath = scrollTo
        reloadEnterAndBackCollectionCell(enterIndexPath: reloadIndexPath, backIndexPath: scrollTo)
        
        self.updateVisibleCellsMuteStatus()
    }
    
    
    func reloadEnterAndBackCollectionCell(enterIndexPath : IndexPath, backIndexPath : IndexPath) {
        let enterMedia = currentPost.media[enterIndexPath.row]
        if let enterCollectioncell = collectionView.cellForItem(at: enterIndexPath) as? PlayerLayerCollectionCell {
            enterCollectioncell.reload(media: enterMedia)
        } else if let enterCollectioncell =  collectionView.cellForItem(at: enterIndexPath) as? ImageViewCollectionCell {
            enterCollectioncell.reload(media: enterMedia)
        }
        let backMedia = currentPost.media[backIndexPath.row]
        if let backCollectionCell = collectionView.cellForItem(at: backIndexPath) as? PlayerLayerCollectionCell {
            backCollectionCell.reload(media: backMedia)
        } else if let backCollectionCell =  collectionView.cellForItem(at: backIndexPath) as? ImageViewCollectionCell {
            backCollectionCell.reload(media: backMedia)
        }
    }
    
    
}

extension MainPostTableCell {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playCurrentMedia(indexPath: self.currentMediaIndexPath)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(round(targetContentOffset.pointee.x / scrollView.bounds.width))
        if currentMediaIndexPath.row != index {
            pauseCurrentMedia()
            updateCellPageControll(currentCollectionIndexPath: IndexPath(row: index, section: currentMediaIndexPath.section))
            self.updateVisibleCellsMuteStatus()
        }
        currentMediaIndexPath.row = index
    }
}

extension MainPostTableCell {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let bounds = UIScreen.main.bounds
        
        let maxWidth = bounds.width - 16
        var maxHeight : CGFloat! = bounds.height * 0.5
        if presented is ShareViewController {
            maxHeight =  bounds.height * 0.7
        }
        self.mediaTableCellDelegate?.pauseCurrentMedia()
        return MaxFramePresentedViewPresentationController(presentedViewController: presented, presenting: presenting, maxWidth: maxWidth, maxHeight: maxHeight)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self.mediaTableCellDelegate?.playCurrentMedia()
        return nil
    }
    
    
    
    @objc func presentAddCollectViewController(_ gesture : UITapGestureRecognizer) {
        if let delegateViewController = self.mediaTableCellDelegate as? UIViewController {
            let viewController = AddCollectViewController()
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            delegateViewController.present(viewController, animated: true) {
            }
        }
    }
    
    @objc func presentShareViewController(_ gesture : UITapGestureRecognizer) {
        
        let viewController = SharePostViewController(post: currentPost)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        mediaTableCellDelegate?.present(viewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PlayerLayerCollectionCell {
            cell.soundViewIncludeBlur.forEach() {
                $0.layer.opacity = 1
            }
        }
    }
    
}


