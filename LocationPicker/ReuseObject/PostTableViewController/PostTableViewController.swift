import UIKit
import AVFoundation


class PostTableViewController : MainPostTableViewController, StandardPostCellDelegate, PanWholePageViewControllerDelegate {
    
    var panViewGesture : UIPanGestureRecognizer! = UIPanGestureRecognizer()
    
    var isMovingView : Bool = false
    
    func cellRowHeightSizeFit() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    init(presentForTabBarLessView : Bool) {
        super.init(nibName: nil, bundle: nil)
        self.presentForTabBarLessView = presentForTabBarLessView
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var defaultLeftBarButtonItem : UIBarButtonItem! = UIBarButtonItem()
    
    var canScrollAction : Bool! = false
    
    var dismissButton : UIBarButtonItem! = UIBarButtonItem()
    
    weak var postsTableDelegate : PostsTableForGridPostCellViewDelegate?
    
    @objc func dismissSelf() {
        self.dismiss(animated: true) {

            BasicViewController.shared.swipeDatasourceToggle(navViewController: self.postsTableDelegate?.navigationController ?? self.navigationController)
        }
    }
    
    
    override func viewSetup() {
        super.viewSetup()
        tableView.delaysContentTouches = false

        self.tableView.backgroundColor = UIColor.backgroundPrimary
        if self.presentForTabBarLessView {
            self.tableView.contentInset = .init(top: 0, left: 0, bottom: 0 , right: 0)
        } else {
        
            self.tableView.contentInset = .init(top: 0, left: 0, bottom: Constant.bottomBarViewHeight - Constant.safeAreaInsets.bottom , right: 0)
        }
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .secondaryBackgroundColor
        tableView.separatorInset = Constant.standardTableViewInset
        self.view.backgroundColor = .backgroundPrimary
        tableViewBottomAnchor.constant = 0
    }
    
    @objc func closeCurrentEmojiView() {
        for cell in self.tableView.visibleCells {
            if let cell = cell as? StandardPostTableCell {
                cell.startReactionTargetAnimation(targetTag: cell.currentEmojiTag)
            }
        }
    }

    var previousOffsetY : CGFloat! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture()
        self.view.layoutIfNeeded()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: self.currentTableViewIndexPath, at: .top, animated: false)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gestureStatusToggle(isTopViewController: false)
    }
    
    

    
    override func barButtonItemSetup() {
        return
    }
    
    
    override func registerTableCell() {
        super.registerTableCell()
        self.tableView.register(StandardPostTableCell.self, forCellReuseIdentifier: "StandardPostTableCell")
        self.tableView.register(StandardPostTitleTableCell.self, forCellReuseIdentifier: "StandardPostTitleTableCell")
        self.tableView.register(StandardPostContentTableCell.self, forCellReuseIdentifier: "StandardPostContentTableCell")
        self.tableView.register(StandardPostAllTextTableCell.self, forCellReuseIdentifier: "StandardPostAllTextTableCell")
    }
    
    override func presentWholePageMediaViewController(post: Post?) {
        guard let post = post else {
            return
        }
        if let currentPostIndex = self.posts.firstIndex(of: post) {
            let indexPath = IndexPath(row: currentPostIndex, section: self.currentTableViewIndexPath.section)
            self.currentTableViewIndexPath = indexPath
        }
        let controller = WholePageMediaViewController(presentForTabBarLessView: self.presentForTabBarLessView, post: post)
        let navController = SwipeEnableNavViewController(rootViewController: controller)
        controller.mediaAnimatorDelegate = self
        controller.currentMediaIndexPath = tableViewCurrentCell?.currentMediaIndexPath
        controller.panWholePageViewControllerwDelegate = self
        controller.reactionDelegate = tableViewCurrentCell
        navController.modalPresentationStyle = .overFullScreen
        navController.transitioningDelegate = self
        navController.delegate = self
        canScrollAction = false
        self.present(navController, animated: true) {
            self.tableView.scrollToRow(at: self.currentTableViewIndexPath, at: .top, animated: false)
            BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
            self.canScrollAction = true
        }
    }
    

    override var tableViewCurrentCell : StandardPostTableCell? {
        guard let cell = tableView.cellForRow(at: currentTableViewIndexPath) as? StandardPostTableCell else {
            return nil
        }
        return cell
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        canScrollAction = true
        gestureStatusToggle(isTopViewController: true)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled  = false
        self.navigationController?.delegate = self
        self.navigationController?.transitioningDelegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissButton.image = UIImage(systemName: "chevron.left", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)))
        dismissButton.target = self
        dismissButton.action = #selector(dismissSelf)
        configureNavBar(title: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pauseCurrentMedia()
    }
    
    deinit {
        let deinitPost = posts[currentTableViewIndexPath.row]
        postsTableDelegate?.tempModifiedPostsWithMediaCurrentIndex[deinitPost.id] = (deinitPost, deinitPost.CurrentIndex)
        
        posts.forEach() { post in
            if let currentIndex = postsTableDelegate?.tempModifiedPostsWithMediaCurrentIndex[post.id]?.1 {
                post.CurrentIndex = currentIndex
                
            } else {
                post.CurrentIndex = 0
            }
        }
        
    }

    
    override func initRefreshControl() {
        
    }
    
    override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self.navigationController {
            if self.navigationController?.topViewController == self {
                if let toViewController = postsTableDelegate {
                    return  DismissPostTableViewAnimator(transitionToIndexPath: self.currentTableViewIndexPath, toViewController: toViewController, fromViewController: self)
                }
            }
        }
        
        return nil
    }
        
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        gestureStatusToggle(isTopViewController: false)
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func gestureStatusToggle(isTopViewController : Bool) {
        if isTopViewController {
            self.panViewGesture.isEnabled = true
        } else {
            self.panViewGesture.isEnabled = false
        }
    }
    
    override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            self.gestureStatusToggle(isTopViewController: true)
        } else {
            self.gestureStatusToggle(isTopViewController: false)
        }
            
    }
    
    
    override func getFadedSubviews() -> [UIView]! {
        var array = self.view.subviews.filter { view in
            if let soundArray = self.tableViewCurrentCell?.currentSoundImageView {
                if soundArray.contains(where: {
                    $0 == view
                }) {
                    return false
                }
            }
            if view == tableViewCurrentCell?.collectionView {
                return false
            }
            return true
        }
        array.append(self.view)
        return array
    }
    
    override func getFadeInSubviews() -> [UIView?] {
        let target = self.tableViewCurrentCell?.currentSoundImageView
        return target ?? []
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        var cell : StandardPostTableCellProtocol!
        if post.postTitle != nil && post.postContent == nil {
            let cellIdentifier = "StandardPostTitleTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostTitleTableCell
        } else if post.postTitle == nil && post.postContent != nil  {
            let cellIdentifier = "StandardPostContentTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostContentTableCell
        } else if post.postTitle != nil && post.postContent != nil {
            let cellIdentifier = "StandardPostAllTextTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostAllTextTableCell
        } else {
            let cellIdentifier = "StandardPostTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostTableCell
        }
        cell.standardPostCellDelegate = self
        cell.mediaTableCellDelegate = self
        cell.collectionViewHeight = Constant.standardMinimumTableCellCollectionViewHeight
        cell.configureData(post: post)

        return cell
            
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableViewRowHeightSet() {
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func titleButtonSetup() {
        
    }
    
    override func refreshPosts() {
        
    }
    
    var closeCurrentEmojiViewTapGesture : UITapGestureRecognizer!
    
    func setGesture() {
        panViewGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureToDismiss(_:)))
        panViewGesture.cancelsTouchesInView = true
        self.navigationController?.view.addGestureRecognizer(panViewGesture)
        closeCurrentEmojiViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeCurrentEmojiView))
        closeCurrentEmojiViewTapGesture.cancelsTouchesInView = true
        self.navigationController?.view.addGestureRecognizer(closeCurrentEmojiViewTapGesture)
        self.view.addGestureRecognizer(closeCurrentEmojiViewTapGesture)
    }

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canScrollAction else {
            return
        }
        
         updateVisibleCellsMuteStatus()

        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let tableViewHeight = scrollView.bounds.size.height
        if offsetY > contentHeight - tableViewHeight {
            return
        }
        let diffY = scrollView.contentOffset.y - previousOffsetY
        if scrollView.contentOffset.y <= 0 {
            previousOffsetY = scrollView.contentOffset.y
            return
        }
        
        scrollToUpdateIndexPath(diffY: diffY )
        previousOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        closeCurrentEmojiView()
    }
    
    func scrollToUpdateIndexPath(diffY : CGFloat) {
        let visibleCells = tableView.visibleCells
        for cell in visibleCells {
            guard let indexPath = tableView.indexPath(for: cell),
                  let cell = cell as? MainPostTableCell else {
                continue
            }
            let collectionViewFrameInTableView = tableView.convert(cell.collectionView.frame, from: cell.collectionView.superview)
            if diffY < 0 {
                let frame = collectionViewFrameInTableView
                //collectoinView只露下半2/3就是true
                //往上
                let intersects = tableView.bounds.contains(frame)
                if intersects {
                    
                    if self.currentTableViewIndexPath > indexPath {
                        self.pauseCurrentMedia()

                        self.currentTableViewIndexPath = indexPath
                        self.playCurrentMedia()
                    }
                }
                
            } else {
                let frame = collectionViewFrameInTableView
                //collectoinView只露上半1/3就是true
                //往下
                let intersects = tableView.bounds.contains(frame)
                
                if intersects {
                    
                    if self.currentTableViewIndexPath < indexPath {
                        self.pauseCurrentMedia()

                        self.currentTableViewIndexPath = indexPath
                        self.playCurrentMedia()
                    }
                }
                
            }
        }
    }

    func configureNavBar(title : String? ) {
        let image = UIImage(systemName: "chevron.backward", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)))?.withAlignmentRectInsets(UIEdgeInsets(top: 0 , left: 0, bottom: 0, right: 0)).withTintColor(.label, renderingMode: .alwaysOriginal)
        defaultLeftBarButtonItem.image = image
        defaultLeftBarButtonItem.target = self
        defaultLeftBarButtonItem.action = #selector(dismissSelf)
        self.navigationItem.leftBarButtonItem = defaultLeftBarButtonItem
        if let title = title {
            self.navigationItem.title = title
        }
    }
    


}

extension PostTableViewController  {
    @objc func handlePanGestureToDismiss(_ recognizer: UIPanGestureRecognizer) {
        guard let navView = self.navigationController?.view else {
            return
        }
        
        let translation = recognizer.translation(in: navView)
        switch recognizer.state {
        case .began :
            if let postsTableDelegate = postsTableDelegate {
                let toCollectionIndexPath = IndexPath(row: self.currentTableViewIndexPath.row, section: postsTableDelegate.enterCollectionIndexPath.section)
                postsTableDelegate.collectionView.isPagingEnabled = false
                postsTableDelegate.collectionView.scrollToItem(at: toCollectionIndexPath, at: .centeredVertically, animated: false)
                postsTableDelegate.hiddenWillBackCollectionCell(hiddenIndexPath: toCollectionIndexPath)
                postsTableDelegate.changeMediaCollectionCellImage(needChangedCollectionIndexPath: toCollectionIndexPath, currentMediaIndexPath: self.currentMediaIndexPath)
            }
        
        case .changed:
            let deltaY = translation.y
            let deltaX = translation.x
            
            if deltaY > 2 || deltaY < -2 || deltaX > 2 || deltaX < -2 {
                if !isMovingView {
                    self.view.subviews.forEach { view in
                        view.translatesAutoresizingMaskIntoConstraints = true
                    }
                }

                isMovingView = true
            }
            if isMovingView {
                let deltaX = translation.x
                navView.frame.origin.x += deltaX
                navView.frame.origin.y += deltaY
                let centerInScreen = navView.superview!.convert(navView.center, to: nil)
                let offset = abs(centerInScreen.x - UIScreen.main.bounds.width / 2 )
                let scale = 1 - ( offset * 0.8 / UIScreen.main.bounds.width / 2 )
                let transForm = CGAffineTransform(scaleX: scale , y: scale)
                navView.transform = transForm
            }
            recognizer.setTranslation(.zero, in: navView)
        case .ended :

            let frame = navView.frame
            let xOffset : CGFloat = 30
            let yOffset : CGFloat = 60
            if (frame.origin.y > yOffset || frame.origin.y < -yOffset  || frame.origin.x > xOffset || frame.origin.x < -xOffset) && isMovingView {
                dismissSelf()
            } else {
                self.startViewBackAnimate(x: frame.minX, y: frame.minY)
            }
            recognizer.setTranslation(.zero, in: navView)
        default:
            break
        }
    }
    
    
    func startViewBackAnimate(x: CGFloat, y : CGFloat) {
        isMovingView = false
        let bounds = UIScreen.main.bounds
        let indexPath = IndexPath(row: self.currentTableViewIndexPath.row, section: postsTableDelegate?.enterCollectionIndexPath.section ?? 0)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, animations: {
            self.navigationController?.view.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
            self.navigationController?.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        }) { bool in
            if let postsTableDelegate = self.postsTableDelegate {
                postsTableDelegate.reloadCollectionCell(backCollectionIndexPath: indexPath)
            }
        }
    }
}
