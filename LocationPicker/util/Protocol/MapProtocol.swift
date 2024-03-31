
import UIKit
protocol MapGridPostDelegate : UIViewController {
    func removeRoute()
    var cardViewStatus : MapCardViewStatus! { get }
}
