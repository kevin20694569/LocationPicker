import UIKit

class NewPostWholePageMediaViewController: WholePageMediaViewController {
    
    override var canPostReaction: Bool! {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.isHidden = true
        self.locationimageView.isHidden = true
        [heartButton, emojiButton, shareButton, collectButton].forEach() {
            $0?.layer.opacity = 0
            $0?.isUserInteractionEnabled = false
        }

        //rightStackView.backgroundColor = .red
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
            rightStackView.heightAnchor.constraint(greaterThanOrEqualTo: rightStackView.widthAnchor, multiplier: 1),
            soundImageView.centerYAnchor.constraint(equalTo: resizeToggleButton.centerYAnchor   )
        ])
        self.view.layoutIfNeeded()
        
    }
    

}
