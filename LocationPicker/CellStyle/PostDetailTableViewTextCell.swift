import UIKit

class PostDetailTableViewTextCell: PostDetailTableViewCell, UITextViewDelegate {
    
    @IBOutlet var TextView : UITextView? {didSet {
        TextView?.delegate  = self
    }}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.contentView.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
