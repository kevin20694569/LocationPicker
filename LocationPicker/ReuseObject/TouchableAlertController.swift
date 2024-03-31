import UIKit
class TouchableAlertController: UIAlertController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // 添加一个手势识别器来捕获空白区域的触摸事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.presentationController?.containerView?.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        self.presentationController?.containerView?.isUserInteractionEnabled = true
        self.presentationController?.containerView?.subviews.forEach() {
            $0.isUserInteractionEnabled = true
        }
    }

    
    // 处理触摸事件，如果触摸发生在 alertController 的外部，则执行 dismiss 操作
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: self.presentationController?.containerView)
        if !view.frame.contains(touchLocation) {
            dismiss(animated: true, completion: nil)
        }
    }
}
