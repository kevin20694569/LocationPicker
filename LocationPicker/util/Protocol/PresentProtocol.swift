import UIKit

protocol PresentDelegate : UIViewController {
    
}


protocol LimitContainerViewHeightPresentedView : MaxFrameController {
    
    
    
}

protocol LimitSelfFramePresentedView  : MaxFrameController {
    var canTouchOutsideToDismiss : Bool! { get }
}

protocol PresentedSheetViewControllerProtocol : UIViewController, MaxFrameController {
    
}
