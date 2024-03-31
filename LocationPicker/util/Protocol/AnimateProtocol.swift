
import UIKit
protocol BackToReloadMediaAnimator : UIViewController, AnyObject {
    var enterCollectionIndexPath : IndexPath! { get }
    
    func reloadCollectionCell(backCollectionIndexPath : IndexPath)
    var collectionView : UICollectionView! { get }
}

protocol GridPostCollectionViewAnimatorDelegate : BackToReloadMediaAnimator  {
    var enterCollectionCell : UICollectionViewCell? { get }
    func hiddenWillBackCollectionCell(hiddenIndexPath : IndexPath)
    func changeMediaCollectionCellImage(needChangedCollectionIndexPath : IndexPath, currentMediaIndexPath : IndexPath?)
}

protocol MediaCollectionViewAnimatorDelegate : BackToReloadMediaAnimator {
    var currentMediaIndexPath : IndexPath! { get set }
    var currentCollectionCell : UICollectionViewCell? { get }
    
    func getFadeInSubviews() -> [UIView?]
    
    func getFadedSubviews() -> [UIView]!
    func updateCellPageControll(currentCollectionIndexPath: IndexPath)
}

protocol WholePageCollectionViewAnimatorDelegate : MediaCollectionViewAnimatorDelegate {
    var blurView : UIVisualEffectView! { get  }
    var bottomBarView : UIView! { get }
    func getPlayerSubviews() -> [UIView]
}

protocol CollectionViewInTableViewMediaAnimatorDelegate : MediaCollectionViewAnimatorDelegate {
    var tableView : UITableView! { get }
    var currentTableViewIndexPath : IndexPath! { get }
}


