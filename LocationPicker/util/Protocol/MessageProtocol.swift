
import UIKit

protocol MessageTableCellDelegate : AnyObject {
    func showUserProfile(user_id : Int)
    func showWholePageMediaViewController(cell : UITableViewCell)
}

protocol MessageTableCellProtocol : UITableViewCell {
    func configure(message : Message)
}

protocol MessageTextViewCell : MessageTableCellProtocol {
    var messageTextView : UITextView! { get }
    func layoutMessageTextView()
}

protocol MessageSharedPostCell : MessageTableCellProtocol {
    var postImageView : UIImageView! { get }
    var restaurantNameLabel : UILabel! { get }
    var showPostGesture : UITapGestureRecognizer! { get }
        

}
