import UIKit

class PlaceFindCell: UITableViewCell {
    
    @IBOutlet var NameLabel : UILabel!
    
    @IBOutlet var AddressLabel : UILabel!

    override func awakeFromNib() {

    }
    
    func configure(Location : Restaurant) {
        self.NameLabel.text = Location.name
        self.AddressLabel.text = Location.Address
    }

}
