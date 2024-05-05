import UIKit

protocol PanWholePageViewControllerDelegate : UIViewController {
    func gestureStatusToggle(isTopViewController: Bool)
}


protocol PostDetailSheetViewControllerDelegate : AnyObject {
    func recoverInteraction()
    func updateHeartButtonStatus()
    func presentShareViewController(_ gesture : UITapGestureRecognizer)
}
