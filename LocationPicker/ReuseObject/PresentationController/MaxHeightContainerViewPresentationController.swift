import UIKit



class MaxFrameContainerViewPresentationController: UIPresentationController, MaxFrameController {
    var maxWidth: CGFloat! = UIScreen.main.bounds.width
    
    let cornerRadiusFloat = Constant.standardCornerRadius
    
    var maxHeight : CGFloat! = UIScreen.main.bounds.height
    
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, maxWidth: CGFloat, maxHeight: CGFloat!) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        self.maxHeight = maxHeight
        self.maxWidth = maxWidth
        if let presented = presentedViewController as? MaxFrameController {
            presented.maxHeight = self.maxHeight
            presented.maxWidth  = self.maxWidth
        }
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    
    @objc func dismissPresented() {
        presentingViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else {
             return
         }
        let bounds = UIScreen.main.bounds

        containerView.frame = CGRect(x: 0, y: bounds.height -  maxHeight, width: presentedViewController.view.frame.width, height: maxHeight)
    }
    
    

}
class MaxFramePresentedViewPresentationController : UIPresentationController, MaxFrameController {
    
    var cornerRadius : CGFloat!  {
        8
    }
    var maxWidth : CGFloat!
    var blurView : UIView! = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    var maxHeight: CGFloat!
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, maxWidth : CGFloat!,  maxHeight: CGFloat!) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        if let presented = presentedViewController as? MaxFrameController {
            presented.maxHeight = self.maxHeight
            presented.maxWidth = self.maxWidth
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = UIScreen.main.bounds
        let x = (bounds.width - maxWidth) / 2
        return CGRect(x: x, y: bounds.height -  maxHeight, width: self.maxWidth, height: maxHeight - Constant.safeAreaInsets.bottom)
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    
    @objc func dismissPresented(_ gesture : UITapGestureRecognizer) {
        if let presentedView = self.presentedView {
            let touchLocation = gesture.location(in: self.presentedView)
            if let controller = presentedViewController as? LimitSelfFramePresentedView {
                guard controller.canTouchOutsideToDismiss else {
                    return
                }
            }
                
            
            guard !presentedView.bounds.contains(touchLocation) else {
                return
            }
            
            
            
            presentingViewController.dismiss(animated: true)
            
        }

    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        startBlurViewFadeIn()
        addDismissGesture()
        presentedView?.layer.cornerRadius = self.cornerRadius
        presentedView?.clipsToBounds = true

    }
    

    
    override func dismissalTransitionWillBegin() {
        startBlurViewFadeOut()
    }
    
    func startBlurViewFadeIn() {
        let view = blurView!
        view.frame = self.containerView!.bounds
        self.containerView?.insertSubview(view, at: 0)
        view.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0.6
            
        })
    }
    
    func startBlurViewFadeOut() {
        let view = blurView!
        self.containerView?.insertSubview(view, at: 0)
        
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0
        }) { [self] bool in
            view.removeFromSuperview()
            self.blurView = nil
        }
    }
    
    func addDismissGesture() {
        containerView?.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresented( _ :)))
        gesture.cancelsTouchesInView = true
        self.containerView?.addGestureRecognizer(gesture)
    }

    
}
