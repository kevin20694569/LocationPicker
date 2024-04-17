import UIKit
import AVFoundation
class WholePageMediaViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UIViewControllerTransitioningDelegate, UIEditMenuInteractionDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate,  WholePageCollectionViewAnimatorDelegate, PostDetailSheetViewControllerDelegate, EmojiReactionObject{
    
    var currentPost : Post!
    
    var postID : String!
    
    var presentForTabBarLessView : Bool! = false
    
    var canPostReaction : Bool!  {
        true
    }
    
    weak var mediaAnimatorDelegate : MediaCollectionViewAnimatorDelegate?
    
    weak var wholePageMediaDelegate : WholePageMediaViewControllerDelegate?
    
    weak var panWholePageViewControllerwDelegate : PanWholePageViewControllerDelegate?
    
    init(presentForTabBarLessView : Bool, post : Post) {
        super.init(nibName: nil, bundle: nil)
        self.currentPost = post
        self.presentForTabBarLessView = presentForTabBarLessView
    }
    
    deinit {
        self.cacelTimer()
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var detailSheetViewController : PostDetailSheetViewController?
    
    let symbolConfig : UIImage.SymbolConfiguration! = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .medium))
    
    var heartSymbolConfig : UIImage.SymbolConfiguration! = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title1, weight: .medium))
    
    var restaurantNameLabel  : UILabel! = UILabel()
    
    var locationimageView: UIImageView! = UIImageView()
    
    var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    var dismissButtonItem : UIBarButtonItem! = UIBarButtonItem()
    
    var bottomBarView : UIView! = UIView()
    
    var progressSlider : UISlider! = UISlider()
    
    var postTitleButton : RoundedButton! = RoundedButton(frame: .zero, Title: "", backgroundColor: .clear, tintColor: .clear, font: .weightSystemSizeFont(systemFontStyle: .body, weight: .medium), contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20), cornerRadius: 16)
    
    var itemTitleButton : RoundedButton! = RoundedButton(frame: .zero, Title: "", backgroundColor: .clear, tintColor: .clear, font: .weightSystemSizeFont(systemFontStyle: .body, weight: .medium), contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20), cornerRadius: 16)
    
    var pageControll : UIPageControl! = UIPageControl()
    
    var lengthLabel : UILabel! = UILabel()
    
    var currentTimeLabel : UILabel!  = UILabel()
    
    var gradeStackView : UIStackView! = UIStackView()
    
    var gradeLabel : UILabel! = UILabel()
    
    var resizeToggleButton : UIButton! = UIButton()
    
    var userImageView: UIImageView! = UIImageView()
    
    var collectButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var shareButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var emojiButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var heartButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var isMovingButton : Bool = false
    
    var isMovingView : Bool! = false
    
    var isSlidingPlayer : Bool = false
    
    var currentMediaIndexPath : IndexPath! = IndexPath(row: 0, section: 0)
    
    var previousOffsetX : CGFloat! = 0
    
    var activeButton : UIButton?
    
    var soundImageView : UIImageView! = UIImageView(image: UIImage(systemName: "speaker.slash.fill"))
    var soundImageBlurView : UIVisualEffectView! = UIVisualEffectView(frame: .zero, style: .systemChromeMaterialDark)
    var soundImageViews : [UIView]! {
        return [soundImageView, soundImageBlurView]
    }
    
    var taptoProfileGesture : UITapGestureRecognizer!
    var doubletapGesture : UITapGestureRecognizer!
    var mutedAllgesture : UITapGestureRecognizer!
    var likeToggleGesture : UITapGestureRecognizer!
    var longTapToPauseGesture : UILongPressGestureRecognizer!
    var dismissTapGesture : UITapGestureRecognizer!
    var panWholeViewGesture : UIPanGestureRecognizer!
    var dismissEmojiViewGesture : UITapGestureRecognizer!
    
    var timeObserverToken : Any?
    var extendedEmojiBlurView : UIVisualEffectView?
    
    var currentEmojiTag : Int?
    
    var buttonHiddenStatus : ButtonsStatus! = .bothActive
    
    enum ButtonsStatus {
        case bothActive, onlyPresentTitleButton, onlyPresentItemTitleButton, bothHidden
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
    
    var startX : CGFloat?
    
    var lastDeltaX : CGFloat?
    
    var soundImageViewsOpacityTimer : DispatchSourceTimer?
    
    
    var emojiTargetButtons : [ZoomAnimatedButton]! {
        return [loveButton, vomitButton, angryButton, sadButton, surpriseButton]
    }
    
    var currentCollectionCell: UICollectionViewCell? {
        let cell = self.collectionView.cellForItem(at: self.currentMediaIndexPath)
        return cell
    }
    var blurView : UIVisualEffectView!
    
    var postTitleButtonBlurView : UIVisualEffectView!
    
    var itemTitleButtonBlurView : UIVisualEffectView!
    
    func layoutBottomBarView() {
        NSLayoutConstraint.activate([
            self.bottomBarView.heightAnchor.constraint(equalToConstant: Constant.bottomBarViewHeight)
        ])
        bottomBarView.tag = 5
    }
    
    func setGestureTarget() {
        doubletapGesture = {
            
            let DoubletapGesture = UITapGestureRecognizer(target: self, action: #selector(DoubleLike))
            DoubletapGesture.numberOfTapsRequired = 2
            return DoubletapGesture
        }()
        mutedAllgesture = UITapGestureRecognizer(target: self, action: #selector(updateVisibleCellsMuteStatus(_ :)))
        likeToggleGesture = UITapGestureRecognizer(target: self, action: #selector(LikeToggle(_ :)))
        longTapToPauseGesture = UILongPressGestureRecognizer(target: self, action: #selector(pausePlayingnowplayer(_ : )))
        dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView))
        panWholeViewGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureToDismiss(_:)))
        
        longTapToPauseGesture.minimumPressDuration = 0.3
        collectionView.addGestureRecognizer(longTapToPauseGesture)
        collectionView.addGestureRecognizer(doubletapGesture)
        
        
        dismissTapGesture.cancelsTouchesInView = false
        dismissTapGesture.isEnabled = false
        mutedAllgesture.isEnabled = true
        mutedAllgesture.cancelsTouchesInView = false
        mutedAllgesture.require(toFail: doubletapGesture)
        self.navigationController?.view.addGestureRecognizer(panWholeViewGesture)
        resizeToggleButton.addTarget(self, action: #selector(adjustMediaContentMode( _ : )), for: .touchUpInside)
        self.view.gestureRecognizers?.forEach({ gesture in
            panWholeViewGesture.require(toFail: gesture)
        })
        self.emojiTargetButtons.forEach() {
            $0.addTarget(self, action:  #selector(emojiTargetTapped(_:)), for: .touchUpInside)
        }
        shareButton.addTarget(self, action: #selector(presentShareViewController( _  : )), for: .touchUpInside)
        dismissEmojiViewGesture = UITapGestureRecognizer(target: self, action: #selector(tapToCloseExtendedView))
        dismissEmojiViewGesture.cancelsTouchesInView = false
        
        
        dismissTapGesture.delegate = self
        dismissEmojiViewGesture.delegate = self
        mutedAllgesture.delegate = self
        
        mutedAllgesture.require(toFail: longTapToPauseGesture)
        mutedAllgesture.require(toFail: dismissEmojiViewGesture)
        collectionView.addGestureRecognizer(dismissTapGesture)
        collectionView.addGestureRecognizer(mutedAllgesture)
        collectionView.addGestureRecognizer(dismissEmojiViewGesture)
        collectionView.isUserInteractionEnabled = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == dismissEmojiViewGesture {
            if self.extendedEmojiBlurView == nil {
                return false
            }
        }
        if gestureRecognizer == mutedAllgesture {
            if self.presentedViewController != nil {
                return false
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        layoutBottomBarView()
        collectionViewFlowSet()
        registerCells()
        viewStyleSet()
        setGestureTarget()
        layoutBlurView()
        configurePostTitleView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.configureData(post: currentPost)
        self.view.layoutIfNeeded()
        self.collectionView.layoutIfNeeded()
        let indexPath = IndexPath(row: self.currentPost.CurrentIndex, section: 0 )
        self.currentMediaIndexPath = indexPath
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.view.endEditing(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCellPageControll(currentCollectionIndexPath: currentMediaIndexPath)
        layoutNavBar()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = false
        collectionView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        lengthLabel.layer.opacity = 0
        currentTimeLabel.layer.opacity  = 0
        
        self.navigationController?.delegate = self
        self.navigationController?.transitioningDelegate = self
        self.view.layer.cornerRadius = Constant.standardCornerRadius
        
        gestureStatusToggle(isTopViewController: true)
        self.addPeriodicTimeObserver(indexPath: currentMediaIndexPath)
        
        [postTitleButton, itemTitleButton].forEach() {
            $0.addTarget(self, action: #selector(presentPostContent ( _ : )), for: .touchUpInside)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.panWholeViewGesture.isEnabled = false
        gestureStatusToggle(isTopViewController: false)
    }
    
    func configureData(post : Post) {
        
        currentPost = post
        self.postID = currentPost.id
        
        
        self.currentMediaIndexPath = IndexPath(row:  currentPost.CurrentIndex, section: 0)
        if let userImage = post.user?.image {
            self.userImageView.image = userImage
        } else {
            Task {
                let userImage = try await currentPost.user?.imageURL?.getImageFromURL()
                currentPost.user?.image = userImage
                self.userImageView.image = userImage
            }
        }
        self.pageControll.numberOfPages = currentPost.media.count
        if let image = currentPost.restaurant?.image {
            self.locationimageView.image = image
        } else if let restaurantImageURL = currentPost.restaurant?.imageURL {
            Task {
                let image = try await restaurantImageURL.getImageFromURL()
                self.locationimageView.image = image
                self.currentPost.restaurant?.image = image
            }
        } else {
            self.locationimageView.image = UIImage(systemName: "fork.knife.circle")!.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        
        if currentPost.postTitle == nil || currentPost.postTitle == "" {
            self.postTitleButton.isHidden = true
            
        }
        var hiddenItemTitleButton : Bool = true
        for media in currentPost.media {
            if media.title != nil && media.title != ""  {
                hiddenItemTitleButton = false
                break
            }
        }
        self.itemTitleButton.isHidden = hiddenItemTitleButton
        
        if self.postTitleButton.isHidden && self.itemTitleButton.isHidden {
            self.buttonHiddenStatus = .bothHidden
        } else if self.postTitleButton.isHidden && !self.itemTitleButton.isHidden {
            self.buttonHiddenStatus = .onlyPresentItemTitleButton
        } else if !self.postTitleButton.isHidden && self.itemTitleButton.isHidden {
            
            self.buttonHiddenStatus = .onlyPresentTitleButton
        } else {
            self.buttonHiddenStatus = .bothActive
        }
        
        if currentPost.postContent == nil {
            self.postTitleButton.isUserInteractionEnabled = false
            self.postTitleButton.animatedEnable = false
            self.itemTitleButton.animatedEnable = false
        } else {
            self.postTitleButton.isUserInteractionEnabled = true
        }
        
        
        
        if let grade = currentPost.grade {
            gradeLabel.text = String(grade)
        } else {
            gradeStackView?.removeFromSuperview()
            
            gradeStackView = nil
            
            NSLayoutConstraint.activate([
                self.userImageView.centerYAnchor.constraint(equalTo: self.resizeToggleButton.centerYAnchor)
            ])
        }
        configureHeartImage()
        
        if let image = self.currentPost.selfReaction?.reactionType?.reactionImage {
            self.currentEmojiTag = self.currentPost.selfReaction?.reactionInt
            self.updateEmojiButtonImage(image: image)
        }
        self.collectionView.performBatchUpdates(nil, completion: { bool in
            self.collectionView.scrollToItem(at: self.currentMediaIndexPath, at: .centeredHorizontally, animated: false)
        })
        if var titleConfig = postTitleButton.configuration,
           let titleString = currentPost.postTitle {
            var title = AttributedString(titleString )
            title.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
            titleConfig.attributedTitle = title
            postTitleButton.configuration  = titleConfig
        }
        
        if var itemTitleConfig = itemTitleButton.configuration {
            var itemtitle = AttributedString(currentPost.media[currentPost.CurrentIndex].title ?? "")
            itemtitle.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
            itemTitleConfig.baseForegroundColor = .black
            itemTitleConfig.attributedTitle = itemtitle
            itemTitleButton.configuration  = itemTitleConfig
        }
        
        
        postTitleButton.layoutIfNeeded()
        postTitleButtonBlurView = UIVisualEffectView(frame: postTitleButton.bounds, style: .systemUltraThinMaterialDark)
        postTitleButtonBlurView.isUserInteractionEnabled = false
        postTitleButton.insertSubview(postTitleButtonBlurView, belowSubview: postTitleButton.titleLabel!)
        
        itemTitleButton.layoutIfNeeded()
        var titleArray =  currentPost.media.compactMap { media in
            return media.title
        }
        if !titleArray.isEmpty {
            let attributes = [NSAttributedString.Key.font: UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)]
            titleArray = titleArray.sorted() { lhs, rhs in
                let lhsWidth = ( lhs as NSString).size(withAttributes: attributes).width
                let rhsWidth = ( rhs as NSString).size(withAttributes: attributes).width
                return lhsWidth > rhsWidth
            }
            
            let targetString = titleArray.first!
            let verTotalInset =  itemTitleButton.configuration!.contentInsets.top + itemTitleButton.configuration!.contentInsets.bottom
            let horTotalInset = itemTitleButton.configuration!.contentInsets.trailing + itemTitleButton.configuration!.contentInsets.leading
            var width = ( targetString as NSString).size(withAttributes: attributes).width + horTotalInset
            let bounds = UIScreen.main.bounds
            width = width > bounds.width * 0.2 ? width : bounds.width * 0.2
            itemTitleButtonBlurView = UIVisualEffectView(frame: CGRect(x: itemTitleButton.bounds.origin.x, y: itemTitleButton.bounds.origin.y, width: width, height: itemTitleButton.bounds.height), style: .light)
            itemTitleButtonBlurView.isUserInteractionEnabled = false
            itemTitleButton.insertSubview(itemTitleButtonBlurView, belowSubview: itemTitleButton.titleLabel!)
        }
        if !postTitleButton.isHidden {
            activeButton = postTitleButton
        } else {
            activeButton = itemTitleButton
        }
        
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonPanGesture (_ :)))
        
        postTitleButton.addGestureRecognizer(panGesture)
        
        let itemPaneGesture = UIPanGestureRecognizer(target: self, action: #selector(handleButtonPanGesture (_ :)))
        
        itemTitleButton.addGestureRecognizer(itemPaneGesture)
        self.itemTitleButton.isUserInteractionEnabled = false
        self.postTitleButton.isUserInteractionEnabled = false
        
        activeButton?.isUserInteractionEnabled = true
        
        
    }
    
    func configurePostTitleView() {
        if postTitleButton.isHidden && itemTitleButton.isHidden {
            return
        }
        
        [postTitleButton, itemTitleButton].forEach { button  in
            if let button = button  {
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.adjustsFontForContentSizeCategory = true
                button.clipsToBounds = true
                button.layer.cornerRadius = 15
                button.titleLabel?.numberOfLines = 3
                button.tintColor = .clear
                
                var configuration = UIButton.Configuration.filled()
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
                
                button.translatesAutoresizingMaskIntoConstraints = false
                
                button.configuration  = configuration
                button.titleLabel?.font =  UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
                button.scaleTargets?.append(contentsOf:  button.subviews)
            }
            
        }
        
        
        
    }
    
    func viewStyleSet() {
        definesPresentationContext = true
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.view.clipsToBounds = true
        self.collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        self.userImageView.translatesAutoresizingMaskIntoConstraints = false
        self.pageControll.hidesForSinglePage = true
        pageControll.currentPageIndicatorTintColor = .tintOrange
        self.pageControll.isUserInteractionEnabled = false
    }
    func layoutNavBar() {
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func layoutBlurView() {
        
        blurView = UIVisualEffectView(frame: self.collectionView.frame, style: .systemChromeMaterialDark)
        self.view.insertSubview(blurView, at: 0)
        blurView.isUserInteractionEnabled = true
    }
    
    func layout() {
        layoutImageView()
        layoutButtonConfig()
        layoutButtonItem()
        layoutSlider()
        layoutLabel()
        let bounds = self.view.bounds
        self.view.addSubview(collectionView)
        
        self.view.addSubview(bottomBarView)
        bottomBarView.backgroundColor = .black
        self.view.addSubview(progressSlider)
        self.view.addSubview(postTitleButton)
        self.view.addSubview(itemTitleButton)
        
        //right
        self.view.addSubview(pageControll)
        self.view.addSubview(lengthLabel)
        self.view.addSubview(resizeToggleButton)
        self.view.addSubview(collectButton)
        self.view.addSubview(shareButton)
        self.view.addSubview(emojiButton)
        
        self.view.addSubview(heartButton)
        
        // left
        self.view.addSubview(currentTimeLabel)
        self.view.addSubview(locationimageView)
        self.view.addSubview(userImageView)
        self.view.addSubview(gradeStackView)
        self.view.addSubview(soundImageBlurView)
        self.view.addSubview(soundImageView)
        
        
        let starImage = UIImage(systemName : "star.fill", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title3, weight: .regular)) )?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
        let starImageView = UIImageView(image: starImage)
        
        gradeStackView.addArrangedSubview(starImageView)
        gradeStackView.addArrangedSubview(gradeLabel)
        gradeStackView.axis = .vertical
        gradeStackView.spacing = 2
        gradeStackView.distribution = .fillProportionally
        
        
        self.view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            bottomBarView.heightAnchor.constraint(equalToConstant: Constant.bottomBarViewHeight),
            bottomBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomBarView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        NSLayoutConstraint.activate([
            progressSlider.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -1),
            progressSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            progressSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            postTitleButton.bottomAnchor.constraint(equalTo: self.bottomBarView.topAnchor, constant: -12),
            postTitleButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            postTitleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: bounds.width * 0.2),
            postTitleButton.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width * 0.6),
            postTitleButton.heightAnchor.constraint(greaterThanOrEqualToConstant: bounds.height * 0.05),
            itemTitleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: bounds.width * 0.2),
            itemTitleButton.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width * 0.6),
            itemTitleButton.heightAnchor.constraint(greaterThanOrEqualToConstant: bounds.height * 0.05),
            itemTitleButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            itemTitleButton.centerYAnchor.constraint(equalTo: postTitleButton.centerYAnchor),
            
            pageControll.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pageControll.widthAnchor.constraint(equalToConstant: bounds.width * 0.4),
            pageControll.bottomAnchor.constraint(equalTo: postTitleButton.topAnchor, constant: -8),
        ])
        
        NSLayoutConstraint.activate([
            resizeToggleButton.bottomAnchor.constraint(equalTo: self.bottomBarView.topAnchor, constant: -8),
            resizeToggleButton.widthAnchor.constraint(equalTo: resizeToggleButton.heightAnchor, multiplier: 1),
            collectButton.bottomAnchor.constraint(equalTo: resizeToggleButton.topAnchor, constant: -16),
            shareButton.bottomAnchor.constraint(equalTo: collectButton.topAnchor, constant: -20),
            emojiButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -20),
            
            heartButton.bottomAnchor.constraint(equalTo: emojiButton.topAnchor, constant: -16),
            heartButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 4),
            emojiButton.centerXAnchor.constraint(equalTo: heartButton.centerXAnchor),
            emojiButton.widthAnchor.constraint(equalTo: emojiButton.heightAnchor, multiplier: 1),
            shareButton.centerXAnchor.constraint(equalTo: heartButton.centerXAnchor),
            collectButton.centerXAnchor.constraint(equalTo: heartButton.centerXAnchor),
            resizeToggleButton.centerXAnchor.constraint(equalTo: heartButton.centerXAnchor),
            
        ])
        
        
        NSLayoutConstraint.activate([
            currentTimeLabel.bottomAnchor.constraint(equalTo: self.bottomBarView.topAnchor, constant: -16),
            currentTimeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            lengthLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            lengthLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            locationimageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            locationimageView.bottomAnchor.constraint(equalTo: self.userImageView.topAnchor, constant: -16),
            
            locationimageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            
            locationimageView.centerXAnchor.constraint(equalTo: gradeStackView.centerXAnchor),
            locationimageView.heightAnchor.constraint(equalTo: locationimageView.widthAnchor, multiplier: 1),
            userImageView.centerXAnchor.constraint(equalTo: gradeStackView.centerXAnchor),
            
            userImageView.bottomAnchor.constraint(equalTo: gradeStackView.topAnchor, constant: -20),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor, multiplier: 1),
            
            gradeStackView.centerYAnchor.constraint(equalTo: self.resizeToggleButton.centerYAnchor),
            gradeStackView.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor, constant: 30),
            userImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            
            soundImageView.widthAnchor.constraint(equalTo: locationimageView.widthAnchor, multiplier: 1.8),
            soundImageView.heightAnchor.constraint(equalToConstant: self.view.bounds.width * 0.06),
            soundImageView.centerXAnchor.constraint(equalTo: self.locationimageView.centerXAnchor),
            soundImageView.bottomAnchor.constraint(equalTo: locationimageView.topAnchor, constant: -20),
            soundImageBlurView.centerXAnchor.constraint(equalTo: soundImageView.centerXAnchor),
            soundImageBlurView.centerYAnchor.constraint(equalTo: soundImageView.centerYAnchor),
            soundImageBlurView.heightAnchor.constraint(equalTo: soundImageView.heightAnchor, multiplier: 1.7),
            soundImageBlurView.widthAnchor.constraint(equalTo: soundImageView.heightAnchor, multiplier: 1.7)
        ])
        
        
        self.view.layoutIfNeeded()
        soundImageBlurView.layer.cornerRadius = soundImageBlurView.bounds.height / 2
        
    }
    
    func layoutLabel() {
        currentTimeLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        currentTimeLabel.layer.opacity  = 0
        lengthLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        lengthLabel.layer.opacity = 0
        gradeLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
        gradeLabel.textColor = .white
    }
    
    func layoutImageView() {
        soundImageBlurView.layer.opacity = 0
        soundImageBlurView.backgroundColor = .clear
        soundImageBlurView.clipsToBounds = true
        soundImageView.contentMode = .scaleAspectFit
        soundImageView.tintColor = .white
        soundImageView.clipsToBounds = true
        soundImageView.layer.opacity = 0
        locationimageView.contentMode = .scaleAspectFill
        locationimageView.isUserInteractionEnabled = true
        locationimageView.clipsToBounds = true
        locationimageView.layer.cornerRadius = 8
        let locationImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(showRestaurantDetailViewController))
        locationimageView.addGestureRecognizer(locationImageViewGesture)
        
        userImageView.contentMode = .scaleAspectFill
        userImageView.backgroundColor = .clear
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 12
        userImageView.isUserInteractionEnabled = true
        let userImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(showUserProfile(_ :)))
        userImageView.addGestureRecognizer(userImageViewGesture)
    }
    
    
    func layoutButtonConfig() {
        
        var resizeConfig = UIButton.Configuration.filled()
        resizeConfig.image = UIImage(systemName: "arrow.down.forward.and.arrow.up.backward", withConfiguration: symbolConfig)
        resizeConfig.baseBackgroundColor = .clear
        resizeToggleButton.configuration = resizeConfig
        
        var collectConfig = UIButton.Configuration.filled()
        collectConfig.image = UIImage(systemName: "star", withConfiguration: symbolConfig)
        collectConfig.preferredSymbolConfigurationForImage = symbolConfig
        collectConfig.baseBackgroundColor = .clear
        collectButton.configuration = collectConfig
        collectButton.addTarget(self, action: #selector(presentAddCollectViewController( _ :)), for: .touchUpInside)
        
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.image = UIImage(systemName: "paperplane", withConfiguration: symbolConfig)
        shareConfig.baseBackgroundColor = .clear
        shareButton.configuration = shareConfig
        
        
        var heartConfig = UIButton.Configuration.filled()
        heartConfig.image = UIImage(systemName: "heart", withConfiguration: heartSymbolConfig)
        heartConfig.preferredSymbolConfigurationForImage = heartSymbolConfig
        heartConfig.imagePlacement = .top
        heartConfig.title = "0"
        heartConfig.baseBackgroundColor = .clear
        heartConfig.imagePadding = 4
        heartButton.configuration = heartConfig
        heartButton.addTarget(self, action: #selector( LikeToggle(_ :) ) , for: .touchUpInside)
        
        var emojiConfig = UIButton.Configuration.filled()
        emojiConfig.image = UIImage(systemName: "smiley")?.scale(newWidth: self.view.bounds.width * 0.1).withTintColor(.white, renderingMode: .alwaysOriginal)
        emojiConfig.baseForegroundColor = .white
        emojiConfig.baseBackgroundColor = .clear
        emojiButton.configuration = emojiConfig
        emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
        
    }
    
    
    
    func layoutButtonItem() {
        let style = UIFont.TextStyle.title3
        let backImage = UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: style, weight: .bold)))
        dismissButtonItem.image = backImage
        dismissButtonItem.target = self
        dismissButtonItem.action = #selector(dismissSelf)
        dismissButtonItem.tintColor = .white
        self.navigationItem.leftBarButtonItem = dismissButtonItem
        self.navigationItem.backButtonTitle = nil
    }
    
    func layoutSlider() {
        progressSlider.tintColor = .tintColor
        progressSlider.addTarget(self, action: #selector(changeCurrentTime( _ :)), for: .touchDragInside)
        progressSlider.addTarget(self, action: #selector(sliderTouchCompletion( _ :)), for: .touchUpInside)
        progressSlider.setThumbImage(UIImage(), for: .normal)
    }
    
    func registerCells() {
        self.collectionView.register(WholePlayerLayerCollectionCell.self , forCellWithReuseIdentifier: "WholePlayerLayerCollectionCell")
        self.collectionView.register(WholeImageViewCollectionCell.self, forCellWithReuseIdentifier: "WholeImageViewCollectionCell")
    }
    
    func getEmojiButtonConfig(image : UIImage) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        
        config.image = image.scale(newWidth: self.view.bounds.width * 0.1)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .clear
        return config
    }
    
    func changeCurrentEmoji(emojiTag: Int?) {
        return
    }
    
    func getFadedSubviews() -> [UIView]! {
        let array = view.subviews.filter { view in
            if view is UICollectionView || view == bottomBarView || view == self.blurView || self.soundImageViews.contains(view) {
                return false
            }
            return true
        }
        
        return array
    }
    
    func getPlayerSubviews() -> [UIView] {
        return [currentTimeLabel, lengthLabel, progressSlider]
    }
    func getFadeInSubviews() -> [UIView?] {
        return []
    }
    
    var enterCollectionIndexPath: IndexPath!
    
    func reloadCollectionCell(backCollectionIndexPath: IndexPath) {
        
        if let needReloadCell = self.collectionView.cellForItem(at: self.enterCollectionIndexPath) as? MediaCollectionCell {
            needReloadCell.reload(media: nil)
            
        }

    }
    
    func playCurrentMedia() {
        self.addPeriodicTimeObserver(indexPath: currentMediaIndexPath)
        if let cell = collectionView.cellForItem(at: currentMediaIndexPath ) as? WholePlayerLayerCollectionCell {
            cell.play()
        }
        
    }
    
    func pauseCurrentMedia() {
        if let cell = self.currentCollectionCell as? WholePlayerLayerCollectionCell {
            cell.pause()
        }
        self.removePeriodicTimeObserver(indexPath: currentMediaIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentPost.media.count
    }
    
    func collectionViewFlowSet() {
        let height = UIScreen.main.bounds.height - Constant.bottomBarViewHeight
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: view.frame.width, height: height)
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = flow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.currentPost.media[indexPath.row]
        if media.isImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WholeImageViewCollectionCell", for: indexPath) as! WholeImageViewCollectionCell
            cell.layoutImageView(media: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WholePlayerLayerCollectionCell", for: indexPath) as! WholePlayerLayerCollectionCell
            cell.layoutPlayerlayer(media: media)
            return cell
        }
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let bounds = UIScreen.main.bounds
        var maxWidth = bounds.width - 16
        var maxHeight : CGFloat! = bounds.height * 0.5
        if presented is LimitContainerViewHeightPresentedView  {
            
            return MaxFrameContainerViewPresentationController(presentedViewController: presented, presenting: presenting, maxWidth: maxWidth, maxHeight: maxHeight)
        }
        if presented is LimitSelfFramePresentedView {
            
            
            if presented is ShareViewController {
                maxHeight =  bounds.height * 0.7
            }
            
            return MaxFramePresentedViewPresentationController(presentedViewController: presented, presenting: presenting, maxWidth: maxWidth, maxHeight: maxHeight)
            
        }
        return nil
        
    }
    
    
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            playCurrentMedia()
        } else {
            pauseCurrentMedia()
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self.navigationController {
            
            self.panWholePageViewControllerwDelegate?.gestureStatusToggle(isTopViewController: true)
            
            if let mediaAnimatorDelegate = mediaAnimatorDelegate as? CollectionViewInTableViewMediaAnimatorDelegate {
                mediaAnimatorDelegate.tableView.isPagingEnabled = false
                if mediaAnimatorDelegate is PostTableViewController {
                    mediaAnimatorDelegate.tableView.isPagingEnabled = false
                } else {
                    mediaAnimatorDelegate.tableView.isPagingEnabled = true
                }
                
            }
            mediaAnimatorDelegate?.collectionView.isPagingEnabled = false
            mediaAnimatorDelegate?.collectionView.scrollToItem(at: self.currentMediaIndexPath, at: .centeredHorizontally, animated: false)
            mediaAnimatorDelegate?.collectionView.isPagingEnabled = true
            if self.navigationController?.topViewController == self {
                return  DismissWholePageMediaViewControllerAnimator(transitionToIndexPath: IndexPath(row: self.currentMediaIndexPath.row, section: mediaAnimatorDelegate!.enterCollectionIndexPath.section), toViewController: mediaAnimatorDelegate!, fromViewController: self)
            }
        }
        if dismissed is ShareViewController || dismissed is AddCollectViewController {
            self.playCurrentMedia()
        }
        return nil
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent is PostDetailSheetViewController {
            
        } else {
            self.pauseCurrentMedia()
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
    }
    
}

extension WholePageMediaViewController {
    @objc func emojiTargetTapped(_ button : UIButton) {
        let tag = button.tag
        if self.currentPost.selfReaction?.reactionInt == tag {
            currentEmojiTag = nil
        } else {
            currentEmojiTag = tag
        }
        self.currentPost.initNewReaction(reactionTag: currentEmojiTag, liked: currentPost.liked)
        if extendedEmojiBlurView == nil {
            startEmojiExtendAnimation()
        } else {
            wholePageMediaDelegate?.changeCurrentEmoji(emojiTag: currentEmojiTag)
            startReactionTargetAnimation(targetTag: currentEmojiTag)
        }
    }
    
    @objc func emojiButtonTapped() {
        if extendedEmojiBlurView == nil {
            startEmojiExtendAnimation()
        } else {
            self.tapToCloseExtendedView()
        }
        
    }
    
    func startEmojiExtendAnimation() {
        guard (extendedEmojiBlurView == nil) else {
            return
        }
        self.emojiButton.translatesAutoresizingMaskIntoConstraints = true
        self.emojiButton.isUserInteractionEnabled = false
        let bounds = view.bounds
        let emojiImageviewFrameInView = self.emojiButton.imageView!.superview!.convert(self.emojiButton.imageView!.frame, to: view)
        let blurViewWidth = bounds.width * 0.7
        let scaleY = 1.8
        let blurViewHeight = emojiImageviewFrameInView.height * scaleY
        let blurViewYOffset = emojiImageviewFrameInView.height * (scaleY - 1 )  / 2
        let blurViewXOffset : CGFloat = 12
        let frame = CGRect(origin: emojiImageviewFrameInView.origin, size: CGSize(width: blurViewWidth, height: blurViewHeight ))
        extendedEmojiBlurView = UIVisualEffectView(frame:  frame, style: .dark)
        guard let extendedEmojiBlurView = extendedEmojiBlurView else {
            return
        }
        extendedEmojiBlurView.translatesAutoresizingMaskIntoConstraints = true
        extendedEmojiBlurView.clipsToBounds = true
        
        extendedEmojiBlurView.alpha = 0
        
        let emojiImageViewCenterInView = self.emojiButton.superview!.convert(self.emojiButton.center, to: view)
        extendedEmojiBlurView.center.y = emojiImageViewCenterInView.y
        self.view.insertSubview(extendedEmojiBlurView, aboveSubview: self.collectionView)
        
        
        let zoomInTransform = CGAffineTransform(scaleX: 1, y: 1)
        
        let zoomOutTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        let targetBlurFrame = CGRect(x: emojiImageviewFrameInView.minX - extendedEmojiBlurView.frame.width - blurViewXOffset  , y:  extendedEmojiBlurView.frame.minY - blurViewYOffset, width: blurViewWidth, height: extendedEmojiBlurView.frame.height)
        
        emojiTargetButtons.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = true
            self.view.insertSubview($0, aboveSubview: extendedEmojiBlurView)
            $0.frame = emojiImageviewFrameInView
            $0.alpha = 0
            $0.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
        extendedEmojiBlurView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseOut, animations:  { [weak self] in
            guard let self = self else { return }
            extendedEmojiBlurView.transform = .identity
            extendedEmojiBlurView.frame = targetBlurFrame
            extendedEmojiBlurView.center.y = emojiImageViewCenterInView.y
            extendedEmojiBlurView.layer.cornerRadius = 20
            
            emojiButton.alpha = 1
            let tag = self.currentPost.selfReaction?.reactionInt
            let emojiTargetWidth =  (blurViewWidth - ( blurViewXOffset * 2 )) / 5
            self.emojiTargetButtons.forEach() {
                $0.transform = .identity
                let x = targetBlurFrame.minX + blurViewXOffset + ( emojiTargetWidth * CGFloat($0.tag) )
                
                $0.frame = CGRect(origin: .zero, size: CGSize(width: emojiTargetWidth, height: $0.frame.height))
                $0.center.y = emojiImageViewCenterInView.y
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
            self.emojiButton.isUserInteractionEnabled = true
        }
    }
    
    func updateEmojiButtonImage(image : UIImage?) {
        if var config = self.emojiButton.configuration {
            config.image = image?.scale(newWidth: self.view.bounds.width * 0.1)
            self.emojiButton.configuration = config
        }
        
    }
    
    func startReactionTargetAnimation(targetTag : Int?) {
        
        guard let extendedEmojiView = extendedEmojiBlurView else {
            return
        }
        self.emojiButton.isUserInteractionEnabled = false
        let frame = self.emojiButton.superview?.convert(emojiButton.frame, to: self.collectionView)
        let centerInFrame = self.emojiButton.superview?.convert(emojiButton.center, to: view)
        let newFrame = CGRect(x: frame!.minX, y: frame!.minY, width: frame!.width, height: frame!.height * 0.8)
        if targetTag == nil {
            if currentEmojiTag != nil {
                self.emojiButton.alpha = 0
            }
            self.updateEmojiButtonImage(image: UIImage(systemName: "smiley")?.withTintColor(.white, renderingMode: .alwaysOriginal))
            
        }
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseOut, animations:  {
            self.emojiTargetButtons.forEach() {
                if let targetTag = targetTag {
                    
                    self.emojiButton.alpha = 0
                    if $0.tag == targetTag {
                        $0.transform = .identity
                        $0.alpha = 1
                    } else {
                        $0.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        $0.alpha = 0
                    }
                } else {
                    
                    self.emojiButton.alpha = 1
                    $0.alpha = 0
                }
                
                $0.center = centerInFrame!
                
            }
            
            extendedEmojiView.frame = newFrame
            extendedEmojiView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            extendedEmojiView.alpha = 0
        }) { bool in
            self.emojiButton.alpha = 1
            if let int = targetTag {
                self.updateEmojiButtonImage(image: self.emojiTargetButtons[int].imageView?.image)
            }
            self.emojiTargetButtons.forEach() {
                $0.removeFromSuperview()
            }
            self.emojiTargetButtons.forEach() {
                $0.transform = .identity
            }
            
            self.extendedEmojiBlurView?.removeFromSuperview()
            self.extendedEmojiBlurView = nil
            self.emojiButton.isUserInteractionEnabled = true
        }
    }
    
}

extension WholePageMediaViewController {
    @objc func handleButtonPanGesture(_ recognizer : UIPanGestureRecognizer) {
        guard self.buttonHiddenStatus != .bothHidden else {
            return
        }
        if activeButton == self.postTitleButton {
            guard self.currentPost.media[self.currentMediaIndexPath.row].title != nil else {
                return
            }
        }
        let translation = recognizer.translation(in: activeButton)
        switch recognizer.state {
        case .began :
            if startX == nil {
                startX = activeButton?.center.x
            }
            break
        case .changed:
            activeButton?.translatesAutoresizingMaskIntoConstraints = true
            let deltaX = translation.x
            
            if deltaX > 3 || deltaX < -3 {
                isMovingButton = true
            }
            
            if isMovingButton, self.buttonHiddenStatus == .bothActive {
                if activeButton == postTitleButton {
                    let postTitleButtonCenterX = postTitleButton.center.x + deltaX
                    postTitleButton.center.x = postTitleButtonCenterX
                }
                
                if activeButton == itemTitleButton {
                    let itemTitleButtonCenterX =  itemTitleButton.center.x + deltaX
                    itemTitleButton.center.x = itemTitleButtonCenterX
                }
            }
            lastDeltaX = deltaX
            
        case .ended :
            if isMovingButton && activeButton!.center.x != self.view.center.x {
                var offsetX : CGFloat = 0
                if let startX = startX {
                    offsetX = self.activeButton!.center.x - startX
                }
                
                let thresholdX : CGFloat = 30
                var  targetButton : UIButton!
                if activeButton == postTitleButton {
                    targetButton = itemTitleButton
                } else {
                    targetButton = postTitleButton
                }
                if offsetX < -thresholdX || offsetX > thresholdX {
                    startButtonSwipeAnimated(toButton: targetButton, deltaX: lastDeltaX!)
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.activeButton?.center.x = self.view.center.x
                    }
                }
            }
            startX = nil
            break
        default:
            break
        }
        recognizer.setTranslation(.zero, in: itemTitleButton)
        recognizer.setTranslation(.zero, in: postTitleButton)
        
    }
    
    func updateButtonAlpha(fadeIn : UIButton?) {
        guard let fadeIn = fadeIn else {
            return
        }
        
        itemTitleButton.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25, animations : {
            fadeIn.subviews.forEach({ view in
                view.alpha = 1
            })
        }) { [weak self] bool in
            guard let self = self else {
                return
            }
            self.activeButton?.translatesAutoresizingMaskIntoConstraints = false
            self.activeButton?.layoutIfNeeded()
            if fadeIn == postTitleButton {
                self.itemTitleButton?.subviews.forEach({ view in
                    view.alpha = 0
                })
            } else {
                self.postTitleButton?.subviews.forEach({ view in
                    view.alpha = 0
                })
            }
            self.startX = nil
            self.activeButton = fadeIn
            fadeIn.isUserInteractionEnabled = true
        }
    }
    
    func startButtonSwipeAnimated(toButton : UIButton, deltaX : CGFloat) {
        activeButton?.translatesAutoresizingMaskIntoConstraints = true
        activeButton?.isUserInteractionEnabled = false
        let direction : CGFloat = deltaX > 0 ? 1 : -1
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.activeButton?.center.x += direction * self.view.bounds.width
        }
        
        
        animator.addCompletion { position in
            if position == .end {
                self.updateButtonAlpha(fadeIn: toButton)
            }
        }
        
        animator.startAnimation()
        
        
    }
}

extension WholePageMediaViewController {
    func updateCellPageControll(currentCollectionIndexPath indexPath: IndexPath) {
        
        setResizeButtonImageToggle( indexPath: indexPath)
        self.pageControll?.currentPage = indexPath.row
        
        
        detailSheetViewController?.updateItemTitleLabelText(index: indexPath.row)
        updateButtonAlpha(fadeIn: self.activeButton)
        guard let currentPost = currentPost else {
            return
        }
        currentPost.CurrentIndex = indexPath.row
        if var itemTitleConfig = itemTitleButton.configuration {
            let title = currentPost.media[indexPath.row].title  ??  "無"
            var itemtitle = AttributedString(title)
            itemtitle.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
            itemTitleConfig.baseForegroundColor = title == "無" || title == "" ? .secondaryLabelColor : .black
            itemTitleConfig.attributedTitle = itemtitle
            itemTitleButton.configuration  = itemTitleConfig
        }
        if currentPost.media[indexPath.row].isImage  {
            self.mutedAllgesture.isEnabled = false
            self.progressSlider.isHidden = true
            self.currentTimeLabel.isHidden = true
            self.lengthLabel.isHidden = true
        } else {
            self.mutedAllgesture.isEnabled = true
            self.progressSlider.isHidden = false
            self.currentTimeLabel.isHidden = false
            self.lengthLabel.isHidden = false
        }
    }
    
    func updateMediaIndex(currentCollectionIndexPath indexPath: IndexPath) {
        if indexPath != currentMediaIndexPath {
            self.pauseCurrentMedia()
        }
        removePeriodicTimeObserver(indexPath : currentMediaIndexPath)
        self.currentMediaIndexPath = indexPath
        self.playCurrentMedia()
        addPeriodicTimeObserver(indexPath: indexPath)
    }
    
    func configureHeartImage() {
        
        let config = UIImage.SymbolConfiguration.init(font: .preferredFont(forTextStyle: .title1))
        heartButton.setPreferredSymbolConfiguration(config, forImageIn: .application)
        
        let heartImage = currentPost.liked ? UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal) : UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        heartButton.configuration?.image = heartImage
        
        self.heartButton.setTitle( String(currentPost.likedTotal), for: .normal )
    }
}

extension WholePageMediaViewController {
    
    
    func gestureStatusToggle(isTopViewController : Bool ) {
        if isTopViewController {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            dismissTapGesture.isEnabled = false
            panWholeViewGesture.isEnabled = true
        } else {
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            dismissTapGesture.isEnabled = true
            panWholeViewGesture.isEnabled = false
        }
    }
    
    func recoverInteraction() {
        dismissTapGesture.isEnabled = false
        panWholeViewGesture.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
}

extension WholePageMediaViewController {
    
    @objc func presentAddCollectViewController(_ gesture : UITapGestureRecognizer) {
        
        let viewController = AddCollectViewController()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        self.present(viewController, animated: true)
    }
    
    @objc func adjustMediaContentMode(_ button : UIButton) {
        if let cell = collectionView.cellForItem(at: currentMediaIndexPath) as? WholeImageViewCollectionCell {
            if cell.imageView.contentMode == .scaleAspectFill {
                cell.imageView.contentMode = .scaleAspectFit
            } else {
                cell.imageView.contentMode = .scaleAspectFill
            }
        } else if let cell = collectionView.cellForItem(at: currentMediaIndexPath) as? WholePlayerLayerCollectionCell {
            if cell.playerLayer.videoGravity == .resizeAspectFill {
                cell.playerLayer.videoGravity = .resizeAspect
            } else {
                cell.playerLayer.videoGravity = .resizeAspectFill
            }
        }
        setResizeButtonImageToggle(indexPath: currentMediaIndexPath)
    }
}

extension WholePageMediaViewController {
    
    
    
    @objc func presentShareViewController(_ gesture : UITapGestureRecognizer) {
        let viewController =  SharePostViewController(post: currentPost)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        self.present(viewController, animated: true)
    }
    @objc func showRestaurantDetailViewController() {
        let controller = RestaurantDetailViewController(presentForTabBarLessView: presentForTabBarLessView, restaurant:  self.currentPost.restaurant)
        self.show(controller, sender: nil)
    }
    
    @objc func dismissSelf() {
        dismissButtonItem.isHidden = true
        self.dismiss(animated: true) {
            BasicViewController.shared.swipeDatasourceToggle(navViewController: self.mediaAnimatorDelegate?.navigationController as? UINavigationController)
            
        }
    }
    
    @objc func dismissPresentedView() {
        
        recoverInteraction()
        self.dismiss(animated: true)
    }
    
    @objc func showUserProfile( _ imageView : UIImageView) {
        let controller = MainUserProfileViewController(presentForTabBarLessView: presentForTabBarLessView, user: self.currentPost.user, user_id: self.currentPost.user?.id)
        controller.navigationItem.title = currentPost.user?.name
        self.show(controller, sender: nil)
    }
    
    
    @objc func presentPostContent(_ button : UIButton) {
        if currentPost.postContent == nil {
            return
        }
        let storyboard = UIStoryboard(name: "ReuseViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostDetailSheetViewController") as! PostDetailSheetViewController
        detailSheetViewController = controller
        controller.postDetailSheetViewControllerDelegate = self
        controller.configure(post: currentPost)
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = self
        gestureStatusToggle(isTopViewController: false)
        self.present(controller, animated: true)
    }
}

extension WholePageMediaViewController {
    @objc func pausePlayingnowplayer( _ sender : UITapGestureRecognizer ) {
        let fadedSubviews = getFadedSubviews()
        if sender.state == .began {
            self.pauseCurrentMedia()
            UIView.animate(withDuration: 0.1) {
                fadedSubviews?.forEach { view in
                    
                    view.layer.opacity = 0
                }
            }
        } else if sender.state == .ended {
            self.playCurrentMedia()
            UIView.animate(withDuration: 0.1) {
                fadedSubviews?.forEach { view in
                    if fadedSubviews?.contains(view) == true && view is UILabel  {
                        return
                    }
                    view.layer.opacity = 1
                }
            }
            
            
        }
        
    }
    func setResizeButtonImageToggle(indexPath : IndexPath) {
        let zoomInImage =  UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)) )
        let zoomOutImage =  UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)) )
        if let cell = collectionView.cellForItem(at: indexPath) as? WholeImageViewCollectionCell {
            if cell.imageView.contentMode == .scaleAspectFill {
                self.resizeToggleButton.setImage( zoomInImage, for: .normal)
            } else {
                self.resizeToggleButton.setImage( zoomOutImage, for: .normal)
            }
        } else  if let cell = collectionView.cellForItem(at: indexPath) as? WholePlayerLayerCollectionCell  {
            if cell.playerLayer.videoGravity == .resizeAspectFill {
                self.resizeToggleButton.setImage( zoomInImage  , for: .normal)
            } else {
                self.resizeToggleButton.setImage(zoomOutImage , for: .normal)
            }
        }
    }
    
    func fadeInPlayerSubviews(fadeIn : Bool) {
        var fadedSubviews = getFadedSubviews()
        let playerSubviews = getPlayerSubviews()
        fadedSubviews = fadedSubviews?.filter({ view in
            if view is UISlider || view.tag == 6 || view.tag == 5   {
                return false
            }
            return true
        })
        if !isSlidingPlayer && fadeIn {
            isSlidingPlayer = true
            UIView.animate(withDuration: 0.1) {
                fadedSubviews?.forEach({ view in
                    if playerSubviews.contains(view) == true {
                        return
                    }
                    view.layer.opacity = 0
                })
                playerSubviews.forEach({ view in
                    view.layer.opacity = 1
                })
            }
        } else if isSlidingPlayer && !fadeIn {
            UIView.animate(withDuration: 0.1, animations: {
                fadedSubviews?.forEach({ view in
                    view.layer.opacity = 1
                })
                playerSubviews.forEach({ view in
                    if view is UISlider  {
                        return
                    }
                    view.layer.opacity = 0
                })
            }) { finish in
                self.isSlidingPlayer = false
            }
        }
    }
}

extension WholePageMediaViewController {
    @objc func changeCurrentTime(_ uislider : UISlider) {
        fadeInPlayerSubviews(fadeIn: true)
        self.pauseCurrentMedia()
        let targetTime: CMTime =  CMTimeMakeWithSeconds(Float64(progressSlider.value), preferredTimescale: 600)
        let timeString = formatConversion(time: Float(targetTime.seconds))
        self.currentTimeLabel.text = timeString
        if let cell = collectionView.cellForItem(at: currentMediaIndexPath) as? WholePlayerLayerCollectionCell {
            cell.playerLayer.player?.seek(to: targetTime)
        }
    }
    @objc func sliderTouchCompletion(_ UISlider : UISlider) {
        self.playCurrentMedia()
        fadeInPlayerSubviews(fadeIn: false)
    }
    
    func formatConversion(time: Float) -> String {
        let songLength = Int(time)
        let minutes = Int(songLength / 60)
        let seconds = Int(songLength % 60)
        var time = ""
        if minutes < 10 {
            time = "0\(minutes):"
        } else {
            time = "\(minutes)"
        }
        if seconds < 10 {
            time += "0\(seconds)"
        } else {
            time += "\(seconds)"
        }
        return time
    }
    
    func addPeriodicTimeObserver(indexPath : IndexPath) {
        guard timeObserverToken == nil else {
            return
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? WholePlayerLayerCollectionCell,
           cell.playerLayer != nil {
            
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let time = CMTime(seconds: 0.001, preferredTimescale: timeScale)
            
            self.timeObserverToken = cell.playerLayer.player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
                guard let self = self else {
                    return
                }
                let songCurrentTime = cell.playerLayer.player?.currentItem?.currentTime()
                
                if let seconds = songCurrentTime?.seconds {
                    let currentTimeInSec = self.formatConversion(time: Float(seconds))
                    self.progressSlider.value = Float(seconds)
                    self.currentTimeLabel.text = currentTimeInSec
                }
            }
            
            Task {
                let duration = try await cell.playerLayer.player?.currentItem?.asset.load(.duration)
                let second = CMTimeGetSeconds(duration!)
                self.progressSlider.maximumValue = Float(second)
                let totalTimeInSec = self.formatConversion(time: Float(second))
                self.lengthLabel.text = totalTimeInSec
            }
            progressSlider.minimumValue = 0
            progressSlider.isContinuous = false
            let songCurrentTime = cell.playerLayer.player?.currentItem?.currentTime()
            let seconds = CMTimeGetSeconds(songCurrentTime!)
            let currentTimeInSec = self.formatConversion(time: Float(seconds))
            self.progressSlider.value = Float(seconds)
            self.currentTimeLabel.text = currentTimeInSec
            cell.play()
        }
    }
    
    func removePeriodicTimeObserver(indexPath : IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WholePlayerLayerCollectionCell {
            if let timeObserverToken = timeObserverToken {
                cell.playerLayer.player?.removeTimeObserver(timeObserverToken)
            }
            timeObserverToken = nil
            
        }
        
        
    }
    
    
}

extension WholePageMediaViewController {
    
    @objc func updateVisibleCellsMuteStatus(_ sender : UITapGestureRecognizer) {
        guard currentCollectionCell is PlayerLayerCollectionCell else {
            return
        }
        cacelTimer()
        UniqueVariable.IsMuted.toggle()
        soundImageView.image = UniqueVariable.IsMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.wave.2.fill")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateVisibleCellsMuteStatus( _ :) ), object: nil)
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.soundImageViews.forEach() {
                $0.layer.opacity = 1
            }
        }) { bool in
            self.startSoundImageViewsOpacityTimer()
        }
        
        
        updateVisibleCellsMuteStatus()
    }
    
    func startSoundImageViewsOpacityTimer() {
        soundImageViewsOpacityTimer = DispatchSource.makeTimerSource(queue: .main)
        soundImageViewsOpacityTimer?.schedule(deadline: .now() + 1)
        soundImageViewsOpacityTimer?.setEventHandler() { [weak self] in
            guard let self = self else {
                return
            }
            
            UIView.animate(withDuration: 0.2, animations:  {
                self.soundImageViews.forEach() {
                    $0.layer.opacity = 0
                }
            })
        }
        soundImageViewsOpacityTimer?.resume()
    }
    
    func cacelTimer() {
        soundImageViewsOpacityTimer?.cancel()
        soundImageViewsOpacityTimer = nil
    }
    
    func updateVisibleCellsMuteStatus() {
        for cell in collectionView.visibleCells {
            if let cell = cell as? WholePlayerLayerCollectionCell {
                cell.updateMuteStatus()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playCurrentMedia()
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentWidth = scrollView.contentSize.width
        let offsetX = scrollView.contentOffset.x
        let tableViewWidth = scrollView.bounds.size.width
        if offsetX > contentWidth - tableViewWidth {
            return
        }
        
        let diffX = scrollView.contentOffset.x - previousOffsetX
        if offsetX <= 0 {
            previousOffsetX = offsetX
            return
        }
        let bool = diffX > 0 ? true  : false
        scrollToUpdateIndexPath(scrollingToRight: bool )
        previousOffsetX = scrollView.contentOffset.x
    }
    
    func scrollToUpdateIndexPath(scrollingToRight : Bool) {
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                return
            }
            if scrollingToRight {
                let collectionViewFrameInTableView = collectionView.convert(cell.contentView.frame, from: cell.contentView.superview)
                let frame = CGRect(x: collectionViewFrameInTableView.origin.x , y: collectionViewFrameInTableView.origin.y, width: collectionViewFrameInTableView.width * 2 / 3, height: collectionViewFrameInTableView.height)
                
                let intersects = collectionView.bounds.contains(frame)
                //往右滑 cell露左半2/3就是true
                if intersects {
                    if self.currentMediaIndexPath < indexPath {
                        updateCellPageControll(currentCollectionIndexPath: indexPath)
                        updateMediaIndex(currentCollectionIndexPath: indexPath   )
                    }
                }
            } else {
                let collectionViewFrameInTableView = collectionView.convert(cell.contentView.frame, from: cell.contentView.superview)
                let frame = CGRect(x: collectionViewFrameInTableView.origin.x + collectionViewFrameInTableView.width * 1 / 3, y: collectionViewFrameInTableView.origin.y, width: collectionViewFrameInTableView.width * 2 / 3, height: collectionViewFrameInTableView.height)
                
                let intersects = collectionView.bounds.contains(frame)
                //往左滑 cell露右半2/3就是true
                if intersects {
                    if self.currentMediaIndexPath > indexPath {
                        updateCellPageControll(currentCollectionIndexPath: indexPath)
                        updateMediaIndex(currentCollectionIndexPath: indexPath   )
                    }
                }
            }
        }
    }
    
    @objc func LikeToggle(_ button: UIButton) {
        self.currentPost.liked.toggle()
        setHeartTotal()
        setHeartImage()
        if canPostReaction {
            currentPost.initNewReaction(reactionTag : nil, liked : currentPost.liked )
        }
    }
    
    func setHeartTotal() {
        if currentPost.liked {
            currentPost.likedTotal += 1
        } else {
            currentPost.likedTotal -= 1
        }
        heartButton.setTitle(String(currentPost.likedTotal), for: .normal)
    }
    
    func setHeartImage() {
        if currentPost.liked {
            self.heartButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            self.heartButton.setImage(UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    
    
    @objc func tapToCloseExtendedView() {
        startReactionTargetAnimation(targetTag: currentEmojiTag)
    }
    
    
    @objc func DoubleLike() {
        let lastLike = currentPost.liked
        self.currentPost.liked = true
        if currentPost.liked != lastLike {
            setHeartTotal()
        }
        setHeartImage()
        if canPostReaction {
            currentPost.initNewReaction(reactionTag : nil, liked : currentPost.liked )
        }
    }
    
}

extension WholePageMediaViewController {
    @objc func handlePanGestureToDismiss(_ recognizer: UIPanGestureRecognizer) {
        guard let navView = self.navigationController?.view else {
            return
        }
        let translation = recognizer.translation(in: navView)
        switch recognizer.state {
        case .began :
            UIView.animate(withDuration: 0.1, animations: {
                self.navigationController?.navigationBar.layer.opacity = 0
            })
            mediaAnimatorDelegate?.collectionView.isPagingEnabled = false
            mediaAnimatorDelegate?.collectionView.scrollToItem(at: self.currentMediaIndexPath, at: .centeredHorizontally, animated: false)
            mediaAnimatorDelegate?.collectionView.isPagingEnabled = true
            
            break
        case .changed:
            let deltaY = translation.y
            
            if deltaY > 3 || deltaY < -3 {
                isMovingView = true
            }
            if isMovingView {
                mediaAnimatorDelegate?.collectionView.cellForItem(at: self.currentMediaIndexPath)?.contentView.isHidden = true
                
                let deltaX = translation.x
                navView.frame.origin.x += deltaX
                navView.frame.origin.y += deltaY
                let centerInScreen = navView.superview!.convert(navView.center, to: nil)
                let offset = abs(centerInScreen.x - UIScreen.main.bounds.width / 2 )
                let scale = 1 - ( offset * 0.8 / UIScreen.main.bounds.width / 2 )
                let transForm = CGAffineTransform(scaleX: scale , y: scale)
                navView.transform = transForm
            }
        case .ended :
            let frame = navView.frame
            let xOffset : CGFloat = 30
            let yOffset : CGFloat = 60
            if (frame.origin.y > yOffset || frame.origin.y < -yOffset  || frame.origin.x > xOffset || frame.origin.x < -xOffset) && isMovingView {
                dismissSelf()
            } else {
                self.startViewBackAnimate(x: frame.minX, y: frame.minY)
            }
        default:
            dismissSelf()
        }
        recognizer.setTranslation(.zero, in: navView)
    }
    
    func startViewBackAnimate(x: CGFloat, y : CGFloat) {
        let bounds = UIScreen.main.bounds
        isMovingView = false
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
            self.navigationController?.view.transform = .identity
            self.navigationController?.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            
        }) { bool in
            UIView.animate(withDuration: 0.1, animations: {
                self.navigationController?.navigationBar.layer.opacity = 1
            })
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { bool in
            
        }
    }
    @objc func recoverButton( _ sender : UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
}










