import UIKit

class NewPostWholePageMediaViewController: WholePageMediaViewController {
    
    override var canPostReaction: Bool! {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.isHidden = true
        self.locationimageView.isHidden = true
        self.heartButton.isHidden = true
        self.emojiButton.isHidden = true
        self.shareButton.isHidden = true
        self.collectButton.isHidden = true
        
    }

    override func initLayout() {

        super.initLayout()
        for con in self.view.constraints {
            if con.identifier ==  "soundImageBottomAnchor" {
                self.view.removeConstraint(con)
                break
            }
        }
        NSLayoutConstraint.activate([
            soundImageView.centerYAnchor.constraint(equalTo: resizeToggleButton.centerYAnchor   )
        ])
        
    }
    

}
