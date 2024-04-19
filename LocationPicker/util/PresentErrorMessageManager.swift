import UIKit

class PresentErrorMessageManager : NSObject {
    
    static let shared : PresentErrorMessageManager = PresentErrorMessageManager()
    
    
    var mainBackgroundView : UIVisualEffectView! = UIVisualEffectView(frame: .zero, style: .userInterfaceStyle)
    
    var messageLabel : UILabel! = UILabel()
    
    let backgroundViewMinX : CGFloat = 20
    
    let labelHorOffset : CGFloat = 12
    
    var warnningImageViewHorOffset : CGFloat = 16
    
    let errorViewBottomOffset : CGFloat = 12
    
    var isShowingErrorView : Bool = false
    
    
    var startY : CGFloat?
    
    var startTime : Date?
    
    var yThreshold : CGFloat! = 0
    
    var warningImageView : UIImageView! = UIImageView()
    
    var closeErrorViewTimer : DispatchSourceTimer?
    
    override init() {
        super.init()
        viewSetup()
        labelSetup()
        gestureSetup()
        imageViewSetup()
        viewLayout()
        
    }
    
    func startCloseTimer() {
        closeErrorViewTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        closeErrorViewTimer?.schedule(deadline: .now() + 2)
        closeErrorViewTimer?.setEventHandler() { [self] in
            Task {
              await self.warningMoveOut()
            }

        }
        closeErrorViewTimer?.resume()
    }
    
    func cacelCloseTimer() {
        closeErrorViewTimer?.cancel()
        closeErrorViewTimer = nil
    }
    
    func viewLayout() {
      
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(mainBackgroundView)

        mainBackgroundView.translatesAutoresizingMaskIntoConstraints = true
        mainBackgroundView.frame = CGRect(x: backgroundViewMinX, y: keyWindow.bounds.height, width: keyWindow.bounds.width - backgroundViewMinX * 2, height: keyWindow.bounds.height * 0.06)
        mainBackgroundView.contentView.addSubview(warningImageView)
        warningImageView.translatesAutoresizingMaskIntoConstraints = false
        mainBackgroundView.contentView.addSubview(messageLabel)
        yThreshold = keyWindow.bounds.height -  (mainBackgroundView.bounds.height + Constant.bottomBarViewHeight + errorViewBottomOffset)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            warningImageView.leadingAnchor.constraint(equalTo: mainBackgroundView.contentView.leadingAnchor, constant: warnningImageViewHorOffset),
            warningImageView.centerYAnchor.constraint(equalTo: mainBackgroundView.contentView.centerYAnchor),
            warningImageView.widthAnchor.constraint(equalTo: warningImageView.heightAnchor, multiplier: 1),
            messageLabel.leadingAnchor.constraint(equalTo: warningImageView.trailingAnchor, constant: labelHorOffset),
            messageLabel.trailingAnchor.constraint(equalTo: mainBackgroundView.contentView.trailingAnchor, constant: -labelHorOffset),
            messageLabel.centerYAnchor.constraint(equalTo: mainBackgroundView.contentView.centerYAnchor)
        ])
        
    }
    
    func viewSetup() {
        mainBackgroundView.clipsToBounds = true
        mainBackgroundView.layer.cornerRadius = 16
        mainBackgroundView.backgroundColor = .clear
        
        
    }
    
    func labelSetup() {
        messageLabel.textColor = .label
        messageLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .regular)
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.numberOfLines = 1
        messageLabel.text = "警告訊息"
    }
    
    func imageViewSetup() {
        warningImageView.image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title1, weight: .medium)))
        warningImageView.tintColor = .systemRed
        warningImageView.contentMode = .scaleAspectFit
    }
    
    func gestureSetup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture ( _ :)))
        self.mainBackgroundView.addGestureRecognizer(panGesture)
        mainBackgroundView.isUserInteractionEnabled = true
    }
    
    @objc func handleGesture( _ recognizer : UIPanGestureRecognizer) {
        guard let view = mainBackgroundView else {
            return
        }

        let translation = recognizer.translation(in: view)
        switch recognizer.state {
        case .began :
            self.cacelCloseTimer()
        case .changed :
            let deltaY = translation.y
            if startY == nil {
                startY = view.frame.origin.y
            }
            if startTime == nil {
                startTime = Date()
            }
            if ( view.frame.origin.y + deltaY > self.yThreshold) {
                view.frame.origin.y += deltaY
            }
            
        case .ended :
            if view.frame.origin.y > yThreshold + view.bounds.height / 2 {
                Task {
                    self.cacelCloseTimer()
                    await self.warningMoveOut()

                }
            } else {
                Task {
                    await self.warningMoveIn()
                    self.cacelCloseTimer()
                    self.startCloseTimer()

                }
            }
        default:
            break
        }
        recognizer.setTranslation(.zero, in: view)
    }
    
    public func updateErrorMessageText(text : String) {
        self.cacelCloseTimer()
        self.startCloseTimer()
        self.messageLabel.text = text
    }
    
    @MainActor
    func warningMoveIn() {
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.mainBackgroundView.frame.origin.y = self.yThreshold
        }) { bool in
            self.isShowingErrorView = true
            self.startCloseTimer()
            
        }
        
    }
    
    
    @MainActor
    func warningMoveOut() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, animations: {  [weak self] in
            guard let self = self else {
                return
            }
            self.mainBackgroundView.frame.origin.y = UIApplication.shared.keyWindow?.frame.height ?? UIScreen.main.bounds.height
        }) { [self] bool in

            cacelCloseTimer()
            self.isShowingErrorView = false
        }
        
    }
    
}
