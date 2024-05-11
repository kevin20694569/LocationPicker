import UIKit

class MainTabBarViewController: UIViewController, MediaDelegate, UIViewControllerTransitioningDelegate {
    
    static var shared : MainTabBarViewController!
    
    @IBOutlet var tabBar : UITabBar! { didSet {
        tabBar.delegate = self
        tabBar.backgroundColor = .clear
    }}
    
    var bottomBarView : UIView! = UIView()
    
    var finishFirstReload : Bool = false
    
    var currentIndex : Int = 0
    
    var standardTabBarFrameInView : CGRect! = .zero
    
    var standardBottomFrameInView : CGRect! = .zero
    
    var currentViewController : SwipeEnableNavViewController! {
        return viewControllers[currentIndex]
    }
    
    var wholeTabBarView : [UIView]! {
        return [tabBar, bottomBarView]
    }
    
    var tabBarminY : CGFloat! {
        let tabbarFrameinWindow = self.tabBar.superview!.convert(self.tabBar.frame, to: nil)
        let height = UIScreen.main.bounds.height - tabbarFrameinWindow.minY
        return height
    }
    
    var viewControllers: [SwipeEnableNavViewController]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarViewController.shared = self
        childControllerSetup()
        showViewController(at: 0)
        tabBarSetup()


    }
    
    func childControllerSetup() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let NavMainTableViewController = storyboard.instantiateViewController(withIdentifier: "NavMainTableViewController")  as! SwipeEnableNavViewController
        let NavUploadPostViewController = storyboard.instantiateViewController(withIdentifier: "NavUploadPostViewController")  as! SwipeEnableNavViewController
        let NavProfileViewController = storyboard.instantiateViewController(withIdentifier: "NavUserProfileViewController")  as! SwipeEnableNavViewController
        let NavPlaylistMapViewController = storyboard.instantiateViewController(withIdentifier: "NavPlaylistMapViewController") as! SwipeEnableNavViewController
        
        viewControllers = [NavMainTableViewController, NavUploadPostViewController, NavProfileViewController, NavPlaylistMapViewController]
    }
    
    func tabBarSetup() {
        
        for (index, item) in tabBar.items!.enumerated() {
            let image = item.image?.withConfiguration(UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .semibold)))
            item.selectedImage = image
            item.image = image
            item.tag = index
        }
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.selectedItem?.isEnabled = true
        finishFirstReload = true

        bottomBarView.backgroundColor = .backgroundPrimary
        
        self.view.addSubview(tabBar)
        self.view.addSubview(bottomBarView)
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        tabBar.layoutIfNeeded()
        standardTabBarFrameInView = tabBar.frame
    }


    @objc func tabBarButtonTapped(_ sender: UIButton) {
        // 在按鈕點擊時切換到相應的視圖
        if let index = tabBar.subviews.firstIndex(of: sender) {
            showViewController(at: index)
        }
    
    }
    
    func layoutTabBarAndBottomView() {
        
        wholeTabBarView.forEach() {
            self.view.addSubview($0)
            $0.layoutIfNeeded()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabbarFrameinWindow = self.tabBar.superview!.convert(self.tabBar.frame, to: nil)
        let height = UIScreen.main.bounds.height - tabbarFrameinWindow.minY
        Constant.bottomBarViewHeight = height
        bottomBarView.translatesAutoresizingMaskIntoConstraints = true
        bottomBarView.frame = CGRect(x: tabBar.frame.minX, y: tabBar.frame.maxY, width: tabBar.frame.width, height: height - tabBar.frame.height)
        standardBottomFrameInView = CGRect(x: tabBar.frame.minX, y: tabBar.frame.maxY, width: tabBar.frame.width, height: height - tabBar.frame.height)
    }
    
    func showViewController(at index: Int) {
        let lastIndex = self.currentIndex
        let selectedViewController = viewControllers[index]
        
        if index != 0 {
            BasicViewController.shared.swipeEnable(bool: false)
        } else {
            BasicViewController.shared.swipeDatasourceToggle(navViewController: selectedViewController)
        }
        
        currentIndex = index
        view.addSubview(selectedViewController.view)
        selectedViewController.didMove(toParent: self)
        
        // 隱藏其他視圖控制器
        for (i, viewController) in viewControllers.enumerated() {
            
            if i != index {
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
            
        }
        self.wholeTabBarView.forEach() {
            self.view.addSubview($0)
        }
        
        self.tabBar.selectedItem = tabBar.items?[index]
        
        if index == lastIndex && self.finishFirstReload {
            let cuurentViewController = self.currentViewController
            if let nav = currentViewController.presentedViewController as? SwipeEnableNavViewController,
               nav.viewControllers.count == 1,
               nav.presentedViewController == nil {
                self.currentViewController.dismiss(animated: true) {
                    BasicViewController.shared.swipeDatasourceToggle(navViewController: cuurentViewController)
                }
            } else {
                let bounds = UIScreen.main.bounds
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut   , animations: {
                    self.currentViewController.presentedViewController?.view.frame.origin.x += bounds.width
                }) { bool in
                    self.currentViewController.dismiss(animated: false) {
                        BasicViewController.shared.swipeDatasourceToggle(navViewController: cuurentViewController)
                    }
                }
            }

            self.currentViewController.popToRootViewController(animated: true)
            if let reloadAnimator  = currentViewController.viewControllers.first as? BackToReloadMediaAnimator  {
                reloadAnimator.collectionView.isHidden = false
                reloadAnimator.reloadCollectionCell(backCollectionIndexPath: reloadAnimator.enterCollectionIndexPath)
            }
            
            
            
        }
       
        if let mediaViewController =  BasicViewController.topMostViewController(self.currentViewController) as? MediaDelegate {
            mediaViewController.playCurrentMedia()
        }
        
        
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissLikePopAnimator()
    }
    
    
    
    
    func pauseCurrentMedia() {
        if finishFirstReload {
            if let controller = BasicViewController.topMostViewController(currentViewController) as? MediaDelegate {
                controller.pauseCurrentMedia()
            }
        }
    }
    
    func playCurrentMedia() {
        if finishFirstReload {
            if let controller = BasicViewController.topMostViewController(currentViewController) as? MediaDelegate {
                controller.playCurrentMedia()
            }
        }
    }
    
}

extension MainTabBarViewController: UITabBarDelegate {
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.currentIndex != item.tag {
            if let mediaViewController = BasicViewController.topMostViewController(currentViewController) as? MediaDelegate {
                mediaViewController.pauseCurrentMedia()
            }
        }
        showViewController(at: item.tag)
    }
    
    
    
}

