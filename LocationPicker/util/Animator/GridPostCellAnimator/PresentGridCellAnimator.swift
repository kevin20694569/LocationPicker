

import UIKit
import AVFoundation

class PresentGridCellAnimator : NSObject, UIViewControllerAnimatedTransitioning  {
    var transitionContext : UIViewControllerContextTransitioning!
    
    var fadedSubviews : [UIView]!
    
    var transitionImageView : UIImageView!
    
    var fadeInSubviews : [UIView?]!
    
    var toViewController : CollectionViewInTableViewMediaAnimatorDelegate!
    
    var fromViewController : GridPostCollectionViewAnimatorDelegate!
    
    var targetCellRadius : CGFloat!
    
    var tableViewTransitionToIndexPath : IndexPath!
    
    var initFrame : CGRect!
    
    var targetFrame : CGRect!
    
    var initCornerRadius : CGFloat!
    
    var collectionViewTransitionToIndexPath : IndexPath!
    
    let mediaTargetRadius : CGFloat = 0
    
    let toViewTargetRadius : CGFloat = Constant.standardCornerRadius
    
    init(transitionToIndexPath : IndexPath , toViewController : CollectionViewInTableViewMediaAnimatorDelegate, fromViewController : GridPostCollectionViewAnimatorDelegate, collectoinViewTransionToIndexPath : IndexPath) {
        
        self.tableViewTransitionToIndexPath = transitionToIndexPath
        self.toViewController = toViewController
        self.fromViewController = fromViewController
        self.collectionViewTransitionToIndexPath = collectoinViewTransionToIndexPath
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    
    func animationEnded(_ transitionCompleted: Bool) {
        if !transitionCompleted {
            print("presentGridPostCell Fail")
        }
        toViewController.collectionView.isHidden = false
        transitionImageView.removeFromSuperview()
        fromViewController.reloadCollectionCell(backCollectionIndexPath: fromViewController.enterCollectionIndexPath)
        fadeInSoundImageViewStartAnimation()
        toViewController.reloadCollectionCell(backCollectionIndexPath:  toViewController.currentMediaIndexPath)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let NavtoViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        
        let finalFrame = transitionContext.finalFrame(for: NavtoViewController)
        
        let containerView = transitionContext.containerView
        
        NavtoViewController.view.frame = finalFrame
        
        self.transitionContext = transitionContext
        self.fadedSubviews = toViewController.getFadedSubviews()
        
        self.fromViewController.navigationController?.view.addSubview(containerView)
        if let fromTabbarViewController = transitionContext.viewController(forKey: .from) as? MainTabBarViewController {
            fromTabbarViewController.wholeTabBarView.forEach() {
                self.toViewController.navigationController?.view.addSubview($0)
            }
        }

        let fromImageViewCell = self.fromViewController.enterCollectionCell as! GridPostCell
        self.initCornerRadius = fromImageViewCell.cornerRadius
        let fromImageViewInitFrame = fromImageViewCell.contentView.superview?.convert(fromImageViewCell.contentView.frame, to: containerView)
        self.transitionImageView = fromImageViewCell.imageView
        self.initFrame = fromImageViewInitFrame

        NavtoViewController.view.subviews.forEach { view in
            view.alpha = 0
        }
        NavtoViewController.view.alpha = 0
        self.fadeInSubviews = self.toViewController.getFadeInSubviews()
        
        DispatchQueue.main.async {
            containerView.addSubview(NavtoViewController.view)
            containerView.layoutIfNeeded()
            if let toImageTableCell = self.toViewController.collectionView.visibleCells.first as? StandardImageViewCollectionCell {
                let frame = toImageTableCell.contentView.convert(toImageTableCell.imageView.frame, to: containerView )
                
                self.targetFrame = frame
   
                self.targetCellRadius = toImageTableCell.mediaCornerRadius
                self.fadeInSubviews.forEach { view in
                    view?.alpha = 0
                }
                
                
            } else if let toPlayerLayerCell = self.toViewController.collectionView.visibleCells.first as? StandardPlayerLayerCollectionCell {
                let frame = toPlayerLayerCell.contentView.convert(toPlayerLayerCell.playerLayer.frame, to: containerView )
                self.targetFrame = frame
                self.targetCellRadius = toPlayerLayerCell.mediaCornerRadius
                self.fadeInSubviews.forEach { view in
                    view?.alpha = 0
                }
            } else {
                self.transitionContext.completeTransition(false)
                return
            }
            self.toViewController.collectionView.isHidden = true
            self.performToViewControllerImageView()
        }
        
        
    }
    
    
    func performToViewControllerImageView() {
        let duration = transitionDuration(using: transitionContext )

        guard let NavtoViewController = self.transitionContext.viewController(forKey: .to) else {
            self.transitionContext.completeTransition(false)
            return
        }
        let finalFrame = transitionContext.finalFrame(for: NavtoViewController)

        let containerView = self.transitionContext.containerView

        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        NavtoViewController.view.frame = finalFrame
        NavtoViewController.view.layer.mask = mask
        mask.frame = initFrame
        containerView.clipsToBounds = true

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
        performImageViewZoomInAnimation(initFrame: initFrame, targetFrame: targetFrame)
        
    }
    
    
    func performImageViewZoomInAnimation(initFrame : CGRect, targetFrame : CGRect) {
        let duration = self.transitionDuration(using: transitionContext)
        let containerView = self.transitionContext.containerView
        let NavtoViewController = self.transitionContext.viewController(forKey: .to)
        let imageView = self.transitionImageView!
        NavToViewFadeIn()
        NavtoViewController?.view.isHidden = false
        
        containerView.insertSubview(imageView, aboveSubview: NavtoViewController!.view)
        imageView.frame = initFrame
        imageView.layer.cornerRadius = initCornerRadius
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(Constant.presentPostTableViewCAMediaTimingFunction)

        UIView.animate(withDuration: duration ,  animations: {
            
            self.transitionImageView.frame = targetFrame
            self.transitionImageView.layer.cornerRadius = self.targetCellRadius
        }) { bool in
            self.transitionContext.completeTransition(true)
            
        }
        CATransaction.commit()
    }
    
    func NavToViewFadeIn() {
        let NavTo = self.transitionContext.viewController(forKey: .to)
        UIView.animate(withDuration: transitionDuration(using: transitionContext) , delay: 0, animations: {
            NavTo?.view.subviews.forEach({ view in
                view.alpha = 1
            })
            NavTo?.view.alpha = 1
        })
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





