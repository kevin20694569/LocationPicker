import UIKit
class RestaurantDetailViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PostsTableForGridPostCellViewDelegate, UIViewControllerTransitioningDelegate, PresentDelegate {
    
    init(presentForTabBarLessView : Bool, restaurant : Restaurant?) {
        super.init(nibName: nil, bundle: nil)
        self.presentForTabBarLessView = presentForTabBarLessView
        self.restaurant = restaurant
    }
    
    var presentForTabBarLessView : Bool! = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var openingTimesView : OpeningTimeView? = initOpeningTimesView()
    
    func initOpeningTimesView() -> OpeningTimeView {
        let view = OpeningTimeView(frame: .zero)
        view.configure(openingDays: restaurant.openingDays)
        return view
    }
    
    var tempModifiedPostsWithMediaCurrentIndex: [String : Post]! = [ : ]
    
    weak var enterCollectionCell: UICollectionViewCell? {
        return self.collectionView.cellForItem(at: enterCollectionIndexPath)
    }
    
    var completeNoPosts : Bool! = false
    
    let getServerData : Bool = Constant.getServerData
    
    var dismissAlertGesture : UITapGestureRecognizer!
    
    
    var enterCollectionIndexPath: IndexPath! = IndexPath(row: 0, section: 3)
    
    func changeMediaCollectionCellImage(needChangedCollectionIndexPath : IndexPath, currentMediaIndexPath : IndexPath?) {
        self.posts[needChangedCollectionIndexPath.row].CurrentIndex = currentMediaIndexPath?.row
        let collectionIndexPath = IndexPath(row: needChangedCollectionIndexPath.row, section: self.enterCollectionIndexPath.section)
        let needChangeIndexPathCell = self.collectionView.cellForItem(at: collectionIndexPath) as! GridPostCell
        needChangeIndexPathCell.changeImage(changeToIndex:currentMediaIndexPath?.row ?? 0)
    }
    
    func reloadCollectionCell(backCollectionIndexPath : IndexPath) {
        if let needReloadCell = self.collectionView.cellForItem(at: self.enterCollectionIndexPath) as? GridPostCell {
            needReloadCell.reloadCollectionCell()
        }
        
        if let backReloadCell = self.collectionView.cellForItem(at: backCollectionIndexPath ) as? GridPostCell {
            backReloadCell.reloadCollectionCell()
        }
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
    
    var posts : [Post]! = []
    
    func getRestaurantSummary(restaurant_id : String) async  {
        do {
            let restaurant = try await RestaurantManager.shared.getRestaurantIDasync(restaurantID: restaurant_id)
            guard let restaurant = restaurant else {
                throw RestaurantError.NotFoundRestaurant
            }
            self.restaurant = restaurant
            self.collectionView.reloadSections([0, 1, 2])
        } catch {
            print("error", error)
        }
    }
    
    func getRestaurantPosts(restaurantID : String, afterDate : String, reload : Bool) async {
        do {
            defer {
                self.collectionView.refreshControl?.endRefreshing()
            }
            var newPosts : [Post] = []
            if getServerData {
                newPosts = try await PostManager.shared.getRestaurantPostsByID(restaurantID: restaurantID, date: afterDate)
            } else {
                newPosts = Post.localPostsExamples
            }
            if newPosts.count > 0 {
                let insertionIndexPaths = (self.posts.count..<self.posts.count + newPosts.count).map { IndexPath(row: $0, section: self.enterCollectionIndexPath.section) }
                self.posts.insert(contentsOf: newPosts, at: self.posts.count)
                if reload {
                    self.collectionView.reloadSections([self.enterCollectionIndexPath.section])
                } else {
                    self.collectionView.insertItems(at: insertionIndexPaths)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func initLayout() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        viewControllerToPresent.view.superview?.addGestureRecognizer(dismissAlertGesture)
        viewControllerToPresent.view.superview?.isUserInteractionEnabled = true
        self.dismissAlertGesture.isEnabled = true
        
    }

    
    weak var restaurant : Restaurant!
    
    var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        viewDataStyleSet()
        registerCollectionCells()
        setGesture()
        Task(priority : .background) {  [weak self] in
            guard let self = self else {
                return
            }
            await getRestaurantSummary(restaurant_id: self.restaurant.ID)
        }
        Task(priority : .background) { [weak self] in
            guard let self = self else {
                return
            }
            self.collectionView.refreshControl?.beginRefreshing()

            await self.getRestaurantPosts(restaurantID: self.restaurant.ID, afterDate: posts.last?.timestamp ?? "", reload: posts.isEmpty )
            
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func setGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissOpeningDaysTableView))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        dismissAlertGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapped( _ :)))
        dismissAlertGesture.cancelsTouchesInView = true
        dismissAlertGesture.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar(title: restaurant.name)
    }
    
    func refreshPosts() {

    }
    
    func viewDataStyleSet() {
        self.view.backgroundColor = .backgroundPrimary
        self.collectionView.backgroundColor = .backgroundPrimary
        collectionView.delaysContentTouches = false
        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        collectionView.collectionViewLayout = flow
        if presentForTabBarLessView {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constant.bottomBarViewHeight - Constant.safeAreaInsets.bottom, right: 0)
        }
        navigationItem.backButtonTitle = ""
    }
    
    func configureNavBar(title : String?) {
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        if let title = title {
            self.navigationItem.title = title
        }
    }
    
    func presentPostTableViewController(indexPath: IndexPath) {
        let targetPostCellIndexPath = IndexPath(row: indexPath.row , section: 0)
        let restaurantPostsTableViewController = RestaurantPostsTableViewController(presentForTabBarLessView: presentForTabBarLessView)
        let nav = SwipeEnableNavViewController(rootViewController: restaurantPostsTableViewController)
        restaurantPostsTableViewController.restaurant = self.restaurant
        restaurantPostsTableViewController.postsTableDelegate = self
        restaurantPostsTableViewController.posts = posts
        restaurantPostsTableViewController.currentTableViewIndexPath = targetPostCellIndexPath
        nav.modalPresentationStyle = .overFullScreen
        nav.transitioningDelegate = self
        
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
    
    
    func registerCollectionCells() {
        let restaurantNameDetailCell = UINib(nibName: "RestaurantProfileNameCell", bundle: nil)
        self.collectionView.register(restaurantNameDetailCell, forCellWithReuseIdentifier: "RestaurantProfileNameCell")
        
        let RestaurantDetailCollectionViewButtonsCell = UINib(nibName: "RestaurantDetailCollectionViewButtonsCell", bundle: nil)
        self.collectionView.register(RestaurantDetailCollectionViewButtonsCell, forCellWithReuseIdentifier: "RestaurantDetailCollectionViewButtonsCell")
        
        let RestaurantDetailCollectionViewDetailGridCell = UINib(nibName: "RestaurantDetailCollectionViewDetailGridCell", bundle: nil)
        self.collectionView.register(RestaurantDetailCollectionViewDetailGridCell, forCellWithReuseIdentifier: "RestaurantDetailCollectionViewDetailGridCell")
        self.collectionView.register(GridPostCell.self, forCellWithReuseIdentifier: "GridPostCell")
        self.collectionView.register(EmptyPostCollectoinCell.self, forCellWithReuseIdentifier: "EmptyPostCollectoinCell")
        self.collectionView.register(LoadingCollectionCell.self, forCellWithReuseIdentifier: "LoadingCollectionCell")
    }
         
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section <= 2 {
            return 1
        }
        if self.posts.isEmpty {
            return 1
        }
        return posts.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets.init(top: 4, left: 0, bottom: 0, right: 0)
        }
        if section == 2 {
            return UIEdgeInsets.init(top: 4, left: 0, bottom: 0, right: 0)
        }
        if section == 3 {
            return UIEdgeInsets.init(top: 12, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 3 {
            return 1
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 2 {
            return 12
        }
        if section == 3 {
            return 2
        }
        return 0
    }
    
    @objc func dismissTapped(_ gesture : UITapGestureRecognizer) {
        
        self.dismiss(animated: true) {
            gesture.isEnabled = false
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let bounds = UIScreen.main.bounds
        if section == 0 {
            
            return CGSize(width: bounds.width , height: bounds.height * 0.3)
        } else if section == 1 {
            return CGSize(width: bounds.width , height: bounds.height * 0.04 )
        } else if section == 2 {
            return CGSize(width: bounds.width , height: bounds.width * 2 / 3 )
        } else if section == 3 {
            if self.posts.isEmpty {
                let width = bounds.width
                return CGSize(width: width , height: bounds.height * 0.1 )
            }
            let lineSpaceing : CGFloat = 1
            let width = self.view.bounds.width / 3 - lineSpaceing * 2
            return CGSize(width: width  , height: width)
        }
        

        return CGSize(width: bounds.width , height: bounds.height * 0.25
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantProfileNameCell", for: indexPath) as! RestaurantProfileNameCell
            cell.configure(restaurant: self.restaurant)
            return cell
        } else if section == 1 {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantDetailCollectionViewButtonsCell", for: indexPath) as! RestaurantDetailCollectionViewButtonsCell
            cell.presentDelegate = self
            cell.configure(restaurant: self.restaurant)
            return cell
        } else if section == 2 {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantDetailCollectionViewDetailGridCell", for: indexPath) as! RestaurantDetailCollectionViewDetailGridCell
            cell.delegate = self
            cell.configure(restaurant: self.restaurant)
            return cell
        }
        if self.posts.isEmpty {
            if completeNoPosts {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPostCollectoinCell", for: indexPath) as! EmptyPostCollectoinCell
                cell.configure(title: "尚未有貼文")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionCell", for: indexPath) as! LoadingCollectionCell
                return cell
            }
        }
        let post = self.posts[indexPath.row]
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "GridPostCell", for: indexPath) as! GridPostCell
        cell.configureImageView(post: post, image: nil, mediaIndex: post.CurrentIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section >= 2 else {
            return
        }

        if indexPath.section == 3 {
            guard !posts.isEmpty else {
                return
            }
            self.presentPostTableViewController(indexPath: indexPath)
        }
        self.collectionView.visibleCells.forEach() {
            $0.isSelected = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissOpeningDaysTableView()
    }
    
    var detailCollectionViewIndexPath : IndexPath! = IndexPath(row: 0, section: 2)
    
    var openingTimeGridCell : RestaurantDetailOpeningTimesCell? {
        if let detailCollectionViewCell = self.collectionView.cellForItem(at: detailCollectionViewIndexPath) as? RestaurantDetailCollectionViewDetailGridCell {
            
            return detailCollectionViewCell.openingTimeGridCell
            
        }
        return nil
    }
    
    var openingViewCanBeingAnimated : Bool! = true
    
    
    
}

extension RestaurantDetailViewController : RestaurantDetailCollectionViewDetailGridCellDelegate {
    

    @MainActor
    func presentOpeningDaysTableView( cell: UICollectionViewCell) {
        guard cell == openingTimeGridCell,
              openingViewCanBeingAnimated,
            openingTimesView?.superview == nil else {
            return
        }
        if let initCell = cell as? RestaurantDetailOpeningTimesCell {
            openingViewCanBeingAnimated = false
            self.openingTimesView = self.initOpeningTimesView()
            let view = openingTimesView!
            view.configure(openingDays: restaurant.openingDays)
            let initCellFrame = initCell.contentView.superview!.convert(initCell.contentView.frame, to: self.view)
            let initCellCenter = initCell.contentView.superview!.convert(initCell.contentView.center, to: self.view)

            self.view.insertSubview(view, aboveSubview: collectionView)
            
            let initTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            let width = self.view.bounds.width * 0.5
            let height = self.view.bounds.height * 0.3
            let scale = 0.2
            var targetCenterY : CGFloat = initCellFrame.minY - height / 2 + initCellFrame.height * scale
            view.alpha = 0
            var y : CGFloat! = initCellFrame.minY - height + initCellFrame.height * scale
            let navBarFrame = self.navigationController?.navigationBar.superview?.convert(navigationController!.navigationBar.frame, to: self.view)
            if y < navBarFrame!.maxY {
                y = initCellFrame.maxY - initCellFrame.height * scale
                targetCenterY = y + height / 2
            }
            let targetFrame = CGRect(x: initCellFrame.minX - width + initCellFrame.width * scale, y: y , width: width, height: height)
            let targetCenter : CGPoint! = CGPoint(x: initCellFrame.minX - width / 2 + initCellFrame.width * scale, y: targetCenterY )
            view.frame = targetFrame
            view.center = initCellCenter
            view.transform = initTransform
            UIView.animate(withDuration:  0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                view.center = targetCenter
                view.transform = .identity
                view.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    view.tableView.alpha = 1
                }
            }) { bool in
                self.openingViewCanBeingAnimated = true
            }
        }
    }
    
    
    @MainActor
    @objc func dismissOpeningDaysTableView() {
        guard openingViewCanBeingAnimated,
        openingTimesView?.superview != nil else {
            return
        }
        
        if self.collectionView.cellForItem(at: self.detailCollectionViewIndexPath) is RestaurantDetailCollectionViewDetailGridCell {
            openingViewCanBeingAnimated = false
            if let targetCell = self.openingTimeGridCell {
                self.openingViewCanBeingAnimated = false
                let targetTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                let view = self.openingTimesView!
                let targetCellCenter = targetCell.convert(targetCell.contentView.center, to: self.view)
                UIView.animate(withDuration: 0.25, animations: {
                    
                     view.center = targetCellCenter
                    view.transform = targetTransform
                    view.alpha = 0
                }) { bool in
                    view.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    view.layout()
                    view.transform = .identity
                    view.removeFromSuperview()
                    self.openingTimesView = nil
                    self.openingViewCanBeingAnimated = true
                }
                
            }
        }
    }
    
}
