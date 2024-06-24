import UIKit
import AVFoundation

class MainPostTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MediaCollectionCellDelegate, EmojiReactionObject, PostTableCell, UIViewControllerTransitioningDelegate     {
    func updateEmojiButtonImage(targetTag: Int?) {
        self.startReactionTargetAnimation(targetTag: targetTag)
    }
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
            cell.configure(media: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerLayerCollectionCell", for: indexPath) as! PlayerLayerCollectionCell
            cell.mediaCellDelegate = self
            cell.configure(media: media)
            return cell
        }
    }
    
    var currentMediaIndexPath : IndexPath! = IndexPath(row: 0, section: 0)
    
    
    var currentPost : Post! = Post.defaultExample

    var currentCollectionCell : UICollectionViewCell? {
        let cell =  collectionView.cellForItem(at: currentMediaIndexPath)
        return cell
    }
    
    var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    var shareButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var collectButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var restaurantNameLabel : UILabel! = UILabel()
    var userImageView: UIImageView! = UIImageView()
    
    var pageControll : UIPageControl! = UIPageControl()
    var distanceLabel : UILabel! = UILabel()
    
    var heartButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var gradeStarImageView : UIImageView! = UIImageView()
    var gradeLabel : UILabel! = UILabel()

    var emojiReactionsStackView : UIStackView! = UIStackView()
    
    var timeStampLabel : UILabel! = UILabel()
    
    var showProfileGesture : UITapGestureRecognizer! = UITapGestureRecognizer()
    var doubleTapGesture : UITapGestureRecognizer! =  UITapGestureRecognizer()
    var longTapGesture : UILongPressGestureRecognizer! = UILongPressGestureRecognizer()
    var muteTapGesture : UITapGestureRecognizer! = UITapGestureRecognizer()
    
    var tapToPresentWholeMediaGesture : UITapGestureRecognizer! = UITapGestureRecognizer()

    
    var gradeStackView : UIStackView! = UIStackView()
    
    func getEmojiButtonConfig(image : UIImage) -> UIButton.Configuration {
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .clear
        config.image = image.scale(newWidth: UIScreen.main.bounds.height * 0.04)
        return config
    }
    
    var loveButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var vomitButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var angryButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    var sadButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var surpriseButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    func configureData(post: Post)  {
        currentPost = post
        self.collectionView.reloadSections([0])
        currentMediaIndexPath = IndexPath(row: post.CurrentIndex, section: 0)
        if let userImage = currentPost.user?.image {
            userImageView.image = userImage
        } else {
            Task(priority: .low) {
                let userImage = try await currentPost.user?.imageURL?.getImageFromURL()
                currentPost.user?.image = userImage
                userImageView.image = userImage
            }
        }
        if let grade = post.grade {
            gradeStackView.isHidden = false
            self.gradeLabel.text = String(grade)
        } else {
            gradeStackView.isHidden = true
        }
        
        self.startReactionTargetAnimation(targetTag: post.selfReaction?.reactionType?.reactionTag)
        
        timeStampLabel.text = post.timestamp?.timeAgeFromStringOrDateString()

        distanceLabel?.text = currentPost.distance?.milesTransform()
        restaurantNameLabel?.text = currentPost.restaurant?.name
      
        setHeartButtonStatus()

        updateVisibleCellsMuteStatus()
        updateCellPageControll(currentCollectionIndexPath: IndexPath(row: currentPost.CurrentIndex, section: 0) )
        
        UIView.performWithoutAnimation {
            self.collectionView.scrollToItem(at: self.currentMediaIndexPath, at: .centeredHorizontally, animated: false)
            
        }
    }
    
    
    func emojiButtonSetup() {
        loveButton.configuration = getEmojiButtonConfig(image: UIImage(named: "love")!)
        loveButton.tag = 0
        vomitButton.configuration = getEmojiButtonConfig(image: UIImage(named: "vomit")!)
        vomitButton.tag = 1
        angryButton.configuration = getEmojiButtonConfig(image: UIImage(named: "angry")!)
        angryButton.tag = 2
        sadButton.configuration = getEmojiButtonConfig(image: UIImage(named: "sad")!)
        sadButton.tag = 3
        surpriseButton.configuration = getEmojiButtonConfig(image: UIImage(named: "surprise")!)
        surpriseButton.tag = 4
    }
    
    var emojiTargetButtons : [ZoomAnimatedButton]! {
        return [loveButton, vomitButton, angryButton, sadButton, surpriseButton]
    }
    
    func viewLayoutSetup() {

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
        
        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 1 / 1.08),
            
            gradeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            gradeStackView.centerYAnchor.constraint(equalTo: pageControll.centerYAnchor),
            
            shareButton.centerYAnchor.constraint(equalTo: pageControll  .centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            collectButton .centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            collectButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -8),
            
            pageControll.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 4),
            pageControll.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            pageControll.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControll.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.3),
            
            restaurantNameLabel.topAnchor.constraint(equalTo: pageControll.bottomAnchor, constant: 6),
            restaurantNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            
            distanceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            distanceLabel.topAnchor.constraint(equalTo: restaurantNameLabel.bottomAnchor, constant: 8),
            
            emojiReactionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28),
            emojiReactionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiReactionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiReactionsStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.08),
            
            timeStampLabel.bottomAnchor.constraint(equalTo: emojiReactionsStackView.topAnchor, constant: -16),
            timeStampLabel.trailingAnchor.constraint(equalTo: emojiReactionsStackView.trailingAnchor)
            
        ])

        self.layoutIfNeeded()
        let width = contentView.bounds.width
        let scale = 0.1
        NSLayoutConstraint.activate( [
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: width * scale),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  width * scale),
            userImageView.widthAnchor.constraint(equalToConstant: width * 0.14),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),
            
            heartButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            
            heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -width * scale),
            heartButton.heightAnchor.constraint(equalToConstant: width * 0.12),
            heartButton.widthAnchor.constraint(equalTo: heartButton.heightAnchor, multiplier: 1),
        ])

        
        
    }
    
    func labelSetup() {
        gradeLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)
        
        restaurantNameLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
        restaurantNameLabel.numberOfLines = 2
        restaurantNameLabel.textAlignment = .center
        timeStampLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        timeStampLabel.textColor = .secondaryLabelColor
        distanceLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        distanceLabel.textColor = .secondaryLabelColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        registerCollectionCell()
        viewLayoutSetup()
        collectionViewSetup()
        labelSetup()
        buttonSetup()
        userImageViewSetup()
        pageControllSetup()
        gradeStackViewSetup()
        emojiStackViewSetup()
        setGestureTarget()
    }
    
    func gradeStackViewSetup() {
        gradeStackView.alignment = .center
        gradeStackView.distribution = .fill
        gradeStackView.axis = .horizontal
        gradeStackView.spacing = 2

        gradeStarImageView.image = UIImage(systemName: "star.fill")?.withTintColor(.gradeStarYellow , renderingMode: .alwaysOriginal    )
        gradeStackView.addArrangedSubview(gradeStarImageView)
        gradeStackView.addArrangedSubview(gradeLabel)
    }
    
    
    func buttonSetup() {
        var paperplaneConfig = UIButton.Configuration.filled()
        paperplaneConfig.image = UIImage(systemName: "paperplane")
        paperplaneConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium))
        paperplaneConfig.baseBackgroundColor = .clear
        paperplaneConfig.baseForegroundColor = .label
        paperplaneConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        shareButton.configuration = paperplaneConfig
        var starConfig = UIButton.Configuration.filled()
        starConfig.image = UIImage(systemName: "star")
        starConfig.baseBackgroundColor = .clear
        starConfig.baseForegroundColor = .label
        starConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium))
        starConfig.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        collectButton.configuration = starConfig
        
        
        var heartConfig = UIButton.Configuration.filled()
        heartConfig.image = UIImage(systemName: "heart")
        heartConfig.baseBackgroundColor = .clear
        
        heartConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title1, weight: .bold))
        heartButton.configuration = heartConfig
    }
    
    
    var userImageViewCornerRadius : CGFloat! {
        return 8
    }
    
    func userImageViewSetup() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius  = userImageViewCornerRadius
        userImageView.isUserInteractionEnabled = true
    }
    
    func emojiStackViewSetup() {
        emojiReactionsStackView.layer.cornerRadius = 10.0
        emojiReactionsStackView.layer.borderWidth = 1.0
        emojiReactionsStackView.layer.borderColor = UIColor.secondaryLabelColor.cgColor
        emojiReactionsStackView.axis = .horizontal
        emojiReactionsStackView.distribution  = .fillEqually
        emojiReactionsStackView.alignment = .center
        emojiReactionsStackView.isUserInteractionEnabled = true
        emojiButtonSetup()
        if let emojiReactionsStackView = emojiReactionsStackView {
            self.emojiTargetButtons.forEach() {
                emojiReactionsStackView.addArrangedSubview($0)
            }
        }
    }
    
    func pageControllSetup() {
        pageControll.pageIndicatorTintColor = .secondaryLabelColor
        pageControll.currentPageIndicatorTintColor = .tintOrange
        pageControll.backgroundStyle = .automatic
        pageControll.isUserInteractionEnabled = false
        
        
    }

    
    func collectionViewSetup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.delaysContentTouches = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.clipsToBounds = true
        collectionViewFlowSetup()
        
    }
    
    func collectionViewFlowSetup() {
        DispatchQueue.main.async { [self] in
            let flow = UICollectionViewFlowLayout()
            let height = self.collectionView.bounds.height
            let spacing = self.contentView.bounds.width - height
            flow.itemSize = CGSize(width: height  , height: height )
            flow.minimumLineSpacing = spacing
            flow.minimumInteritemSpacing = 0
            flow.scrollDirection = .horizontal
            flow.sectionInset = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
            self.collectionView.collectionViewLayout = flow
        }
        
    }
    

    
    func setHeartButtonStatus() {
        
        self.heartButton.configuration?.image =  currentPost.liked ? UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal) :  UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    func setGestureTarget() {
        showProfileGesture = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_ : )))
        doubleTapGesture = {
            let DoubletapGesture = UITapGestureRecognizer(target: self, action: #selector(DoubleLike( _ : )))
            DoubletapGesture.numberOfTapsRequired = 2
            return DoubletapGesture
        }()
        longTapGesture = {
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(presentWholePageViewController (_ :)))
            longTapGesture.minimumPressDuration = 0.2
            return longTapGesture
        }()
        muteTapGesture = UITapGestureRecognizer(target: self, action: #selector(muteGestureTapped( _ : )))
        
        heartButton.addTarget(self, action: #selector(LikeToggle), for: .touchUpInside)
        
        collectButton.addTarget(self, action: #selector(presentAddCollectViewController), for: .touchUpInside)
        
        shareButton.addTarget(self, action: #selector(presentShareViewController), for: .touchUpInside)
        
        collectionView.addGestureRecognizer(muteTapGesture)
        collectionView.addGestureRecognizer(doubleTapGesture)
        collectionView.addGestureRecognizer(longTapGesture)
        muteTapGesture.require(toFail: doubleTapGesture)
        userImageView.addGestureRecognizer(showProfileGesture)
        
        self.emojiTargetButtons.forEach() {
            $0.addTarget(self, action: #selector(emojiTargetTapped(_:)), for: .touchUpInside)
        }
        
    }
    
    
    
    var currentEmojiTag: Int?
    
    
    @objc func emojiTargetTapped(_ button: UIButton) {
        
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
    
    
    
    func startReactionTargetAnimation(targetTag : Int?) {
        currentEmojiTag = targetTag
        if let targetTag = targetTag {
            
            let label = self.emojiReactionsStackView!.arrangedSubviews[targetTag]
            let zoomInTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            let zoomOutTransform = CGAffineTransform(scaleX: 0.65, y: 0.65)
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut , animations: {
                label.transform = zoomInTransform
                label.alpha = 1
                self.emojiReactionsStackView!.arrangedSubviews.forEach { view in
                    if view.tag == self.currentPost.selfReaction?.reactionType?.reactionTag {
                        return
                    }
                    view.transform = zoomOutTransform
                    view.alpha = 0.4
                }
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut , animations: {
                self.emojiReactionsStackView!.arrangedSubviews.forEach { view in
                    view.transform = .identity
                    view.alpha = 1
                }
            })
        }
        
    }
    
}

extension MainPostTableCell {
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetPostMediasPlayer()
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
        pageControll?.numberOfPages = currentPost.media.count
        self.currentMediaIndexPath.row = currentCollectionIndexPath.row
        self.pageControll?.currentPage = currentCollectionIndexPath.row
        
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
    
   /* @objc func presentWholePageViewController(_ gesture : UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            mediaTableCellDelegate?.presentWholePageMediaViewController(post : currentPost)
        }
    }*/
    
    @objc func presentWholePageViewController(_ gesture : UITapGestureRecognizer) {
       // if gesture.state == .began {
             mediaTableCellDelegate?.presentWholePageMediaViewController(post : currentPost)
        //}
    }
    
    @objc func LikeToggle() {
        self.currentPost.liked.toggle()
        setHeartTotal()
        setHeartButtonStatus()
        if canPostReaction {
            self.initNewReaction(reactionTag: self.currentPost.selfReaction?.reactionType?.reactionTag, liked: currentPost.liked)
        }
    }
    
    @objc func DoubleLike(_ gesture : UITapGestureRecognizer) {
        self.currentPost.liked = true
        setHeartTotal()
        setHeartButtonStatus()
        if canPostReaction {
            self.initNewReaction(reactionTag: self.currentPost.selfReaction?.reactionType?.reactionTag, liked: currentPost.liked)
        }
    }
    
    
    
    @objc func showUserProfile(_ gesture: UITapGestureRecognizer) {
        guard let user = self.currentPost.user else {
            return
        }
        mediaTableCellDelegate?.showUserProfile(user: user)
    }

    @objc func muteGestureTapped(_ gesture: UITapGestureRecognizer) {
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
        
        setHeartButtonStatus()
        
        startReactionTargetAnimation(targetTag: currentPost.selfReaction?.reactionType?.reactionTag)
        currentMediaIndexPath = scrollTo
        reloadEnterAndBackCollectionCell(enterIndexPath: reloadIndexPath, backIndexPath: scrollTo)
        
        updateVisibleCellsMuteStatus()
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
        
        let viewController = AddCollectViewController()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        mediaTableCellDelegate?.present(viewController, animated: true)
        
        
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


