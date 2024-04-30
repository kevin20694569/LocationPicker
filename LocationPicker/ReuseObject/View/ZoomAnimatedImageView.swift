
import UIKit

class ZoomAnimatedButton : UIButton {
    var scaleX : CGFloat! = 0.90
    var scaleY : CGFloat! = 0.90
    var scaleTargets : [UIView]? = []
    var recoverDutation : TimeInterval! = 0.1
    var tappedDuration : TimeInterval! = 0.1
    
    var animatedEnable : Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scaleTargets?.append(self)
        self.addTarget(self, action: #selector(buttonTapped ( _ : )), for: .touchDown)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchCancel)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchUpInside)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragExit)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragOutside)
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleTargets?.append(self)
        self.addTarget(self, action: #selector(buttonTapped ( _ : )), for: .touchDown)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchCancel)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchUpInside)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragExit)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragOutside)
    }
    
    
    @objc func recoverButton( _ sender : UIButton) {
        guard animatedEnable else {
            return
        }
        UIView.animate(withDuration: recoverDutation) {
            self.scaleTargets?.forEach({ view in
                view.transform = .identity
            })
        }
    }


    @objc func buttonTapped(_ sender: UIButton) {
        guard animatedEnable else {
            return
        }
        UIView.animate(withDuration: tappedDuration) {
            self.scaleTargets?.forEach({ view in
                
                view.transform = CGAffineTransform(scaleX: self.scaleX, y: self.scaleY)
            })
        }
    }
}
