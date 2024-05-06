import UIKit
import MapKit



class MapGridPostViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate , UICollectionViewDataSource, GridPostCollectionViewAnimatorDelegate, PostsTableForGridPostCellViewDelegate {
    
    var tempModifiedPostsWithMediaCurrentIndex: [String : (Post, Int)]! = [:]
    
    var enterCollectionCell: UICollectionViewCell? {
        self.collectionView.cellForItem(at: self.enterCollectionIndexPath)
    }
    
    func deletePostCell(post: Post) {
        guard let index = self.posts.firstIndex(of: post) else {
            return
        }
        let indexPath = IndexPath(row: index, section: self.enterCollectionIndexPath.section)
        posts.remove(at: index)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        } completion: { bool in
            
        }
        Task {
            await self.getRestaurantSummary(restaurant_id: self.restaurantID )
        }
        

    }
    
    @IBOutlet var openingTimeStackView : UIStackView!
    
    var getServerData : Bool = Constant.getServerData
    
    var enterCollectionIndexPath: IndexPath! = IndexPath(row: 0, section: 0)
    
    func changeMediaCollectionCellImage(needChangedCollectionIndexPath : IndexPath, currentMediaIndexPath : IndexPath?) {
        self.posts[needChangedCollectionIndexPath.row].CurrentIndex = currentMediaIndexPath?.row
        let collectionIndexPath = IndexPath(row: needChangedCollectionIndexPath.row, section: self.enterCollectionIndexPath.section)
        if let needChangeIndexPathCell = self.collectionView.cellForItem(at: collectionIndexPath) as? GridPostCell {
            needChangeIndexPathCell.changeImage(changeToIndex:currentMediaIndexPath?.row ?? 0)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = self.posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridPostCell", for: indexPath) as! GridPostCell
        cell.configureImageView(post: post, image: nil, mediaIndex: 0)
        return cell
    }
    
    var previousOffsetY : CGFloat = 0
    @IBOutlet weak var RestaurantNameLabel : UILabel! { didSet {
        RestaurantNameLabel.adjustsFontSizeToFitWidth = true
    }}
    @IBOutlet weak var RestaurantAddressLabel : UILabel! { didSet {
        RestaurantAddressLabel.adjustsFontSizeToFitWidth = true
    }}
    @IBOutlet weak var RestaurantImageView : UIImageView! { didSet {
        RestaurantImageView.layer.cornerRadius = 8.0
        RestaurantImageView.layer.contentsGravity = .resizeAspectFill
        RestaurantImageView.backgroundColor = .secondaryBackgroundColor
    }}
    
    @IBOutlet weak var openToggleView : UIView!
    @IBOutlet weak var OpenToggleLabel : UILabel! { didSet {
        OpenToggleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
    }}
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradeLabel: UILabel! { didSet {
        gradeLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
    }}
    @IBOutlet weak var distanceLabel : UILabel! { didSet {
        distanceLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
        distanceLabel.adjustsFontSizeToFitWidth = true
    }}
    @IBOutlet weak var distanceAndGradeView : UIView!
    @IBOutlet weak var distanceStackView : UIStackView!
    @IBOutlet weak var restaurantNameView : UIView!
    
    @IBOutlet weak var openingDayLabel : UILabel!
    
    var restaurant : Restaurant! = Restaurant.example
    
    var collectionViewpreviousOffsetY : CGFloat = 0
    weak var mapGridPostDelegate : MapGridPostDelegate!
    var refreshControl : UIRefreshControl! { didSet {
        refreshControl?.backgroundColor = .clear
        refreshControl?.tintColor = .label
        refreshControl?.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
    }}
    var restaurantID : String!
    var posts : [Post]! = []
    
    @objc func refreshPosts() {
        Task(priority : .background) {
            self.collectionView.refreshControl?.beginRefreshing()
            self.posts.removeAll()
            await self.getRestaurantPosts(restaurantID: self.restaurantID, afterDate: "", reload: true)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    
    var restaurantDistanceTopAnchor : NSLayoutConstraint!
    
    @IBOutlet var gradeStackView : UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture()
        viewStyleSet()
        collectionViewLayout()
    }
    
    func configureOpeningTime(restaurant : Restaurant) {
        if let grade = restaurant.average_grade {
            self.gradeLabel.text = String(format: "%.1f", grade)
        } else {
            self.gradeLabel.text = "nil"
        }
        
        self.openingTimeStackView.arrangedSubviews.forEach() { view in
            openingTimeStackView.removeArrangedSubview(view)
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayString = dateFormatter.string(from: date)
        openingDayLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline   , weight: .bold)
        let today =  WeekDay(rawValue: dayString)
        openingDayLabel.text = today?.dayString
        var openingDay : [OpeningHours]?
        if let openingDays = restaurant.openingDays {
            if let monFirst = openingDays.mon?.first {
                if monFirst.open == "0000" && monFirst.close == nil {
                    configureOpeningLabel(openingDay: openingDays.mon)
                    return
                }
            }
            switch today {
            case .mon :
                openingDay = openingDays.mon
            case .tues :
                openingDay = openingDays.tues
            case .wed :
                openingDay = openingDays.wed
            case .thur :
                openingDay = openingDays.thur
            case .fri :
                openingDay = openingDays.fri
            case .sat :
                openingDay = openingDays.sat
            case .sun :
                openingDay = openingDays.sun
            case .none :
                return
            }
        }
        configureOpeningLabel(openingDay: openingDay)
        
    }
    
    func configureOpeningLabel(openingDay : [OpeningHours]?) {

        if let openingDay = openingDay {
            if openingDay.isEmpty {
                let label = UILabel()
                label.contentMode = .center
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                label.adjustsFontForContentSizeCategory = true
                label.text = "休息"
                label.textColor = .label
                openToggleView.backgroundColor = .systemRed
                self.OpenToggleLabel.text = "休息中"
                self.openingTimeStackView.addArrangedSubview(label)
                return
            }
            var opening : Bool = false
            for hour in openingDay {
                if let open = hour.open {
                    let label = UILabel()
                    label.font = UIFont.weightSystemSizeFont(systemFontStyle: .subheadline  , weight: .bold)
                    label.contentMode = .center
                    label.textAlignment = .center
                    if open == "0000" && hour.close == "0000" {
                        label.text = "24小時營業"
                        label.textColor = .label
                        opening = true
                    } else if let close = hour.close {
                        label.text = "\(open.prefix(2)):\(open.suffix(2))" + " - " + "\(close.prefix(2)):\(close.suffix(2))"
                        
                        if Date.isCurrentTimeInRange(startTime: open, endTime: close) {
                            label.textColor = .label
                            opening = true
                        } else {
                            label.textColor = .secondaryLabelColor
                        }
                    }
                    self.openingTimeStackView.addArrangedSubview(label)
                }
            }
            if opening {
                openToggleView.backgroundColor = .systemGreen
                self.OpenToggleLabel.text = "營業中"
            } else {
                openToggleView.backgroundColor = .systemRed
                self.OpenToggleLabel.text = "休息中"
            }
        } else {
            let label = UILabel()
            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .subheadline  , weight: .bold)
            label.contentMode = .center
            label.textAlignment = .center
            label.textColor = .secondaryLabelColor
            label.text = "暫無營業時間"
            self.openingTimeStackView.addArrangedSubview(label)
            openToggleView.backgroundColor = .secondaryBackgroundColor
            self.OpenToggleLabel.text = ""
            return
        }

        
    }
    
    func setGesture() {
        let locationImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(presentRestaurantDetailViewController))
        RestaurantImageView.addGestureRecognizer(locationImageViewGesture)
        RestaurantImageView.isUserInteractionEnabled = true
        let RestaurantNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(presentRestaurantDetailViewController))
        RestaurantNameLabel.addGestureRecognizer(RestaurantNameLabelGesture)
        RestaurantNameLabel.isUserInteractionEnabled = true
        let  RestaurantAddressLabelGesture = UITapGestureRecognizer(target: self, action: #selector(presentRestaurantDetailViewController))
        RestaurantAddressLabel.addGestureRecognizer(RestaurantAddressLabelGesture)
        RestaurantAddressLabel.isUserInteractionEnabled = true
    }
    
    
    @objc func presentRestaurantDetailViewController() {
        let controller = RestaurantDetailViewController(presentForTabBarLessView: true, restaurant: restaurant)
        
        controller.posts = posts

        
        self.show(controller, sender: nil)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.mapGridPostDelegate.navigationController)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled  = false
    }
    
    func viewStyleSet() {
        self.view.layer.cornerRadius = 25
        self.view.layer.masksToBounds =  true
        refreshControl = UIRefreshControl()
        collectionView.refreshControl = self.refreshControl
        collectionView.dataSource = self
        collectionView.delegate = self
        distanceAndGradeView.translatesAutoresizingMaskIntoConstraints  = false
        restaurantDistanceTopAnchor = distanceAndGradeView.topAnchor.constraint(equalTo: restaurantNameView.bottomAnchor)
        let cellWidth = self.view.bounds.width / 3 - 2
        NSLayoutConstraint.activate([
            openingTimeStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -cellWidth - 1),
            gradeStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: cellWidth + 1),
            restaurantDistanceTopAnchor
        ])
    }
    
    func collectionViewLayout() {
        let lineSpacing : CGFloat = 1
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = lineSpacing
        let width = self.view.bounds.width / 3 - 2 * lineSpacing
        layout.itemSize = CGSize(width: width , height: width )
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0 , right: 0)
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapGridPostDelegate.removeRoute()
    }
    
    func insertPostsReloadSection(newPosts : [Post]) {
        
        let insertionIndexPaths = (self.posts.count..<self.posts.count + newPosts.count).map { IndexPath(row: $0, section: self.enterCollectionIndexPath.section) }
        self.posts.insert(contentsOf: newPosts, at: self.posts.count)
        self.collectionView.performBatchUpdates(  {
            
            self.collectionView.insertItems(at: insertionIndexPaths)
            
        })
        
    }
    
    func getRestaurantSummary(restaurant_id: String) async {
        self.RestaurantImageView.image = nil
        do {
            let restaurant = try await RestaurantManager.shared.getRestaurantIDasync(restaurantID: restaurant_id)
            guard let restaurant = restaurant else {
                throw RestaurantError.NotFoundRestaurant
            }
            self.restaurant = restaurant
            configureOpeningTime(restaurant: restaurant)
            if let restaurantImage = restaurant.image {
                self.RestaurantImageView.image = restaurantImage
            } else {
                Task(priority : .background) {
                    let restaurantImage = try? await self.restaurant.imageURL?.getImageFromURL()
                    self.restaurant.image = restaurantImage
                    self.RestaurantImageView.image = restaurantImage
                }
            }
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
            if reload {
                self.posts = newPosts
                self.collectionView.reloadSections([0])
                return
            }
            if newPosts.count > 0 {
                insertPostsReloadSection(newPosts: newPosts)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func search(restaurantname : String, restautrantaddress: String?, restaurantID: String) async  {
        guard self.restaurantID != restaurantID else {
            return
        }
        self.restaurantID = restaurantID
        RestaurantNameLabel.text = restaurantname
        RestaurantAddressLabel.text = restautrantaddress
        self.posts.removeAll()
        self.collectionView.reloadSections([self.enterCollectionIndexPath.section])
        self.openingTimeStackView.arrangedSubviews.forEach() { view in
            openingTimeStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        Task {
            await getRestaurantSummary(restaurant_id: restaurantID)
        }
        Task {
            await getRestaurantPosts(restaurantID: restaurantID, afterDate: "", reload: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.posts.count > 18 else {
            return
        }
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let tableViewHeight = scrollView.bounds.size.height
        if offsetY > contentHeight - tableViewHeight {
            return
        }
        let diffY = scrollView.contentOffset.y - previousOffsetY
        var newConstant: CGFloat = restaurantDistanceTopAnchor.constant - diffY
        let persent : Float = Float(  (newConstant + self.distanceAndGradeView.bounds.height) / self.distanceAndGradeView.bounds.height )
        if scrollView.contentOffset.y <= 0 {
            distanceAndGradeView.layer.opacity = 1
            UIView.animate(withDuration: 0.1, animations: {
                self.restaurantDistanceTopAnchor.constant = 0
            })
            
            return
        }
        if diffY < 0 {
            newConstant = min( 0  ,newConstant)
        } else if diffY > 0 {
            newConstant = max( -self.distanceAndGradeView.bounds.height ,newConstant)
        }
        distanceAndGradeView.layer.opacity = persent
        restaurantDistanceTopAnchor.constant = newConstant
        previousOffsetY = scrollView.contentOffset.y
    }
    
    
    
}

extension MapGridPostViewController : UICollectionViewDelegate {
    
    func configureCollectionDatasource() -> UICollectionViewDiffableDataSource<PreViewSection, Post>  {
        let datasource = UICollectionViewDiffableDataSource<PreViewSection, Post>(collectionView: self.collectionView) { collectionView, indexPath, post in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridPostCell", for: indexPath) as! GridPostCell
            cell.configureImageView(post: post, image: nil, mediaIndex: 0)
            return cell
        }
        return datasource
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let total = self.posts.count
        if let timestamp = self.posts.last?.timestamp {
            if total - indexPath.row == 6 {
                Task {
                    await getRestaurantPosts(restaurantID: self.restaurantID, afterDate: timestamp, reload: false)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !BasicViewController.shared.isSwiping else {
            return
        }
        presentPostTableViewController(indexPath: indexPath)
    }
    

    
    
    func presentPostTableViewController(indexPath: IndexPath) {
        
        let targetPostCellIndexPath = IndexPath(row: indexPath.row , section: 0)
        
        let controller = RestaurantPostsTableViewController(presentForTabBarLessView: true)

        let nav = SwipeEnableNavViewController(rootViewController: controller)

        controller.bottomBarViewHeight = 0
        controller.posts = posts
        controller.restaurant  = self.restaurant
        controller.currentTableViewIndexPath = targetPostCellIndexPath
        controller.postsTableDelegate = self
        nav.definesPresentationContext = true
        nav.modalPresentationStyle = .overFullScreen
        nav.transitioningDelegate = self
        self.present(nav, animated: true) {
            BasicViewController.shared.swipeDatasourceToggle(navViewController: self.mapGridPostDelegate.navigationController)
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
