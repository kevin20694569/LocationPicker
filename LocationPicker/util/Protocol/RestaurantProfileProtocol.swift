
import UIKit

protocol RestaurantProfileCollectionCell : UICollectionViewCell {
    func configure(restaurant : Restaurant)
}

protocol RestaurantDetailCollectionViewDetailGridCellDelegate : NSObject {
    func  presentOpeningDaysTableView( cell: UICollectionViewCell)
}
