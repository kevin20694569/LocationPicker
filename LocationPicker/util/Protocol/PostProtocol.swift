

import UIKit

protocol PostTableCell : UITableViewCell {
    var mediaTableCellDelegate : MediaTableCellDelegate? { get  set }
    func configureData(post : Post)
}

protocol PostsTableForGridPostCellViewDelegate : GridPostCollectionViewAnimatorDelegate {
    var tempModifiedPostsWithMediaCurrentIndex : [String: Post]! { get set }
}

protocol StandardPostTableCellProtocol : PostTableCell {
    var collectionViewHeight : CGFloat! { get set }
    var standardPostCellDelegate : StandardPostCellDelegate! { get set }
    var userImageView : UIImageView! { get }
    var userNameLabel : UILabel! { get }

}

protocol StandardPostCellDelegate : MediaTableViewCellDelegate {
    func cellRowHeightSizeFit()
    func scrollToUpdateIndexPath(diffY : CGFloat)
    var tableView  : UITableView! { get }
    func gestureStatusToggle(isTopViewController  : Bool)
}
