import UIKit

class BasicViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var startTime : Date?
    
    var startX : CGFloat?
    
    let bounds : CGRect! = UIScreen.main.bounds
    
    var page : Int! = 1
    
    var pageDict : [Int : CGRect]! = [ : ]
    
    var currentViewController : UIViewController? {
        return viewControllerArray[self.page]
    }

    static var shared : BasicViewController!
    
    var navMapViewController : NavMapViewController!
    
    var mainTabBarViewController : MainTabBarViewController!
    
    var navChatRoomViewController : SwipeEnableNavViewController!
    
    var viewControllerArray : [UIViewController]! = []
    
    var swipePanGesture : UIPanGestureRecognizer! = UIPanGestureRecognizer()
    
    var isSwiping : Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BasicViewController.shared = self
        initViewControllerSetup()
        gestureSetup()
    }
    
    func initViewControllerSetup() {
        navMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavMapViewController") as? NavMapViewController
        mainTabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomTabBarController")  as? MainTabBarViewController

        navChatRoomViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavChatRoomViewController") as? SwipeEnableNavViewController
        viewControllerArray = [navMapViewController, mainTabBarViewController, navChatRoomViewController]
    }
    
    func gestureSetup() {
        swipePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_ :)))
        swipePanGesture.cancelsTouchesInView = false
        swipePanGesture.delegate = self
        self.view.addGestureRecognizer(swipePanGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let bounds = UIScreen.main.bounds
        self.view.frame = CGRect(x: -bounds.width, y: bounds.minY, width: bounds.width * 3, height: bounds.height)
        
        for (index, viewController) in viewControllerArray.enumerated() {
            let minX = bounds.width * CGFloat(index)
            let frame = CGRect(x: minX, y: bounds.minY, width: bounds.width, height: bounds.height)
            let viewMinX = -bounds.width * CGFloat(index)
            let ViewFrame = CGRect(x: viewMinX , y: bounds.minY, width: bounds.width * 3, height: bounds.height)
            
            self.pageDict[index] = ViewFrame
            viewController.view.alpha = 0
            viewController.view.frame = frame
            self.view.addSubview(viewController.view)
        }
        startViewFadeIn()
        Constant.safeAreaInsets = self.view.safeAreaInsets
        
    }
    
    private func startViewFadeIn() {
        UIView.animate(withDuration: 0.1, animations: {
            self.viewControllerArray.forEach { viewController in
                viewController.view.alpha = 1
            }
        })
        
    }
    
    public func swipeDatasourceToggle(navViewController : UINavigationController?) {
        guard let navViewController = navViewController else {
            return
        }
        
        let navMain = self.mainTabBarViewController.viewControllers?.first as? UINavigationController
        let mainTableViewController = navMain?.viewControllers.first
        let mapViewController = self.navMapViewController.viewControllers.first
        
        let chatRoomViewController = self.navChatRoomViewController.viewControllers.first
        if Self.topMostViewController(navViewController) == mainTableViewController || Self.topMostViewController(navViewController) == mapViewController || Self.topMostViewController(navViewController) == chatRoomViewController    {
            BasicViewController.shared.swipeEnable(bool: true)
        } else {
            BasicViewController.shared.swipeEnable(bool: false)
        }
        
        
    }
    
    
    static func topMostViewController(_ viewController: UIViewController) -> UIViewController? {
        if let presentedViewController = viewController.presentedViewController {
            return topMostViewController(presentedViewController)
        }
        if let pageViewController = viewController as? UIPageViewController,
           let currentViewController = pageViewController.viewControllers?.first {
            return topMostViewController(currentViewController)
        }
        if let navigationController = viewController as? UINavigationController {
            return topMostViewController(navigationController.visibleViewController ?? UIViewController())
        }
        if let tabBarController = viewController as? UITabBarController {
            return topMostViewController(tabBarController.selectedViewController ?? UIViewController())
        }
        return viewController
    }
    
    func pauseTopViewController() {
        guard let currentViewController = currentViewController else {
            return
        }
        if let topMediaController = Self.topMostViewController(currentViewController) as? MediaDelegate {
            topMediaController.pauseCurrentMedia()
        }
    }
    
    func playTopViewController() {
        guard let currentViewController = currentViewController else {
            return
        }
        if let topMediaController = Self.topMostViewController(currentViewController) as? MediaDelegate {
            topMediaController.playCurrentMedia()
        }
    }
    
}
extension BasicViewController {
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began :
            isSwiping = true
            
        case .changed:
            if startX == nil {
                startX = self.view.frame.origin.x
            }
            if startTime == nil {
                startTime = Date()
            }
            let deltaX = translation.x
            if deltaX < 0 && self.view.frame.origin.x <= -bounds.width * 2 {
                return
            } else if deltaX > 0 && self.view.frame.origin.x >= 0  {
                return
            }
            
            self.view.frame.origin.x += deltaX
            if let chatRoomViewController = self.navChatRoomViewController.viewControllers.first  as?  ChatRoomViewController  {
                if !chatRoomViewController.hasBeenFirstAppear {

                    if self.view.frame.origin.x < -UIScreen.main.bounds.width - 20  {
                        chatRoomViewController.refreshChatRoomsPreview()
                        chatRoomViewController.hasBeenFirstAppear = true
                    }

                }
            }

            recognizer.setTranslation(.zero, in: self.view)
        case .ended :
            
            var offsetX : CGFloat = 0
            if let startX = startX {
                offsetX = self.view.frame.origin.x - startX
            }
            startX = nil
            
            if let startTime = startTime {
                self.startTime = nil
                let endTime = Date()
                let elapsedTime = endTime.timeIntervalSince(startTime)
                let thresholdTime : CGFloat = 0.06
                if elapsedTime < thresholdTime {
                    if offsetX < -2 {
                        startSwipe(toPage: self.page + 1)
                        return
                    } else if offsetX > 2 {
                        startSwipe(toPage: self.page - 1)
                        return
                    }
                }
            }
            let thresholdX : CGFloat = 85

            if offsetX < -thresholdX {
                startSwipe(toPage: self.page + 1)
            } else if offsetX > thresholdX {
                startSwipe(toPage: self.page - 1)
            } else {
                startSwipe(toPage: self.page)
            }
            
        default:
            break
        }
        recognizer.setTranslation(.zero, in: self.view)
    }
    
    public func swipeEnable(bool : Bool) {
        self.swipePanGesture.isEnabled = bool
    }
    
    
    private func switchPage() -> Int {
        if self.view.frame.origin.x < 0 && self.view.frame.origin.x > -bounds.width {
            return 0
        } else if self.view.frame.origin.x < 0 && self.view.frame.origin.x < -bounds.width * 2 {
            return 2
        } else if self.view.frame.origin.x < -bounds.width && self.view.frame.origin.x > -bounds.width * 2 {
            return 1
        } else {
            return self.page
        }
    }
    
    
    public func startSwipe(toPage : Int) {
        guard toPage >= 0 && toPage <= 2 else {
            return
        }
        let lastPage = self.page!
        self.page = toPage
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame = self.pageDict[toPage]!
        }) { bool in
            self.isSwiping = false
            if toPage == 0 {
                let mapViewController = self.navMapViewController.viewControllers.first as? MapViewController
                if let navMain = self.mainTabBarViewController.viewControllers?.first as? NavMainTableViewController,
                   let mainTableViewController = navMain.viewControllers.first as? MainPostTableViewController {
                    guard let post = mainTableViewController.tableViewCurrentCell?.currentPost  else {
                        return
                    }
                    mapViewController?.Restaurant  = Restaurant(name: post.restaurant?.name, Address: post.restaurant?.Address, restaurantID: post.restaurant!.ID, image: nil)
                    mapViewController?.configure(restaurantName: post.restaurant!.name, address: post.restaurant!.Address, restaurantID:  post.restaurant!.ID)
                }
            }
            if let fromMediaViewController = BasicViewController.topMostViewController(self.viewControllerArray[lastPage]) as? MediaDelegate {
                if lastPage == toPage  {
                    fromMediaViewController.playCurrentMedia()
                } else {
                    fromMediaViewController.pauseCurrentMedia()
                }
            }

            
            if let toMediaViewController =  BasicViewController.topMostViewController(self.viewControllerArray[toPage]) as? MediaDelegate  {
                toMediaViewController.playCurrentMedia()
            }
            
            
            
        }
    }
    
}
