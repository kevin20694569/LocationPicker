import UIKit

class ExtendedEmojiView: UIView {
    var emojiLabels : [UILabel]! {
        return [loveLabel, vomitLabel, angryLabel, sadLabel, surpriseLabel]
    }
    var loveLabel : UILabel! = UILabel()
    var vomitLabel : UILabel! = UILabel()
    var angryLabel : UILabel! = UILabel()
    var sadLabel : UILabel! = UILabel()
    var surpriseLabel : UILabel! = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        

        let blurView = UIVisualEffectView(frame: bounds)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
        insertSubview(blurView, at: 0) // 将模糊视图放在最底层
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo:  self.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        for (i, label) in emojiLabels.enumerated() {
            label.tag = i
            label.translatesAutoresizingMaskIntoConstraints = true
            label.frame = frame
            
            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
            self.addSubview(label)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
