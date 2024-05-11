import UIKit

protocol PhotoPostViewControllerDelegate : AnyObject  {
    func changeMediaTitle(title: String)
    func selectPHPickerImage()
}


protocol FriendRequestsCellDelegate : AnyObject {
    func showUserProfileViewController(userRequst: UserFriendRequest)
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
    func showMessageViewController(user_ids : [String])
}


protocol ProfileMainCellDelegate : ShowMessageControllerProtocol {
    func showEditUserProfileViewController(userProfile : UserProfile)
    
    func showShareUserController(user: User)
    
    func showUserProfileOptionViewController(profile : UserProfile)

}

protocol EditUserProfileCellDelegate : ShowViewControllerDelegate {
    func saveButtonEnableToggle(_ enable : Bool)
}

protocol EditUserProfileViewControllerDelegate : MainUserProfileViewController {
    
}


protocol UploadPostDetailGradeCellDelegate : UIViewController {
    func updateReleaseButtonStatus()
}


