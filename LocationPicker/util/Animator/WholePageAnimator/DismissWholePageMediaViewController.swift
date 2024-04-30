import UIKit
import AVFoundation

class DismissWholePageMediaViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate  {
    
    var targetCornerRadius : CGFloat!
    
    var fadInSubViews : [UIView?]!
    
    var initCornerRadius : CGFloat!
    
    weak var transitionPlayerLayer : AVPlayerLayer?
    
    weak var transitionImageView : UIImageView?
    
    var transitionContext : UIViewControllerContextTransitioning!
    
    weak var toViewController : MediaCollectionViewAnimatorDelegate!
    
    weak var fromViewController : WholePageCollectionViewAnimatorDelegate!
    
    var initFrame : CGRect!
    
    var targetFrame : CGRect!
    
    var transitionCollectionIndexPath : IndexPath!
    var duration : TimeInterval!
    
    init(transitionToIndexPath : IndexPath, toViewController : MediaCollectionViewAnimatorDelegate, fromViewController : WholePageCollectionViewAnimatorDelegate) {
        super.init()
        self.toViewController = toViewController
        self.transitionCollectionIndexPath = transitionToIndexPath
        self.fromViewController = fromViewController
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
        toViewController.collectionView.isHidden = false
        self.toViewController.reloadCollectionCell(backCollectionIndexPath: transitionCollectionIndexPath)
        
        self.transitionPlayerLayer?.removeFromSuperlayer()
        self.transitionPlayerLayer?.removeAllAnimations()
  
       
        self.transitionPlayerLayer = nil
        self.transitionImageView?.removeFromSuperview()
        self.transitionImageView = nil
        self.fadeInViewStartAnimation()
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
        transitionCollectionIndexPath = IndexPath(row: fromViewController.currentMediaIndexPath.row, section: toViewController.enterCollectionIndexPath.section)
        toViewController.updateCellPageControll(currentCollectionIndexPath: transitionCollectionIndexPath)
        
        self.transitionContext = transitionContext
        
        fromViewController.view.isUserInteractionEnabled = false
        toViewController.view.isUserInteractionEnabled = false
        
        duration = transitionDuration(using: transitionContext)
        self.fadInSubViews = toViewController.getFadeInSubviews()

        
        fadInSubViews.forEach({ view in
            view?.alpha = 0
        })
        startFadeOutViewAnimation()
        DispatchQueue.main.async { [self] in
            startBottomBarBackgroundFadeToBackGroundColor(bottomBarView: MainTabBarViewController.shared.tabBar)
        
            if let toCollectionImageCell = toViewController.collectionView.visibleCells.first as?
                ImageViewCollectionCell {
                self.targetCornerRadius = toCollectionImageCell.mediaCornerRadius
                targetFrame = toCollectionImageCell.contentView.convert(toCollectionImageCell.imageView.frame, to: containerView)
                toCollectionImageCell.imageView.isHidden = true
                
            } else if let toCollectionPlayerLayerCell =  toViewController.collectionView.visibleCells.first as? PlayerLayerCollectionCell {
                self.targetCornerRadius = toCollectionPlayerLayerCell.mediaCornerRadius
                targetFrame = toCollectionPlayerLayerCell.contentView.convert(toCollectionPlayerLayerCell.playerLayer.frame, to: containerView)
               /* CATransaction.begin()
                CATransaction.setAnimationDuration(0)
                toCollectionPlayerLayerCell.playerLayer.isHidden = true
                CATransaction.commit()*/
            } else {
                self.transitionContext.completeTransition(true)
                return
            }

            
            self.toViewController.collectionView.isPagingEnabled = false
        self.toViewController.collectionView.scrollToItem(at: self.transitionCollectionIndexPath, at: .centeredHorizontally, animated: false)
        self.toViewController.collectionView.isPagingEnabled = true
        
            self.toViewController.collectionView.isHidden = true
             
            if let fromWholeImageCell = fromViewController.currentCollectionCell as? WholeImageViewCollectionCell {
                self.transitionImageView = fromWholeImageCell.imageView
                self.initCornerRadius = fromWholeImageCell.imageView.layer.cornerRadius
                initFrame = fromWholeImageCell.contentView.convert(fromWholeImageCell.imageView.frame, to: containerView)
                let fromViewControllerinitFrame = (fromViewController.view.superview?.convert(fromViewController.view.frame, to: containerView))!
                self.performImageViewZoomOutAnimation(initFrame: initFrame, targetFrame: targetFrame, fromViewControllerinitFrame: fromViewControllerinitFrame)
                
            } else if let fromWholePlayerLayerCell = fromViewController.currentCollectionCell as? WholePlayerLayerCollectionCell {
                self.initCornerRadius = fromWholePlayerLayerCell.playerLayer.cornerRadius
                self.transitionPlayerLayer = fromWholePlayerLayerCell.playerLayer
                initFrame = fromWholePlayerLayerCell.contentView.layer.convert(fromWholePlayerLayerCell.playerLayer.frame, to: containerView.layer)
                let fromViewControllerinitFrame = (fromViewController.view.superview?.convert(fromViewController.view.frame, to: containerView))!
                
                playerLayerSetAnimationPerform(initFrame: initFrame, targetFrame: targetFrame, fromViewControllerinitFrame: fromViewControllerinitFrame)
                
            } else {
                self.transitionContext.completeTransition(true)
                return
                
            }
        }
    }
    
    func startBottomBarBackgroundFadeToBackGroundColor(bottomBarView : UIView) {
        if let bottomBarView = bottomBarView as? UITabBar {

            UIView.transition(with: bottomBarView, duration: duration) {
            }
        }
    }
    
    func performFromBackgroundViewAnimated(fromViewControllerinitFrame: CGRect, targetFrame: CGRect) {
        
        self.fromViewController.view.subviews.forEach{ view in
            view.translatesAutoresizingMaskIntoConstraints  = true
        }
      
        let containerView = self.transitionContext.containerView
        let durationTime = self.transitionDuration(using: self.transitionContext)
        self.transitionImageView?.translatesAutoresizingMaskIntoConstraints = true
        
        self.fromViewController.view.frame = fromViewControllerinitFrame
        containerView.addSubview(self.fromViewController.view)

        UIView.animate(withDuration: durationTime, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseOut , animations: {
            self.fromViewController.view.frame = targetFrame
            self.fromViewController.view.layer.cornerRadius = self.targetCornerRadius
        })
        
    }
    
    func performImageViewZoomOutAnimation(initFrame: CGRect, targetFrame: CGRect, fromViewControllerinitFrame: CGRect)  {
       
        
        let imageView = self.transitionImageView!
        let durationTime = transitionDuration(using: transitionContext)
        self.fromViewController.view.subviews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = true
        }
        performFromBackgroundViewAnimated(fromViewControllerinitFrame: fromViewControllerinitFrame, targetFrame: targetFrame)

        if imageView.contentMode == .scaleAspectFit {
            DispatchQueue.main.asyncAfter(deadline: .now()  ) {
                UIView.transition(with: imageView, duration: 0.2 , options: .transitionCrossDissolve, animations: {
                    imageView.contentMode = .scaleAspectFill
                })
            }
        }

        UIView.animate(withDuration: durationTime, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseOut , animations: {
            imageView.frame = CGRect(x: 0, y: 0, width: targetFrame.width, height: targetFrame.height)
            imageView.layer.cornerRadius = self.targetCornerRadius
        }) { bool in
            if bool {
                self.transitionContext.completeTransition(true)
            }
        }
    }
    
    func playerLayerSetAnimationPerform(initFrame: CGRect, targetFrame: CGRect, fromViewControllerinitFrame: CGRect) {
        let playerLayer = transitionPlayerLayer!
        let duration = transitionDuration(using: transitionContext)
        performFromBackgroundViewAnimated(fromViewControllerinitFrame: fromViewControllerinitFrame, targetFrame: targetFrame)
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(Constant.wholePageCAMediaTimingFunction)
        
        CATransaction.setCompletionBlock {
            self.transitionContext.completeTransition(true)
        }
        playerLayer.frame = CGRect(x: 0, y: 0, width: targetFrame.width, height: targetFrame.height)
        playerLayer.cornerRadius = self.targetCornerRadius
        playerLayer.videoGravity = .resizeAspectFill
        
        CATransaction.commit()
        
       
    }
    
    func startFadeOutViewAnimation() {
        let fadeOutSubviews = fromViewController.getFadedSubviews()
        UIView.animate(withDuration: duration) {
            fadeOutSubviews?.forEach { view in
                view.alpha = 0
            }
        }
    }
    
    
    func fadeInViewStartAnimation() {
        let duration = transitionDuration(using: transitionContext) / 2
        
        UIView.animate(withDuration:  duration, delay: duration , animations: {
            self.fromViewController.view.backgroundColor = .clear
            self.fadInSubViews.forEach { view in
                if view is UILabel || view is UISlider {
                    return
                }
                view?.alpha = 1
            }
        })
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}

extension DismissWholePageMediaViewControllerAnimator {
    func performPlayerLayerZoomOutAnimation(initFrame: CGRect, targetFrame: CGRect) {
        let containerView = self.transitionContext.containerView
        
        let playerLayer = transitionPlayerLayer!
        let duration = transitionDuration(using: transitionContext)
        playerLayer.cornerRadius = targetCornerRadius
        containerView.addSubview(toViewController.view)
        containerView.layer.addSublayer(playerLayer)
       
        let durationTime = transitionDuration(using: transitionContext)
        containerView.layer.addSublayer(transitionPlayerLayer!)
        CATransaction.begin()
        CATransaction.setAnimationDuration(durationTime)
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        let positionYAnimation = CABasicAnimation(keyPath: "position.y")
        let positionXAnimation = CABasicAnimation(keyPath: "position.x")
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        [boundsAnimation, positionYAnimation, cornerRadiusAnimation, positionXAnimation ].forEach { animation in
           // animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.duration = durationTime
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
        }
        // 设置动画的起始值
        boundsAnimation.fromValue = NSValue(cgRect: initFrame)
        // 设置动画的目标值
        boundsAnimation.toValue = NSValue(cgRect: targetFrame)
        
        positionYAnimation.fromValue = initFrame.height / 2 + initFrame.minY
        positionYAnimation.toValue = targetFrame.height / 2 + targetFrame.minY
        
        positionXAnimation.fromValue = initFrame.midX
        positionXAnimation.toValue = UIScreen.main.bounds.width / 2
        
        cornerRadiusAnimation.fromValue = initCornerRadius
        cornerRadiusAnimation.toValue = targetCornerRadius

        playerLayer.frame = targetFrame
       /* CATransaction.setCompletionBlock {
           
            self.transitionContext.completeTransition(true)
        }*/

        
        playerLayer.add(boundsAnimation, forKey: "boundsAnimation")
        playerLayer.add(positionYAnimation, forKey: "positionYAnimation")
        playerLayer.add(positionXAnimation, forKey: "positionXAnimation")
        playerLayer.add(cornerRadiusAnimation, forKey: "cornerRadiusAnimation")
        

        CATransaction.begin()
        
        CATransaction.setAnimationDuration(duration)

        playerLayer.videoGravity = .resizeAspectFill
        CATransaction.setCompletionBlock {
            self.transitionContext.completeTransition(true)
        }



        CATransaction.commit()
    }
}












