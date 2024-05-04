

import UIKit


protocol StandardEmojiReactionObject : EmojiReactionObject {
    var extendedEmojiBlurView : UIVisualEffectView? { get }
    func startEmojiExtendAnimation()
    func emojiButtonTapped( _ button : UIButton)
}

protocol EmojiReactionObject : AnyObject {
    var loveButton : ZoomAnimatedButton!  {get }
    var vomitButton : ZoomAnimatedButton! {get }
    var angryButton : ZoomAnimatedButton! {get }
    var sadButton: ZoomAnimatedButton! { get }
    var surpriseButton : ZoomAnimatedButton! {get }
    var emojiTargetButtons : [ZoomAnimatedButton]! { get }
    var currentEmojiTag : Int? { get }
    func emojiTargetTapped(_ button : UIButton)
    func startReactionTargetAnimation(targetTag : Int?)
}
