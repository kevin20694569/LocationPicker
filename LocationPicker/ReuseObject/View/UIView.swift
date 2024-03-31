import UIKit
class RoundedView : UIView {
    
    init(frame : CGRect , backgroundColor: UIColor, tintColor : UIColor, contentInsets : NSDirectionalEdgeInsets? = .init(top: 10, leading: 30, bottom: 10, trailing: 30), cornerRadius : CGFloat  ) {
        super.init(frame: frame)
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
}
