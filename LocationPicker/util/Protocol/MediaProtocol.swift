
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
    var cornerRadiusfloat : CGFloat! { get }
}

protocol MediaTableCellDelegate : MediaCellDelegate, UIViewController {
    
    func presentWholePageMediaViewController(post: Post?)
    func segueToProFile(user_id : Int,  user_name : String, user_image : UIImage?)
    func changeCurrentEmoji(emojiTag : Int?)
}

protocol MediaTableViewCellDelegate : MediaTableCellDelegate  {
    var tableView : UITableView! { get }
    var collectionView : UICollectionView! { get }
}

