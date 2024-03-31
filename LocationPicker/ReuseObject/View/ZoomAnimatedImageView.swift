
import UIKit

/*class ZoomAnimatedImageView : UIImageView {
    var scaleX : CGFloat! = 0.90
    var scaleY : CGFloat! = 0.90
    var scaleTargets : [UIView]? = []
    var recoverDutation : TimeInterval! = 0.1
    var tappedDuration : TimeInterval! = 0.1
    
    var animatedEnable : Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        scaleTargets?.append(self)

        let zoomOutGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped( _ :)))
        self.addGestureRecognizer(zoomOutGesture)
        let event = UIControl.Event.self
        [event.touchCancel.self, event.touchUpInside, event.touchDragExit, event.touchDragOutside].forEach() {
            
            let recoverGesture = UITapGestureRecognizer(target: self, action: #selector(recoverButton( _ :)))
        }
        
        UIControl.Event.touchCancel
        
        addTarget(<#T##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchCancel)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchUpInside)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragExit)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragOutside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        scaleTargets?.append(self)
        self.addTarget(self, action: #selector(buttonTapped ( _ : )), for: .touchDown)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchCancel)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchUpInside)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragExit)
        self.addTarget(self, action: #selector(recoverButton ( _ : )), for: .touchDragOutside)
    }
    
    @objc func recoverButton( _ sender : UIImageView) {
        guard animatedEnable else {
            return
        }
        UIView.animate(withDuration: recoverDutation) {
            self.scaleTargets?.forEach({ view in
                view.transform = .identity
            })
        }
    }

    
    @objc func buttonTapped(_ sender: UIImageView) {
        guard animatedEnable else {
            return
        }
        UIView.animate(withDuration: tappedDuration) {
            self.scaleTargets?.forEach({ view in
                view.transform = CGAffineTransform(scaleX: self.scaleX, y: self.scaleY)
            })
        }
    }
}*/
