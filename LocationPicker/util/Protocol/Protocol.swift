import UIKit

protocol PhotoPostViewControllerDelegate : AnyObject  {
    func changeMediaTitle(title: String)
    func selectPHPickerImage()
}


protocol FriendRequestsCellDelegate : AnyObject {
    func segueToUserProfileView(userRequst: UserFriendRequest)
}

protocol PlaceFindDelegate {
    func changePlaceModel(model : Restaurant)
}
protocol ExtendLabelHeightTableCellDelegate : AnyObject {
    func cellRowHeightSizeFit()
}
protocol MaxFrameController : AnyObject {
    var maxHeight : CGFloat! { get set }
    var maxWidth : CGFloat! { get set }
}

protocol ShowViewControllerDelegate : UIViewController {
    var presentForTabBarLessView : Bool! { get }
}

protocol ShowMessageControllerProtocol : ShowViewControllerDelegate {
    func showMessageViewController(user_ids : [Int])
}


protocol ProfileMainCellDelegate : ShowMessageControllerProtocol {

}

