
import UIKit

protocol PresentedSheetViewControllerProtocol : UIViewController {
    var titleSlideView : UIView! { get }
}

protocol LimitContainerViewHeightPresentedView : MaxFrameController, PresentedSheetViewControllerProtocol {
}

protocol LimitSelfFramePresentedView : MaxFrameController, PresentedSheetViewControllerProtocol {
    var canTouchOutsideToDismiss : Bool! { get set }
}
