import UIKit


protocol WholePageMediaViewControllerDelegate : NSObject {
    func changeCurrentEmoji(emojiTag : Int?)
    var tableView : UITableView! { get }
}
