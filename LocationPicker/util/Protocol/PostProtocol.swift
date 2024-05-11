

import UIKit

protocol PostTableCell : UITableViewCell {
    var mediaTableCellDelegate : MediaTableCellDelegate? { get  set }
    func configureData(post : Post)
}

protocol PostsTableForGridPostCellViewDelegate : GridPostCollectionViewAnimatorDelegate {
    var posts : [Post]! { get set }
    var tempModifiedPostsWithMediaCurrentIndex : [String: (Post, Int)]! { get set }
    func deletePostCell(post: Post)
    
    
}

protocol StandardPostTableCellProtocol : PostTableCell {
    var collectionViewHeight : CGFloat! { get set }
    var standardPostCellDelegate : StandardPostCellDelegate? { get set }
    var userImageView : UIImageView! { get }
    var userNameLabel : UILabel! { get }
    var settingButton : ZoomAnimatedButton! { get }
    func refreshData() async
    

    


}

protocol StandardPostCellDelegate : MediaTableViewCellDelegate {
    func cellRowHeightSizeFit()
    func scrollToUpdateIndexPath(diffY : CGFloat)
    var tableView  : UITableView! { get }
    func gestureStatusToggle(isTopViewController  : Bool)
    
    func showEditPostViewController(post : Post)
    
    func reloadPostCell(post: Post) async
    
    func presentEditPostOptionViewController(post : Post)
        
    
}



