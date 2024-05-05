import UIKit

class PreviewWholePageMediaViewController : WholePageMediaViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.isUserInteractionEnabled = false
        self.locationimageView.isUserInteractionEnabled = false
        self.heartButton.isUserInteractionEnabled = false
        self.emojiButton.isUserInteractionEnabled = false
        self.collectButton.isUserInteractionEnabled = false
    }
}

