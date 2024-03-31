import UIKit
import MapKit

class RestaurantDetailCollectionViewDetailGridCell : CollectionCollectionViewCell, RestaurantProfileCollectionCell {

    
    weak var delegate : RestaurantDetailCollectionViewDetailGridCellDelegate?
    

    var restaurant : Restaurant!
    let offset : CGFloat = 4
    
    let openingTimeIndexPath : IndexPath! = IndexPath(row: 0, section: 1)
    
    var openingTimeGridCell : RestaurantDetailOpeningTimesCell? {
        return self.collectionView.cellForItem(at: openingTimeIndexPath) as? RestaurantDetailOpeningTimesCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantProfileMapCell", for: indexPath) as! RestaurantProfileMapCell
            cell.configure(restaurant: restaurant)
            return cell
        } else {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantDetailOpeningTimesCell", for: indexPath) as! RestaurantDetailOpeningTimesCell
            cell.configure(restaurant: restaurant)
            return cell
        }
    }


    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.contentInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
            collectionView.collectionViewLayout = flow
        }
        collectionView.isScrollEnabled = false
    }
    
    
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func registerCells() {
        super.registerCells()
        self.collectionView.register(RestaurantProfileMapCell.self, forCellWithReuseIdentifier: "RestaurantProfileMapCell")
        let RestaurantDetailOpeningTimesCell = UINib(nibName: "RestaurantDetailOpeningTimesCell", bundle: nil)
        self.collectionView.register(RestaurantDetailOpeningTimesCell, forCellWithReuseIdentifier: "RestaurantDetailOpeningTimesCell")
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 1
    }
    
    func configure(restaurant: Restaurant) {
        self.restaurant = restaurant
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        
        if section == 0 {
            let height = bounds.height - offset * 3
            return CGSize(width: height, height: height)
        } else {
            let height = (bounds.height - offset * 3) / 2
            return CGSize(width: height, height: height)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: offset)
        }
        return UIEdgeInsets(top: offset , left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 1 {
            return offset
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 1 {
            return offset
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? RestaurantDetailOpeningTimesCell {
            
            delegate?.presentOpeningDaysTableView( cell: cell)
            cellTapped(cell)
        }
    }
    
    let cellDidSelectDuration : TimeInterval! = 0.08
    
    
    @objc func cellRecover( _ sender : UIView) {
        UIView.animate(withDuration: cellDidSelectDuration) {
            sender.transform = .identity
        }
    }
    
    
    @objc func cellTapped(_ sender: UIView) {
        if sender == self.openingTimeGridCell {
            UIView.animate(withDuration: cellDidSelectDuration, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { bool in
                self.cellRecover(sender)
            }
        }
    }
    
    
}


