import UIKit
import SHFullscreenPopGestureSwift
class SwipeEnableNavViewController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
        navigationItem.backBarButtonItem?.isEnabled = true
        interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.backButtonTitle = ""
        definesPresentationContext = true

        self.navigationBar.barTintColor = .clear
        self.navigationBar.backgroundColor = .clear
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewControllers.first?.navigationItem.backButtonTitle = ""
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self)
        toVC.navigationItem.backButtonTitle = ""
        return nil
    }
    
    

}

