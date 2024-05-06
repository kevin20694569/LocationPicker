import UIKit

class PresentedSheetViewController : UIViewController, PresentedSheetViewControllerProtocol {
    
    var maxHeight: CGFloat!
    
    var maxWidth : CGFloat!
    
    
    
    var titleSlideView: TitleSlideView! = TitleSlideView()
    var originFrame : CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        setGesture()
    }
    
    func viewSetup() {
        self.view.backgroundColor = .secondaryBackgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.originFrame = self.view.frame
    }
    
    func setGesture() {
        let panGestureForSliderViewGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture ( _ :) ))
        self.titleSlideView.addGestureRecognizer(panGestureForSliderViewGesture)
        self.titleSlideView.isUserInteractionEnabled = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        
        //this is the KEY of the fix
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyBoard(tap: UITapGestureRecognizer) {
        let view = tap.view
        view?.endEditing(true)
    }
    
    func initLayout() {
        self.view.addSubview(titleSlideView)
        titleSlideView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleSlideView.heightAnchor.constraint(equalToConstant: Constant.titleSliderViewHeight),
            titleSlideView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            titleSlideView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleSlideView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    
    @objc func handlePanGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        let offset = gestureRecognizer.velocity(in: self.view)
        switch gestureRecognizer.state {
        case .changed :
            self.view.frame.origin.y  = max(originFrame.minY, self.view.frame.origin.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended  :
            if offset.y > 0 {
                self.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.1) { [self] in
                    self.view.frame = CGRect(x: originFrame.minX, y: originFrame.minY, width: self.view.bounds.width, height: originFrame.height)
                }
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        default:
            break
        }
    }
}
