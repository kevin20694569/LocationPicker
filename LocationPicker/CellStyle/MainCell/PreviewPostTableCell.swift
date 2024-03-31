import UIKit
class PreviewPostTableCell : MainPostTableCell {
    
    override var canPostReaction: Bool {
        return false
    }
    
    override var shareImageView: UIImageView! {didSet {
        shareImageView.isUserInteractionEnabled = false
    }}
    override var userImageView: UIImageView! { didSet {
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius  = 8
        userImageView.isUserInteractionEnabled = false
    }}
    
    override var emojiReactionsStackView: UIStackView? { didSet {
        emojiReactionsStackView?.isUserInteractionEnabled = false
    }}
    
    

    
    
    
    
}
