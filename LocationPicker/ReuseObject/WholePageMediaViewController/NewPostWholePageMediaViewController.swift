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

    override func layout() {
        super.layout()
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
