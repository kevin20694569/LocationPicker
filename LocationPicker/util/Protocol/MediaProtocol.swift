
import UIKit

protocol MediaDelegate : AnyObject {
    func playCurrentMedia()
    func pauseCurrentMedia()
}


protocol MediaCellDelegate : MediaDelegate {
    var currentMediaIndexPath : IndexPath! { get }
    func updateVisibleCellsMuteStatus()
    func updateCellPageControll(currentCollectionIndexPath: IndexPath)
}

protocol MediaCollectionCellDelegate : MediaCellDelegate {

}

protocol MediaCollectionCell : UICollectionViewCell {
    func reload(media : Media?)
    var mediaCornerRadius : CGFloat! { get }
}

protocol MediaTableCellDelegate : MediaCellDelegate, ShowViewControllerDelegate {
    func presentWholePageMediaViewController(post: Post?)
    func showUserProfile(user : User)
}

protocol MediaTableViewCellDelegate : MediaTableCellDelegate  {
    var tableView : UITableView! { get }
    var collectionView : UICollectionView! { get }
    func deletePostCell(post : Post)
}

