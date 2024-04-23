import UIKit
import AVFoundation

class PresentWholePageMediaViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate  {
     
    var fadeInSubviews : [UIView]! = []
    
    var fadeOutSubviews : [UIView?]! = []
    
    var playerViews : [UIView]?
    
    var initCornerRadius : CGFloat!
    
    var transitionToIndexPath : IndexPath!
    
    let mediaTargetRadius : CGFloat = 0
    
    let toViewTargetRadius : CGFloat = Constant.standardCornerRadius
    
    weak var transitionContext : UIViewControllerContextTransitioning!
    
    weak var toViewController : WholePageCollectionViewAnimatorDelegate!
    
    weak var fromViewController : MediaCollectionViewAnimatorDelegate!
    
    weak var transitionPlayerLayer : AVPlayerLayer?
    
    weak var transitionImageView : UIImageView?
    
    var duration : TimeInterval!
    
    var initFrame : CGRect!
    var targetFrame : CGRect!
    
    init(transitionToIndexPath : IndexPath, toViewController : WholePageCollectionViewAnimatorDelegate, fromViewController : MediaCollectionViewAnimatorDelegate) {
        super.init()
        self.toViewController = toViewController
        self.transitionToIndexPath = transitionToIndexPath
        self.fromViewController = fromViewController
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        if !transitionCompleted {
            print("tran problem")
            return
        }

        startFadeInBottomBarView()
        self.toViewController.collectionView.isHidden = false

        transitionPlayerLayer?.removeAllAnimations()
        fromViewController.reloadCollectionCell(backCollectionIndexPath: fromViewController.enterCollectionIndexPath)
        
        transitionPlayerLayer?.isHidden = true
        transitionImageView?.isHidden = true
        self.fadeOutSubviews.forEach() {
            $0?.alpha = 0
        }
        self.fadeInPlyaerViewStartAnimation()
        
        [toViewController.view, fromViewController.view].forEach { view in
            view?.isUserInteractionEnabled = true
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let NavtoViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        self.fadeOutSubviews.insert(contentsOf: fromViewController.getFadeInSubviews(), at: 0)
        duration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: NavtoViewController)
        NavtoViewController.view.frame = finalFrame
        self.transitionContext = transitionContext
        let containerView = transitionContext.containerView
        
        self.fadeInSubviews = toViewController.getFadedSubviews()
        self.playerViews = toViewController.getPlayerSubviews()
        
        self.fadeInSubviews.forEach({ view in
            view.alpha = 0
        })
        self.playerViews?.forEach { view in
            view.alpha = 0
        }
        let fromHiddenSubviews = self.fromViewController.getFadeInSubviews()
        fromHiddenSubviews.forEach { view in
            view?.alpha = 0
        }

        toViewController.collectionView.isHidden = true
        toViewController.collectionView.backgroundColor = .clear
        performWholePageCornerRadiusAnimated(wholePageviewController: NavtoViewController)

        self.fromViewController.navigationController?.view.addSubview(containerView)

        if let fromTabbarViewController = transitionContext.viewController(forKey: .from) as? MainTabBarViewController {
            fromTabbarViewController.wholeTabBarView.forEach() {
                self.fromViewController.navigationController?.view.addSubview($0)
            }
        }
        startBottomBarBackgroundFadeToBlack(bottomBarView: MainTabBarViewController.shared.tabBar)
        containerView.addSubview(NavtoViewController.view)
        self.toViewController.blurView.isHidden = true
        
        self.toViewController.collectionView.isPagingEnabled = false
        self.toViewController.collectionView.scrollToItem(at: self.transitionToIndexPath, at: .centeredHorizontally, animated: false)
        self.toViewController.collectionView.isPagingEnabled = true
        toViewController.view.layoutIfNeeded()

        DispatchQueue.main.async {
            if let toImageViewCollectionCell = self.toViewController.collectionView.visibleCells.first as? WholeImageViewCollectionCell {
                self.targetFrame = toImageViewCollectionCell.contentView.convert(toImageViewCollectionCell.imageView.frame, to: containerView)

            } else if let toPlayerLayerCollectionCell = self.toViewController.collectionView.visibleCells.first as? WholePlayerLayerCollectionCell {
                self.targetFrame = toPlayerLayerCollectionCell.contentView.convert(toPlayerLayerCollectionCell.playerLayer.frame, to: containerView)
            }
            self.fadeInBasicViewStartAnimation()
            
            
            if let fromImageViewCell = self.fromViewController.currentCollectionCell as? ImageViewCollectionCell {
                
                self.initCornerRadius = fromImageViewCell.imageView.layer.cornerRadius
                self.transitionImageView = fromImageViewCell.imageView
                self.initFrame = fromImageViewCell.contentView.convert(fromImageViewCell.imageView.frame, to: containerView)
                self.performToViewControllerImageView()
            } else if let fromPlayerLayerCell = self.fromViewController.currentCollectionCell as? PlayerLayerCollectionCell {
                self.initCornerRadius = fromPlayerLayerCell.playerLayer.cornerRadius
                self.transitionPlayerLayer = fromPlayerLayerCell.playerLayer
                self.initFrame = fromPlayerLayerCell.contentView.convert(fromPlayerLayerCell.playerLayer.frame, to: containerView)
                self.performToViewControllerPlayerLayer()
                
            } else {
                transitionContext.completeTransition(false)
            }
        }

    }
    
    func startBottomBarBackgroundFadeToBlack(bottomBarView : UIView) {
        if let bottomBarView = bottomBarView as? UITabBar {
            UIView.transition(with: bottomBarView, duration: duration) {
                //bottomBarView.barTintColor =  UIColor.black
               // bottomBarView.layoutIfNeeded()
            }
        }
    }
    
    func performWholePageCornerRadiusAnimated(wholePageviewController : UIViewController) {
        let durationTime = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: durationTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, animations: {
            wholePageviewController.view.layer.cornerRadius = self.toViewTargetRadius
        })
    }
    
    func performToViewControllerImageView() {
        guard let NavtoViewController = self.transitionContext.viewController(forKey: .to) else {
            self.transitionContext.completeTransition(true)
            return
        }
        let imageView = self.transitionImageView!
        imageView.frame = initFrame
        let duration = transitionDuration(using: transitionContext )

        let containerView = self.transitionContext.containerView

        containerView.insertSubview(imageView, belowSubview: NavtoViewController.view )
        performNavViewControllerAnimation()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
            imageView.frame = self.targetFrame
            imageView.layer.cornerRadius = self.mediaTargetRadius
        }) { bool in
            if bool {
                self.transitionContext.completeTransition(true)
            }
        }
    }
    func performToViewControllerPlayerLayer() {
        let playerLayer = self.transitionPlayerLayer!
        let duration = transitionDuration(using: transitionContext )
        let NavtoViewController = self.transitionContext.viewController(forKey: .to) as! UINavigationController
        let containerView = self.transitionContext.containerView
        performNavViewControllerAnimation()

        containerView.layer.insertSublayer(playerLayer,  below : NavtoViewController.view.layer)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock {
            self.transitionContext.completeTransition(true)
        }
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        let RadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        let positionXAnimation = CABasicAnimation(keyPath: "position.x")
        let positionYAnimation = CABasicAnimation(keyPath: "position.y")
        
        [boundsAnimation, RadiusAnimation, positionXAnimation, positionYAnimation].forEach { animation in
            animation.duration = duration
            animation.timingFunction = Constant.wholePageCAMediaTimingFunction
            animation.isRemovedOnCompletion = false
            animation.fillMode = .both
        }
        boundsAnimation.fromValue = NSValue(cgRect: initFrame)

        boundsAnimation.toValue = NSValue(cgRect: targetFrame)
        
        RadiusAnimation.fromValue = initCornerRadius
        RadiusAnimation.toValue = mediaTargetRadius
        
        positionXAnimation.fromValue = initFrame.midX
        positionXAnimation.toValue = targetFrame.midX
        
        positionYAnimation.fromValue = initFrame.midY
        positionYAnimation.toValue = targetFrame.midY
        [boundsAnimation, RadiusAnimation, positionXAnimation, positionYAnimation].forEach { animation in
            playerLayer.add(animation, forKey: "\(animation)")
        }

        
       
        CATransaction.commit()

    }
    
    func performNavViewControllerAnimation() {

        guard let NavtoViewController = self.transitionContext.viewController(forKey: .to) else {
            self.transitionContext.completeTransition(false)
            return
        }
        
        NavtoViewController.view.isHidden = false
        let duration = self.transitionDuration(using: transitionContext)
        let containerView = self.transitionContext.containerView
        let finalFrame =  self.transitionContext.finalFrame(for: NavtoViewController)
        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        containerView.layer.mask = mask
        mask.frame = initFrame
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        let maskboundsAnimation = CABasicAnimation(keyPath: "bounds")
        let maskRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        let positionXAnimation = CABasicAnimation(keyPath: "position.x")
        let positionYAnimation = CABasicAnimation(keyPath: "position.y")
        
        [maskboundsAnimation, maskRadiusAnimation, positionXAnimation, positionYAnimation].forEach { animation in
            animation.duration = duration - 0.1
            animation.timingFunction = Constant.wholePageCAMediaTimingFunction
            animation.isRemovedOnCompletion = false
            animation.fillMode = .both
        }
        maskboundsAnimation.fromValue = NSValue(cgRect: initFrame)

        maskboundsAnimation.toValue = NSValue(cgRect: finalFrame)
        
        maskRadiusAnimation.fromValue = initCornerRadius
        maskRadiusAnimation.toValue = toViewTargetRadius
        
        positionXAnimation.fromValue = initFrame.midX
        positionXAnimation.toValue = finalFrame.midX
        
        positionYAnimation.fromValue = initFrame.midY
        positionYAnimation.toValue = finalFrame.midY
        [maskboundsAnimation, maskRadiusAnimation, positionXAnimation, positionYAnimation].forEach { animation in
            mask.add(animation, forKey: "\(animation)")
        }
        NavtoViewController.view.layer.cornerRadius = toViewTargetRadius
        CATransaction.commit()
    }
    
    func fadeInBasicViewStartAnimation() {
        UIView.animate(withDuration: transitionDuration(using: transitionContext) / 2, delay: 0.2, animations: {
            self.fadeInSubviews.forEach { view in
                if (view is UILabel && view.tag != 5) || view is UISlider {
                    return
                }
                view.alpha = 1
            }
        })
    }
    
    func fadeInPlyaerViewStartAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.playerViews?.forEach { view in
                if view is UILabel {
                    view.alpha = 0
                    return
                }
                view.alpha = 1
            }
        })
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func startFadeInBottomBarView() {

        UIView.animate(withDuration: 0.2, animations : {
            self.toViewController.bottomBarView.alpha = 1
        }) { bool in
            self.toViewController.blurView.isHidden = false
        }
    }
}










