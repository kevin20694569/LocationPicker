
import UIKit

protocol MessageTableCellDelegate : UIViewController {
    func showUserProfile(user_id : Int , user: User?)
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
    func layoutSharePostSubviews()
        

}

protocol MessageSharedUserCell : MessageTableCellProtocol {
    var sharedUserImageView : UIImageView! { get }
    var userNameLabel : UILabel! { get }
    var showUserProfileGesture : UITapGestureRecognizer! { get }
    func layoutSharedUserSubviews()
}

protocol MessageShareRestaurantCell : MessageTableCellProtocol {
    
    var showRestaurantDetailGesture: UITapGestureRecognizer! { get }
    
    var sharedRestaurantImageView: UIImageView! { get }
    
    var restaurantNameLabel: UILabel! { get }
    
    var sharedRestaurant : Restaurant! { get }
}
