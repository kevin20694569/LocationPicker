import UIKit
class TitleSlideView : UIView {
    var slider : UIView! = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout() {
        slider.backgroundColor = .secondaryLabelColor
        self.slider.clipsToBounds = true
        self.slider.layer.cornerRadius = 2
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        self.addSubview(slider)
        self.backgroundColor = .secondaryBackgroundColor
        let bounds = UIScreen.main.bounds
        NSLayoutConstraint.activate([
            slider.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            slider.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            slider.heightAnchor.constraint(equalToConstant: bounds.height / 170),
            slider.widthAnchor.constraint(equalToConstant: bounds.width / 5),
        ])
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layout()
    }
}
