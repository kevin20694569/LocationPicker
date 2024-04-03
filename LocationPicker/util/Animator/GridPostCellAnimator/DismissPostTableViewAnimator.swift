import UIKit
import AVFoundation

class DismissPostTableViewAnimator : NSObject, UIViewControllerAnimatedTransitioning  {
    var transitionContext : UIViewControllerContextTransitioning!
    
    var fadedSubviews : [UIView]!
    
    var transitionImageView : UIImageView!
    
    var transitionPlayerLayer : AVPlayerLayer!
    
    var fadeInSubviews : [UIView?]!
    
    weak var toViewController : GridPostCollectionViewAnimatorDelegate!
    
    weak var fromViewController : CollectionViewInTableViewMediaAnimatorDelegate!
    
    var navFrom : UIViewController!
    
    var targetCellRadius : CGFloat!
    
    var initFrame : CGRect!
    
    var targetFrame : CGRect!
    
    var initCornerRadius : CGFloat!
    
    var collectionViewTransitionToIndexPath : IndexPath!
    
    var mediaTargetRadius : CGFloat = Constant.GridPostCellRadius
    
    let toViewTargetRadius : CGFloat = Constant.GridPostCellRadius
    
    var duration : TimeInterval!
    
    init(transitionToIndexPath : IndexPath , toViewController : GridPostCollectionViewAnimatorDelegate, fromViewController : CollectionViewInTableViewMediaAnimatorDelegate) {
        self.collectionViewTransitionToIndexPath = IndexPath(row: fromViewController.currentTableViewIndexPath.row  , section: toViewController.enterCollectionIndexPath.section)
        self.toViewController = toViewController
        self.fromViewController = fromViewController
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    

    
    func animationEnded(_ transitionCompleted: Bool) {
        if !transitionCompleted {
            print("dismissPostTableViewController Fail")
        }
        self.toViewController.reloadCollectionCell(backCollectionIndexPath:  self.collectionViewTransitionToIndexPath)
        self.transitionPlayerLayer?.removeFromSuperlayer()
        self.transitionPlayerLayer?.removeAllAnimations()
        self.transitionPlayerLayer = nil
        self.transitionImageView?.removeFromSuperview()
        self.transitionImageView = nil
        [self.toViewController.view, self.fromViewController.view].forEach { view in
            view?.isUserInteractionEnabled = true
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if let toTabbarViewController = toViewController as? MainTabBarViewController {
            toTabbarViewController.wholeTabBarView.forEach() {
                toTabbarViewController.view.addSubview($0)
            }
        }
        navFrom  = transitionContext.viewController(forKey: .from)
        let finalFrame = transitionContext.finalFrame(for: navFrom)
        navFrom.view.frame = finalFrame
        self.transitionContext = transitionContext
        duration = transitionDuration(using: transitionContext)
        fromViewController.view.isUserInteractionEnabled = false
        toViewController.view.isUserInteractionEnabled = false
        self.toViewController.collectionView.isPagingEnabled = false
        self.toViewController.collectionView.scrollToItem(at: self.collectionViewTransitionToIndexPath, at: .centeredHorizontally, animated: false)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if let toCollectionImageCell = toViewController.collectionView.cellForItem(at: self.collectionViewTransitionToIndexPath) as?
                GridPostCell {
                self.mediaTargetRadius = toCollectionImageCell.cornerRadius
                targetFrame = toCollectionImageCell.contentView.convert(toCollectionImageCell.imageView.frame, to: containerView)
                toCollectionImageCell.imageView.isHidden = true
                
            }  else {
                self.transitionContext.completeTransition(false)
                return
            }
            
            

            if let fromWholeImageCell = fromViewController.currentCollectionCell as? StandardImageViewCollectionCell {
                self.transitionImageView = fromWholeImageCell.imageView
                self.initCornerRadius = fromWholeImageCell.imageView.layer.cornerRadius
                initFrame = fromWholeImageCell.contentView.convert(fromWholeImageCell.imageView.frame, to: containerView)
                let fromViewControllerinitFrame = (fromViewController.view.superview?.convert(fromViewController.view.frame, to: containerView))!
            self.performImageViewZoomOutAnimation(initFrame: initFrame, targetFrame: targetFrame, fromViewControllerinitFrame: fromViewControllerinitFrame)
            
        } else if let fromWholePlayerLayerCell = fromViewController.currentCollectionCell as? StandardPlayerLayerCollectionCell {
            self.initCornerRadius = fromWholePlayerLayerCell.playerLayer.cornerRadius
            self.transitionPlayerLayer = fromWholePlayerLayerCell.playerLayer
            initFrame = fromWholePlayerLayerCell.contentView.layer.convert(fromWholePlayerLayerCell.playerLayer.frame, to: containerView.layer)
            let fromViewControllerinitFrame = (fromViewController.view.superview?.convert(fromViewController.view.frame, to: containerView))!
            
            playerLayerSetAnimationPerform(initFrame: initFrame, targetFrame: targetFrame, fromViewControllerinitFrame: fromViewControllerinitFrame)
            
        } else {
            self.transitionContext.completeTransition(false)
            return
            
        }
    }

        
    }
    func performImageViewZoomOutAnimation(initFrame: CGRect, targetFrame: CGRect, fromViewControllerinitFrame: CGRect)  {
        let imageView = self.transitionImageView!
        let durationTime = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        startFromViewControllerFadeOut()
        performFromBackgroundViewAnimated(fromViewControllerinitFrame: initFrame, targetFrame: targetFrame)
        imageView.frame = initFrame
        containerView.addSubview(imageView)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(Constant.presentPostTableViewCAMediaTimingFunction)
        UIView.animate(withDuration: durationTime, animations: {
            imageView.frame = targetFrame
            imageView.layer.cornerRadius = self.mediaTargetRadius
        }) { bool in
            self.transitionContext.completeTransition(true)
        }
        CATransaction.commit()
    }
    
    func playerLayerSetAnimationPerform(initFrame: CGRect, targetFrame: CGRect, fromViewControllerinitFrame: CGRect) {
        let playerLayer = transitionPlayerLayer!
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        self.startFromViewControllerFadeOut()
        self.performFromBackgroundViewAnimated(fromViewControllerinitFrame: initFrame, targetFrame: targetFrame)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            
            playerLayer.frame = initFrame
            containerView.layer.addSublayer(playerLayer)
            
            CATransaction.setCompletionBlock {
                CATransaction.begin()
                CATransaction.setAnimationDuration(duration - 0.01)
                CATransaction.setCompletionBlock {
                    self.transitionContext.completeTransition(true)
                }
                CATransaction.setAnimationTimingFunction(Constant.presentPostTableViewCAMediaTimingFunction)
                playerLayer.frame = targetFrame
                playerLayer.cornerRadius = self.mediaTargetRadius
                playerLayer.videoGravity = .resizeAspectFill
                CATransaction.commit()
            }
            
            CATransaction.commit()
            
        }
        
        
        
        
    }
    
    func startFromViewControllerFadeOut() {

        let offsetX = (targetFrame.minX + targetFrame.width / 2) - (initFrame.minX + initFrame.width / 2)
        let offsetY = (targetFrame.minY + targetFrame.height / 2) - (initFrame.minY + initFrame.height / 2)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(Constant.presentPostTableViewCAMediaTimingFunction)
        UIView.animate(withDuration: duration, delay: 0, animations: {
            self.navFrom.view.frame.origin.x += offsetX
            self.navFrom.view.frame.origin.y += offsetY
        })
        CATransaction.setAnimationTimingFunction(Constant.presentPostTableViewCAMediaTimingFunction)
        let delay : Double = 0
        UIView.animate(withDuration: duration - delay, delay: delay) {
            self.navFrom.view.alpha = 0
        }
        CATransaction.commit()
    }
    
    
    func performFromBackgroundViewAnimated(fromViewControllerinitFrame: CGRect, targetFrame: CGRect) {
        var fromFrame : CGRect!
        if let fromWholeImageCell = fromViewController.currentCollectionCell as? StandardImageViewCollectionCell {
           fromFrame = fromWholeImageCell.contentView.convert(fromWholeImageCell.imageView.frame, to: navFrom.view)
        } else if let fromWholePlayerLayerCell = fromViewController.currentCollectionCell as? StandardPlayerLayerCollectionCell {
            fromFrame = fromWholePlayerLayerCell.contentView.layer.convert(fromWholePlayerLayerCell.playerLayer.frame, to: navFrom.view.layer)
        }

        let duration = self.transitionDuration(using: self.transitionContext)

        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        navFrom.view.layer.mask = mask
        navFrom.view.clipsToBounds = true
        navFrom.view.layer.masksToBounds = true
        mask.frame = navFrom.view.bounds


        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        let maskboundsAnimation = CABasicAnimation(keyPath: "bounds")
        let maskRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        let positionXAnimation = CABasicAnimation(keyPath: "position.x")
        let positionYAnimation = CABasicAnimation(keyPath: "position.y")
        
        [maskboundsAnimation, maskRadiusAnimation, positionXAnimation, positionYAnimation].forEach { animation in
            animation.duration = duration
            animation.timingFunction = Constant.presentPostTableViewCAMediaTimingFunction
            animation.isRemovedOnCompletion = false
            animation.fillMode = .both
            
        }
        maskboundsAnimation.fromValue = NSValue(cgRect: navFrom.view.frame)
        
        maskboundsAnimation.toValue = NSValue(cgRect: targetFrame)
        
        maskRadiusAnimation.fromValue = initCornerRadius
        maskRadiusAnimation.toValue = toViewTargetRadius

         
        positionYAnimation.fromValue = navFrom.view.frame.midY
        positionYAnimation.toValue = fromFrame.midY
        positionXAnimation.fromValue = navFrom.view.frame.midX
        positionXAnimation.toValue = fromFrame.midX
        [maskboundsAnimation, maskRadiusAnimation, positionXAnimation, positionYAnimation].forEach { animation in
            mask.add(animation, forKey: "\(animation)")
        }
        CATransaction.commit()

        
    }
    
    func fadeInBasicViewStartAnimation() {
        UIView.animate(withDuration: transitionDuration(using: transitionContext) , delay: 0, animations: {
            self.fadedSubviews.forEach { view in
                view.alpha = 1
            }
        })
    }
    
    func fadeInSoundImageViewStartAnimation() {
        UIView.animate(withDuration: 0.2 , delay: 0, animations: {
            self.fadeInSubviews.forEach { view in
                view?.alpha = 1
            }
        })
    }
}





