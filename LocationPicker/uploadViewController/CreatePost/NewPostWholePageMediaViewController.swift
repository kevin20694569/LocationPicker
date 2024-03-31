import UIKit

class NewPostWholePageMediaViewController: WholePageMediaViewController {
    
    override var canPostReaction: Bool! {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.isUserInteractionEnabled = false
        self.userImageView.isHidden = true
        self.locationimageView.isUserInteractionEnabled = false
        self.locationimageView.isHidden = true
    }

    

}
