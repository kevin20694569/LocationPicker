import UIKit
class TapGestureHelper {
    
    static let shared = TapGestureHelper()
    lazy var tapGestureRecognizer: UITapGestureRecognizer! = {
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyBoard))
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }()
    
    func shouldAddTapGestureInWindow(view: UIView) {
        view.isUserInteractionEnabled = true
        
        // 在 window 上增加手勢
        view.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc func dismissKeyBoard(tap: UITapGestureRecognizer) {
        let view = tap.view
        view?.endEditing(true)
    }
}
