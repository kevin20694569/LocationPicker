import UIKit

class PostDetailTableViewCell: UITableViewCell {
    
    var activeTextField : UITextField?
    
    var activeTextView : UITextView?
    
    @IBOutlet weak var titleLabel : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

/*extension PostDetailTableViewCell {
    
  NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown),
                                         name: UIResponder.keyboardWillShowNotification,
                                         object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden),
                                         name: UIResponder.keyboardWillHideNotification,
                                         object: nil)
    
    @objc func keyboardShown(notification: Notification) {
        let info: NSDictionary = notification.userInfo! as NSDictionary
        //取得鍵盤尺寸
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        //鍵盤頂部 Y軸的位置
        let keyboardY = self.contentView.frame.height - keyboardSize.height
        //編輯框底部 Y軸的位置
        let offsetY: CGFloat = 20
        
        if let activeTextField = activeTextField {
            let editingTextFieldY = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
            let targetY = editingTextFieldY - keyboardY
            if self.view.frame.minY >= 0 {
                if targetY > 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame = CGRect(x: 0, y:  -targetY - offsetY, width: self.view.bounds.width, height: self.view.bounds.height)
                    })
                }
            }
        }
        if let activeTextView = activeTextView {
            let editingTextViewY = activeTextView.convert(activeTextView.bounds, to: self.view).maxY
            let targetY = editingTextViewY - keyboardY
            if self.view.frame.minY >= 0 {
                if targetY > 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame = CGRect(x: 0, y:  -targetY - offsetY, width: self.view.bounds.width, height: self.view.bounds.height)
                    })
                }
            }
        }
    }
    
    
    
    @objc func keyboardHidden(notification: Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        })
    }
}*/


