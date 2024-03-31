
import UIKit
class DismissLikePopAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 2
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
       let duration = self.transitionDuration(using: transitionContext)
        let bounds = UIScreen.main.bounds
        let toViewController = transitionContext.viewController(forKey: .to)
        let fromViewController = transitionContext.viewController(forKey: .from)
        UIView.animate(withDuration: 5, animations: {
            fromViewController?.view.frame.origin.x += bounds.width
            
        }) { bool in
            transitionContext.completeTransition(true)
        }
    }
    
}
