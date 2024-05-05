import UIKit
import MapKit
import CoreLocation

class RestaurantProfileNameCell : UICollectionViewCell, RestaurantProfileCollectionCell {
    
    let starImageFont = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)
    let dollarImageFont = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .thin)
    
    @IBOutlet var mainView : UIView!
    
    @IBOutlet var starStackView : UIStackView!
    
    @IBOutlet var gradeLabel : UILabel!
    
    @IBOutlet var restaurantSecondLabel : UILabel!
    @IBOutlet var priceLabel : UILabel!
    
    @IBOutlet var postsCountLabel : UILabel!
    
    @IBOutlet var dollarSignStackView : UIStackView!
    
    @IBOutlet var dollarStatusLabel : UILabel! { didSet {
        dollarStatusLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .regular)
    }}

    @IBOutlet var restaurantImageView : UIImageView! { didSet {
        restaurantImageView.backgroundColor = .secondaryBackgroundColor
        restaurantImageView.clipsToBounds = true
        restaurantImageView.layer.cornerRadius = 16
        restaurantImageView.contentMode = .scaleAspectFill
    }}
    @IBOutlet var addressLabel : UILabel! { didSet {
        addressLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .regular)
        addressLabel.adjustsFontSizeToFitWidth = true
    }}
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 20
        mainView.backgroundColor = .secondaryBackgroundColor
        dollarSignStackView.arrangedSubviews.forEach() {
            if let imageView = $0 as? UIImageView {
                imageView.tintColor = .secondaryLabelColor
                imageView.image = UIImage(systemName: "dollarsign.circle", withConfiguration: UIImage.SymbolConfiguration(font: dollarImageFont))?.withTintColor(.secondaryLabelColor, renderingMode: .alwaysOriginal)
            }
        }
    }

    func configure(restaurant : Restaurant) {
        if let image = restaurant.image {
            self.restaurantImageView.image = image
        } else if let restaurantImageURL = restaurant.imageURL {
            Task {
                let image = try? await restaurantImageURL.getImageFromURL()
                self.restaurantImageView.image = image
                restaurant.image = image
            }
        }
        self.addressLabel.text = restaurant.Address
    
        if let grade = restaurant.average_grade {
            self.gradeLabel.text = String(format: "%.1f", grade)
            fillStar(grade: grade)
        }
        configureDollarSign(level: restaurant.price_level)
    
        if let takeout = restaurant.takeout {
            restaurantSecondLabel.text = takeout ? "可外帶" : "不可外帶"
        }
        if let reservable = restaurant.reservable {
            let reservebleString = reservable ? "可訂位" : "不可訂位"
            restaurantSecondLabel.text = restaurantSecondLabel.text != nil ? (restaurantSecondLabel.text! + "，\(reservebleString)") : ("\(reservebleString)")
        }
        if let posts_count = restaurant.posts_count {
            self.postsCountLabel.text = String(posts_count)
        }
        
    }
    
    func configureDollarSign(level : Int?) {

        guard let level = level else {
            for index in 1...4 {
                let dollarImageView = self.dollarSignStackView.arrangedSubviews[index] as! UIImageView
                dollarImageView.isHidden = true
            }
            dollarStatusLabel.isHidden = false
            return
        }
        dollarStatusLabel.isHidden = true
        for index in 0...level {
            let dollarImageView = self.dollarSignStackView.arrangedSubviews[index] as! UIImageView
            dollarImageView.isHidden = false
            dollarImageView.image = UIImage(systemName: "dollarsign.circle.fill", withConfiguration: UIImage.SymbolConfiguration(font: dollarImageFont))?.withTintColor(.tintOrange, renderingMode: .alwaysOriginal)
        }
        
        for index in level + 1 ... 4 {
            let dollarImageView = self.dollarSignStackView.arrangedSubviews[index] as! UIImageView
            dollarImageView.isHidden = false
        }
        
        
        
    }
    
    
    
    func fillStar(grade : Double) {

        let integerPart = Int(grade)
        let decimalPart = grade - Double(integerPart)
        if integerPart > 0 {
            for index in 0...integerPart - 1 {
                let starImageView = self.starStackView.arrangedSubviews[index] as! UIImageView
                starImageView.image = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            }
        }
        if grade == 5 {
            return
        }
        let starImageView = self.starStackView.arrangedSubviews[integerPart] as! UIImageView
        if decimalPart == 0 {
            starImageView.image = UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
        } else {
            starImageView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
        }
        if integerPart + 1 < 4 {
            for index in integerPart + 1...4 {
                let starImageView = self.starStackView.arrangedSubviews[index] as! UIImageView
                starImageView.image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            }
        }
        
    }
}







