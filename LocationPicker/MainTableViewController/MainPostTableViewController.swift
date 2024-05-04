import UIKit
import AVFoundation

class MainPostTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, MediaTableCellDelegate, CollectionViewInTableViewMediaAnimatorDelegate, MediaTableViewCellDelegate {
    
    enum MainTablePostsStatus {
        case PublicNear
        case FriendsNear
        case FriendsCreatedTime
        func getPosts(user_id : String , distance : Double, date : String) async throws -> [Post] {
            var results : [Post] = []
            do {
                switch self {
                case .PublicNear :
                    results =  try await PostManager.shared.getPublicNearLocationPosts(distance: distance)
                case .FriendsNear :
                    results = try await PostManager.shared.getFriendsNearLocationPosts(user_id: user_id, distance: distance)
                case .FriendsCreatedTime :
                    results = try await PostManager.shared.getFriendsPostsByCreatedTime(user_id: user_id, date: date)
                }
            } catch {
                throw error
            }
            return results
        }
        
        var titleString : String! {
            switch self {
            case .PublicNear :
                return "Public"
            case .FriendsNear :
                return "Friend"
            case .FriendsCreatedTime :
                return "Friend"
            }
        }
        
        var subTitleString : String! {
            switch self {
            case .PublicNear :
                return "By Near"
            case .FriendsNear :
                return "By Near"
            case .FriendsCreatedTime :
                return "By Time"
            }
        }
    }
    
    @IBOutlet var tableView: UITableView! = UITableView()
    
    var bottomBarViewHeight: CGFloat! = Constant.bottomBarViewHeight
    
    var presentForTabBarLessView : Bool! = false
    
    @IBOutlet var leftBarButtonItem : UIBarButtonItem! = UIBarButtonItem()
    
    @IBOutlet var rightBarButtonItem : UIBarButtonItem! = UIBarButtonItem()
    
    func barButtonItemSetup() {
       
        let style = UIFont.TextStyle.title3
        let mapImage = UIImage(systemName: "map", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: style, weight: .bold)))
        leftBarButtonItem.image = mapImage
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector(SwipeToLeft)
        let chatImage = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: style, weight: .bold)))
        rightBarButtonItem.target = self
        rightBarButtonItem.action = #selector(SwipeToRight)
        rightBarButtonItem.image = chatImage
    }
    
    @objc func SwipeToLeft() {
        BasicViewController.shared.startSwipe(toPage: 0)
    }
    
    @objc func SwipeToRight() {
        BasicViewController.shared.startSwipe(toPage: 2)
    }
    
    var getServerData : Bool = Constant.getServerData
    
    func playCurrentMedia() {
        if let cell = self.tableViewCurrentCell {
            cell.playCurrentMedia()
        }
    }
    func pauseCurrentMedia() {
        if let cell = self.tableViewCurrentCell {
            cell.pauseCurrentMedia()
        }
    }
    func initRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.backgroundColor = .clear
        self.tableView.refreshControl?.tintColor = .label
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
    }
    
    var currentMediaIndexPath: IndexPath! { get {
        return self.tableViewCurrentCell?.currentMediaIndexPath ?? IndexPath(row: 0, section: 0)
    } set { }
    }
    
    var currentCollectionCell: UICollectionViewCell? {
        return self.tableViewCurrentCell?.currentCollectionCell
    }
    
    var collectionView: UICollectionView! {
        return tableViewCurrentCell!.collectionView
    }
    
    func getFadedSubviews() -> [UIView]! {
        var array = self.view.subviews.filter { view in
            return true
        }
        array.append(self.view)
        return array
    }
    
    
    
    func getFadeInSubviews() -> [UIView?] {
        var soundImageViewArray : [UIView?]?
        if let playerLayerCell = tableViewCurrentCell?.currentCollectionCell  as? PlayerLayerCollectionCell {
            soundImageViewArray = playerLayerCell.soundViewIncludeBlur
        }
        var results : [UIView?] = [tableViewCurrentCell?.heartButton, tableViewCurrentCell?.userImageView]
        results.append(contentsOf: soundImageViewArray ?? [])
        return results
    }
    
    var isFirstLoad : Bool = true
    
    var postsStatus : MainTablePostsStatus = .PublicNear
    
    var enterCollectionIndexPath : IndexPath! = IndexPath(row: 0, section: 0)
    
    var posts : [Post]! = []
    
    var isLoadingPost : Bool = false
    
    var tableViewCurrentCell : MainPostTableCell? {
        if let cell = tableView.cellForRow(at: currentTableViewIndexPath) as? MainPostTableCell {
            return cell
        }
        return nil
    }
    var titleButton : UIButton!
    
    var currentTableViewIndexPath : IndexPath! = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        registerTableCell()
        setupAudioSession()
        layoutTitleButton()
        initRefreshControl()
        viewSetup()
        barButtonItemSetup()
        refreshPosts()
    }
    var tableViewBottomAnchor : NSLayoutConstraint!
    
    func initLayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableViewBottomAnchor = self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -Constant.bottomBarViewHeight   )
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableViewBottomAnchor
        ])
    }
    
    func registerTableCell() {
        self.tableView.register(MainPostTableCell.self, forCellReuseIdentifier: "MainPostTableCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Constant.navBarHeight = (self.navigationController?.navigationBar.frame.height)!
        tableViewRowHeightSet()
        navigationSetup()
        self.updateVisibleCellsMuteStatus()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !tableView.visibleCells.isEmpty {
            playCurrentMedia()
        }
        if Constant.standardNavBarFrame == nil {
            if let navigationBar = navigationController?.navigationBar   {
                if let tabBarFrame = navigationBar.superview?.convert(navigationBar.frame, to: self.view) {
                    Constant.standardNavBarFrame = tabBarFrame
                }
            }
        }
    }
    
    func tableViewRowHeightSet() {
        let fullScrennHeight = UIScreen.main.bounds.height
        let navBarHeight = (navigationController?.navigationBar.bounds.size.height) ?? 0
        let tabBarHeight = Constant.bottomBarViewHeight
        
        
        let statusBarHeight = (UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height) ?? 0
        let rowHeight =  fullScrennHeight - navBarHeight - tabBarHeight - statusBarHeight
        tableView.rowHeight = rowHeight
    }
    
    
    
    func navigationSetup() {
        navigationController?.hidesBarsOnTap = false
        
        self.navigationController?.delegate = self
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        self.navigationController?.navigationBar.isTranslucent = true
      
    }
    
    @objc func refreshPosts()  {
        tableView.refreshControl?.beginRefreshing()
        tableView.isPagingEnabled  = false
        
        Task(priority : .background) {
            do {
                defer {
                    tableView.refreshControl?.endRefreshing()
                    
                    isLoadingPost = false
                    tableView.isPagingEnabled  = true
                    self.playCurrentMedia()

                }
                self.isLoadingPost = true
                self.pauseCurrentMedia()
                self.posts.removeAll()
                if !getServerData {
                    self.posts.insert(contentsOf: posts, at: self.posts.count)
                    tableView.reloadSections([0], with: .automatic)
                    return
                }
                
                let newposts = try await self.postsStatus.getPosts(user_id: Constant.user_id, distance: 0, date: "")
                self.posts.insert(contentsOf: newposts, at: self.posts.count)
                if currentTableViewIndexPath != IndexPath(row: 0, section: 0) {
                    currentTableViewIndexPath = IndexPath(row: 0, section: 0)
                    
                    if self.posts.first != nil {
                        self.tableView.scrollToRow(at: currentTableViewIndexPath, at: .none, animated: true)
                    }
                }
                tableView.reloadSections([0], with: .fade)
            } catch {
                tableView.reloadSections([0], with: .fade)
                throw error
            }
        }
    }
    
    func insertNewPosts(newPosts: [Post]) {
        let insertionIndexPaths = (self.posts.count..<self.posts.count + newPosts.count).map { IndexPath(row: $0, section: currentTableViewIndexPath.section) }
        self.posts.insert(contentsOf: newPosts, at: self.posts.count)
        self.tableView.insertRows(at:insertionIndexPaths, with: .fade)
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = currentCollectionCell as? PlayerLayerCollectionCell {
            cell.playerLayer.player?.seek(to: CMTime.zero)
            cell.removePlayerRestartObserverToken()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoadingPost, posts.count - indexPath.row == 2 else {
            return
        }
        isLoadingPost = true
        Task(priority : .high) {

            let lastPost = self.posts.last
    
            guard let distance = lastPost?.distance,
                  let date = lastPost?.timestamp else {
                return
            }
            do {
                let newposts = try await self.postsStatus.getPosts(user_id: Constant.user_id, distance: distance, date: date)
                if newposts.count > 0 {
                    insertNewPosts(newPosts: newposts)
                }
                isLoadingPost = false
                
            } catch {
                isLoadingPost = false
            }
        }
        
        return
        
    }
    func layoutTitleButton() {
        titleButton = ZoomAnimatedButton(type: .system)
        titleButton.frame.size = CGSize(width: self.view.bounds.width * 0.4, height: titleButton.bounds.height)
        navigationItem.titleView = titleButton
        titleButton.clipsToBounds = true
        setTitleText(text: self.postsStatus.titleString, subText: self.postsStatus.subTitleString)
        titleButton.showsMenuAsPrimaryAction = true
        
        let publicAction = UIAction(title: "Public By Near", state: .on, handler: { action in

            guard self.postsStatus != .PublicNear else {
                return
            }
            self.postsStatus = .PublicNear
            self.setTitleText(text: self.postsStatus.titleString, subText: self.postsStatus.subTitleString)
            self.refreshPosts()
            
        })
        let friendsNearAction = UIAction(title: "Friend By Near", state: .on, handler: { action in
            guard self.postsStatus != .FriendsNear else {
                return
            }
            self.postsStatus = .FriendsNear
            self.setTitleText(text: self.postsStatus.titleString, subText: self.postsStatus.subTitleString)
            self.refreshPosts()
        })
        
        let friendsOrderTimeAction = UIAction(title : "Friend By Time", state: .on) { action in
            guard self.postsStatus != .FriendsCreatedTime else {
                return
            }
            self.postsStatus = .FriendsCreatedTime
            self.setTitleText(text: self.postsStatus.titleString, subText: self.postsStatus.subTitleString)
            self.refreshPosts()

        }
        
        
        let config = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
        let publicImage = UIImage(systemName: "globe.asia.australia.fill", withConfiguration: config)?.withTintColor(.tintOrange, renderingMode: .alwaysOriginal)
        let friendsImage = UIImage(systemName: "person.3.fill", withConfiguration: config)?.withTintColor(.tintOrange, renderingMode: .alwaysOriginal)
        let timeImage = UIImage(systemName: "clock", withConfiguration: config)?.withTintColor(.tintOrange, renderingMode: .alwaysOriginal)
        
        publicAction.image = publicImage

        friendsNearAction.image = friendsImage
        
        friendsOrderTimeAction.image = timeImage
        
        titleButton.menu = UIMenu(options: .singleSelection ,children: [publicAction, friendsNearAction, friendsOrderTimeAction])
        titleButton.menu?.preferredElementSize = .large
    }
    
    
    
    func presentWholePageMediaViewController(post: Post?) {
        guard let post = post else {
            return
        }
        let controller = WholePageMediaViewController(presentForTabBarLessView: false, post: post)
        let navcontroller = SwipeEnableNavViewController(rootViewController: controller)
        if let currentPostIndex = self.posts.firstIndex(of: post) {
            self.currentTableViewIndexPath = IndexPath(row: currentPostIndex, section: self.currentTableViewIndexPath.section)
        }
    //    controller.wholePageMediaDelegate = self
        controller.mediaAnimatorDelegate = self
        navcontroller.modalPresentationStyle = .overFullScreen
        navcontroller.definesPresentationContext = true
        navcontroller.transitioningDelegate = self
        navcontroller.delegate = self
        self.navigationController?.present(navcontroller, animated: true) {
            BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        }
        
    }
    
    func fadeInViewStartAnimation() {
        
        DispatchQueue.main.async {
            let fadInSubViews = self.getFadeInSubviews()
            UIView.animate(withDuration:  0.2 , delay: 0 , animations: {
                fadInSubViews.forEach { view in
                    
                    view?.alpha = 1
                }
            })
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        if dismissed is ShareViewController || dismissed is AddCollectViewController {
            self.playCurrentMedia()
        }
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting presening: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let indexPath = tableViewCurrentCell?.currentMediaIndexPath else {
            return nil
        }
        
        self.enterCollectionIndexPath = indexPath
        
        if let nav = presented as? UINavigationController {
            if let toViewController = nav.viewControllers.first as? WholePageMediaViewController {
                let animator = PresentWholePageMediaViewControllerAnimator(transitionToIndexPath: indexPath, toViewController:  toViewController , fromViewController: self)
                return animator
            }
        }
        pauseCurrentMedia()
        if let toViewController = presented as? GridPostCollectionViewAnimatorDelegate {
            toViewController.reloadCollectionCell(backCollectionIndexPath: toViewController.enterCollectionIndexPath)
        }
        if let toViewController = presented as? MediaCollectionViewAnimatorDelegate {
            toViewController.reloadCollectionCell(backCollectionIndexPath: toViewController.enterCollectionIndexPath)
        }
        
        return nil
    }
    
    
    
    func showUserProfile(user : User) {
        self.pauseCurrentMedia()
        let controller = MainUserProfileViewController(presentForTabBarLessView: self.presentForTabBarLessView, user: user,  user_id: user.id)
        controller.navigationItem.title = user.name
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func viewSetup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        navigationItem.backButtonTitle = ""
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
    }
    
}

extension MainPostTableViewController {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        fadeInViewStartAnimation()
    }
    
    func reloadCollectionCell(backCollectionIndexPath: IndexPath) {
        
        if let enterMainCell = tableView.cellForRow(at: self.currentTableViewIndexPath) as? MainPostTableCell {
            enterMainCell.reloadCollectionCell(reloadIndexPath: enterCollectionIndexPath!, scrollTo: backCollectionIndexPath)
        }
        let fadeInController = self.getFadeInSubviews()
        UIView.animate(withDuration: 0.2, animations: {
            fadeInController.forEach() {
                $0?.alpha = 1
            }
        })
        //出去的index
    }
    
    func updateCellPageControll(currentCollectionIndexPath: IndexPath) {
        let cell = tableView.cellForRow(at: self.currentTableViewIndexPath) as! MainPostTableCell
        cell.updateCellPageControll(currentCollectionIndexPath: currentCollectionIndexPath)
    }
    
}

extension MainPostTableViewController {
    
    func addplayingnowcontrollerObserve() {
        
        if let cell = self.currentCollectionCell as? PlayerLayerCollectionCell,
           let player = cell.playerLayer.player {
            player.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if let cell = currentCollectionCell as? PlayerLayerCollectionCell {
            
            if keyPath == "status", cell.playerLayer.player?.status == .readyToPlay {
                if tableView.visibleCells.first == tableViewCurrentCell {
                    cell.play()
                    cell.playerLayer.player?.removeObserver(self, forKeyPath: "status")
                }
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MainPostTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MainPostTableCell
        
        let post = self.posts[indexPath.row]
        
        cell.mediaTableCellDelegate = self
        cell.configureData(post: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
}


extension MainPostTableViewController {
    
    func updateVisibleCellsMuteStatus() {
        for cell in tableView.visibleCells {
            if let cell = cell as? MainPostTableCell {
                cell.updateVisibleCellsMuteStatus()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index =  Int ( round( scrollView.contentOffset.y / scrollView.bounds.height) )
        
        if currentTableViewIndexPath.row != index {
            pauseCurrentMedia()

            updateVisibleCellsMuteStatus()
            currentTableViewIndexPath = IndexPath(row: index, section: self.currentTableViewIndexPath.section)
            
            playCurrentMedia()
            
        }
    }
    
}

extension MainPostTableViewController {
    func setupAudioSession() {
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("聲音設定錯誤: \(error)")
        }
    }
    
    
    
}


extension MainPostTableViewController {
    
    func setTitleText(text : String, subText : String) {
        let imageConfig = UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .caption2, weight: .bold))
        let container = AttributeContainer([ .font : UIFont.weightSystemSizeFont(systemFontStyle: .title1, weight: .bold), .foregroundColor : UIColor.tintOrange])
        let attriString = AttributedString(text + " " + subText, attributes: container)
        let clockImage = UIImage(systemName: "clock", withConfiguration: imageConfig)
        let nearImage = UIImage(systemName: "person.line.dotted.person", withConfiguration: imageConfig)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .secondaryBackgroundColor
        config.titleAlignment = .center
        config.cornerStyle = .capsule
        config.baseForegroundColor = .secondaryLabelColor
        config.attributedTitle = attriString
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        self.titleButton.configuration = config

    }
    
    
}
