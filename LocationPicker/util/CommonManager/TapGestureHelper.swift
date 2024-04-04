import UIKit
class TapGestureHelper {
    
    static let shared = TapGestureHelper()
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    func shouldAddTapGestureInWindow(window: UIWindow) {
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyBoard))
            tapGestureRecognizer?.cancelsTouchesInView = false
        }
        
        // 在 window 上增加手勢
        window.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc func dismissKeyBoard(tap: UITapGestureRecognizer) {
        let view = tap.view
        view?.endEditing(true)
        //view?.removeGestureRecognizer(tapGestureRecognizer!)
    }
}
