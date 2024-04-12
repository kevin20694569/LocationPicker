import UIKit



class MainUserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate , UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, GridPostCollectionViewAnimatorDelegate, UIGestureRecognizerDelegate , PostsTableForGridPostCellViewDelegate, ProfileMainCellDelegate, ShowMessageControllerProtocol {

    
    var tempModifiedPostsWithMediaCurrentIndex: [String : Post]! = [ : ]
    var getServerData : Bool = Constant.getServerData
        
    
    
    init(presentForTabBarLessView : Bool, user : User?,  user_id : Int?) {
        super.init(nibName: nil, bundle: nil)
        self.user_id = user_id
        self.presentForTabBarLessView = presentForTabBarLessView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
    func hiddenWillBackCollectionCell(hiddenIndexPath : IndexPath) {
        if let unHiddenCell = self.collectionView.cellForItem(at: enterCollectionIndexPath) as? GridPostCell {
            unHiddenCell.imageView.isHidden = false
        }
        let indexPath = IndexPath(row: hiddenIndexPath.row, section: enterCollectionIndexPath.section)
        if let needHiddenCell = self.collectionView.cellForItem(at: indexPath) as? GridPostCell {
            needHiddenCell.imageView.isHidden = true
        }
    }
    
    var presentForTabBarLessView : Bool! = false
    
    
    @IBOutlet var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    var getUserProfileFinish : Bool! = false

    var enterCollectionCell: UICollectionViewCell? {
        return self.collectionView.cellForItem(at: enterCollectionIndexPath)
    }
    
    var user_id : Int! = Constant.user_id
    
    var userProfile: UserProfile! = UserProfile()
    
    var posts : [Post]! =  []
    
    var playlists : [Playlist]! = Playlist.examples
    
    var enterCollectionIndexPath : IndexPath! = IndexPath(row: 0, section: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        initLayout()
        registerCells()
        layoutCollectionCellflow()
        viewDataStyleSet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MainTabBarViewController.shared.layoutTabBarAndBottomView()
    }
    
    
    
    func viewDataStyleSet() {
        self.view.backgroundColor = .backgroundPrimary
        self.collectionView.backgroundColor = .backgroundPrimary
        collectionView.delaysContentTouches = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        navigationItem.backButtonTitle = ""
        if presentForTabBarLessView {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0 , right: 0)
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constant.bottomBarViewHeight - Constant.safeAreaInsets.bottom , right: 0)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar(title: self.userProfile.user?.name)
        if !getUserProfileFinish {
            Task(priority : .background)  {
                await configure(user_id: user_id)
            }
        }
    }
    
    func configureNavBar(title : String?) {
       self.navigationController?.navigationBar.standardAppearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithOpaqueBackground()
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
        self.navigationController?.navigationBar.isTranslucent = true
        if let title = title {
            self.navigationItem.title = title
        }
        self.navigationItem.backButtonTitle = ""
    }


    func configure(user_id: Int)  async {
        do {
            Task(priority : .background) {
                await getUserPosts(user_id : user_id, date : "")
            }

            guard let userProfile = try await UserProfileManager.shared.getProfileByID(user_ID: user_id) else {
                return
            }
            
            self.userProfile = userProfile
            
            configureNavBar(title: self.userProfile.user?.name)
            self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
            getUserProfileFinish = true
        } catch {
            print("getProfile問題")
        }
    }
    
    func showMessageViewController(user_ids: [Int]) {
        let controller = MessageViewController(chatRoomUser_ids: user_ids)
        controller.navigationItem.title = self.userProfile.user.name
        let tabBarframe = MainTabBarViewController.shared.tabBar.superview!.convert(MainTabBarViewController.shared.tabBar.frame, to: self.view)
        MainTabBarViewController.shared.tabBar.frame = tabBarframe
        let bottomBarframe = MainTabBarViewController.shared.bottomBarView.superview!.convert(MainTabBarViewController.shared.bottomBarView.frame, to: view)
        MainTabBarViewController.shared.bottomBarView.frame = bottomBarframe
        view.addSubview(MainTabBarViewController.shared.bottomBarView)
        view.addSubview(MainTabBarViewController.shared.tabBar)
        self.show(controller, sender: nil)
    }
    
    
    func registerCells() {
        collectionView.register(ProfileMainCell.self, forCellWithReuseIdentifier:   "ProfileMainCell")
        collectionView.register(ProfileCollectionViewPlaylistCell.self, forCellWithReuseIdentifier: "ProfileCollectionViewPlaylistCell")
        collectionView.register(GridPostCell.self, forCellWithReuseIdentifier:   "GridPostCell")
    }

    func getUserPosts(user_id : Int, date : String) async {
        do {
            var newPosts : [Post]! = []
            if getServerData {
                newPosts = try await PostManager.shared.getUserPostsByID(user_id: user_id, date: date)
            } else {
                newPosts = Post.localPostsExamples
            }
            if newPosts.count > 0 {
                let insertionIndexPaths = (self.posts.count..<self.posts.count + newPosts.count).map { IndexPath(row: $0, section: self.enterCollectionIndexPath.section) }
                self.posts.insert(contentsOf: newPosts, at: self.posts.count)
                self.collectionView.insertItems(at: insertionIndexPaths)
            }
        } catch {
            print("沒拿到posts")
        }
    }
    func layoutCollectionCellflow() {
        collectionView.showsHorizontalScrollIndicator = false
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        collectionView.collectionViewLayout = flow
    }
    
    func presentPostTableViewController(indexPath: IndexPath) {
        let targetPostCellIndexPath = IndexPath(row: indexPath.row , section: 0)
        let controller = UserProfilePostTableViewController(presentForTabBarLessView: presentForTabBarLessView)
        let nav = SwipeEnableNavViewController(rootViewController: controller)

        controller.user = self.userProfile.user
        controller.posts = posts
        
        controller.currentTableViewIndexPath = targetPostCellIndexPath
        controller.postsTableDelegate = self
        nav.modalPresentationStyle = .overFullScreen
        nav.transitioningDelegate = self
        nav.definesPresentationContext = true

        self.present(nav, animated: true) {

            BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let nav = presented as? UINavigationController {
            if let toViewController = nav.viewControllers.first as? CollectionViewInTableViewMediaAnimatorDelegate {
                guard let enterIndexPath = self.collectionView.indexPathsForSelectedItems?.first else { return nil }
                enterCollectionIndexPath = enterIndexPath
                let toIndexPath = IndexPath(row : enterCollectionIndexPath.row, section: 0)
                let collectoinViewTransionToIndexPath = IndexPath(row: posts[enterIndexPath.row].CurrentIndex, section: 0)

                let animator = PresentGridCellAnimator(transitionToIndexPath: toIndexPath, toViewController: toViewController, fromViewController: self, collectoinViewTransionToIndexPath: collectoinViewTransionToIndexPath)
                return animator
            }
        }
        return nil
    }
    
    
}
 

extension MainUserProfileViewController {
    
    func changeMediaCollectionCellImage(needChangedCollectionIndexPath : IndexPath, currentMediaIndexPath : IndexPath?) {
        
        self.posts[needChangedCollectionIndexPath.row].CurrentIndex = currentMediaIndexPath?.row
        
        if let needChangeIndexPathCell = self.collectionView.cellForItem(at: needChangedCollectionIndexPath) as? GridPostCell {
            needChangeIndexPathCell.changeImage(changeToIndex:currentMediaIndexPath?.row ?? 0)
        }
        //出去的index
    }
    
    func reloadCollectionCell(backCollectionIndexPath : IndexPath) {
        
        if let needReloadCell = self.collectionView.cellForItem(at: self.enterCollectionIndexPath) as? GridPostCell {
            needReloadCell.reloadCollectionCell()
        }
        if let backReloadCell = self.collectionView.cellForItem(at: backCollectionIndexPath ) as? GridPostCell {
            backReloadCell.reloadCollectionCell()
        }
    }
    

    
    
}

extension MainUserProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.posts.count - indexPath.row == 4 {
            guard let date = self.posts.last?.timestamp else {
                return
            }
            Task {
                await self.getUserPosts(user_id: Constant.user_id ,date: date)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 1 {
            return 1
        } else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 1 {
            return 1
        } else {
            return 0
        }// 根据需要设置行之间的最小间距
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }


    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = UIScreen.main.bounds
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return CGSize(width: bounds.width , height: bounds.height * 0.2)
            } else {
                return CGSize(width: bounds.width , height: bounds.height * 0.15)
            }
        } else {
            let width = bounds.width / 3 - 1 * 2
            return CGSize(width: width , height: width )
        }
    }
    
   func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let playlistEmpty = self.playlists.isEmpty ? 0 : 1
            return 1 + playlistEmpty
        } else {
            return posts.count
        }
    }
    
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileMainCell", for: indexPath) as! ProfileMainCell
                cell.configure(userProfile: self.userProfile)

                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewPlaylistCell", for: indexPath) as! ProfileCollectionViewPlaylistCell
                cell.configureData(playlists: self.playlists)
                return cell
            }
        } else {
            let post = posts[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridPostCell", for: indexPath) as! GridPostCell
            cell.configureImageView(post: post, image: nil, mediaIndex: post.CurrentIndex)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 else {
            return
        }
        presentPostTableViewController(indexPath: indexPath)
    }
}
