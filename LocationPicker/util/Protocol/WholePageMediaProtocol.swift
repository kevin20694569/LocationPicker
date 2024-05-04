import UIKit

protocol PanWholePageViewControllerDelegate : UIViewController {
    func gestureStatusToggle(isTopViewController: Bool)
}


protocol PostDetailSheetViewControllerDelegate : AnyObject {
    func recoverInteraction()
    func setHeartImage()
    func presentShareViewController(_ gesture : UITapGestureRecognizer)
}
