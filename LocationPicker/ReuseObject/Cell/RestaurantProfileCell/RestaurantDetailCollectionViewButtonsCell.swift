import UIKit



class RestaurantDetailCollectionViewButtonsCell : CollectionViewInCollectionCell, RestaurantProfileCollectionCell, UIViewControllerTransitioningDelegate {
    var restaurant : Restaurant!
    
    weak var presentDelegate : PresentDelegate?
    
    let collectionExtraButtonsDict : [String : (identify : String, image : UIImage, text:  String)]! = [
        "phone" : ("phone", UIImage(systemName: "phone.fill")! , "致電"),
        "website" : ("website", UIImage(systemName: "globe")! , "網站")
    ]
    
    var activeButtonsArray : [(identify : String, image : UIImage, text:  String)] = [
        ("navigation" ,UIImage(systemName: "paperplane.fill")! , "導航"),
    ]
    
    var trailingButtonsArray : [(identify : String,image : UIImage, text:  String)] = [
        ("collect" ,UIImage(systemName: "star")!, "收藏"),
        ("share", UIImage(systemName: "square.and.arrow.up")! , "分享")]
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.width / 4.8, height: self.bounds.height)
    }
    
    @objc func presentAddCollectViewController(_ gesture : UITapGestureRecognizer) {
        
        let viewController = AddCollectViewController()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        presentDelegate?.present(viewController, animated: true)
    }
    
    @objc func presentShareViewController(_ gesture : UITapGestureRecognizer) {
        
        let viewController = ShareRestaurantController(restaurant: self.restaurant)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        presentDelegate?.present(viewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewButtonCell", for: indexPath) as! CollectionViewButtonCell
        let tuple = activeButtonsArray[index]
        let id = tuple.identify
     
        if id == "navigation" {
            cell.button.addTarget(self, action: #selector(openGoogleMapsForSearch), for: .touchUpInside)
        } else if id == "phone" {
            cell.button.addTarget(self, action: #selector(presentCallUpAlert), for: .touchUpInside)
        } else if id == "website" {
            cell.button.addTarget(self, action: #selector(openRestaurantWebsite), for: .touchUpInside)
            
            
        } else if id == "collect" {
            cell.button.addTarget(self, action: #selector(presentAddCollectViewController( _ :)), for: .touchUpInside)
        } else if id == "share" {
            cell.button.addTarget(self, action: #selector(presentShareViewController( _ :)), for: .touchUpInside)
        }
        cell.configure(buttonIndex: indexPath.row, text: tuple.text, image: tuple.image)
        return cell
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let bounds = UIScreen.main.bounds
        
        let maxWidth = bounds.width - 16
        var maxHeight : CGFloat! = bounds.height * 0.5
        if presented is ShareViewController {
            maxHeight =  bounds.height * 0.7
        }
        return MaxFramePresentedViewPresentationController(presentedViewController: presented, presenting: presenting, maxWidth: maxWidth, maxHeight: maxHeight)
       // return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tuple = activeButtonsArray[indexPath.row]
        let id = tuple.identify
        let cell = cell as! CollectionViewButtonCell
        if var config = cell.button.configuration {
            if id == "navigation" {
                config.baseBackgroundColor = .tintOrange
               
            } else if id == "phone" {

            } else if id == "website" {
                
                
                
            } else if id == "collect" {
                
            } else if id == "share" {
                
            }
            cell.button.configuration = config
        }
    }
                                      

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeButtonsArray.count
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func configure(restaurant: Restaurant) {
        self.restaurant = restaurant
        if restaurant.formatted_phone_number != nil {
            let phoneKey = "phone"
            activeButtonsArray.append(collectionExtraButtonsDict[phoneKey]!)
        }
        if restaurant.website != nil {
            let phoneKey = "website"
            activeButtonsArray.append(collectionExtraButtonsDict[phoneKey]!)
        }
        
        activeButtonsArray.append(contentsOf: self.trailingButtonsArray)
    }
    
    @objc func openGoogleMapsForSearch() {
        if let url = URL(string: "comgooglemaps://?q=" + self.restaurant.name) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                openGoogleMapsInBrowser(query: self.restaurant.name)
            }
        }
    }
    
    @objc func openRestaurantWebsite() {
        guard let website = restaurant.website else {
            return
        }
        
        if let url = URL(string: website) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                openGoogleMapsInBrowser(query: self.restaurant.name)
            }
        }
    }
    
    @objc func presentCallUpAlert() {
        guard let num = restaurant.formatted_phone_number else {
            return
        }
        if let url = URL(string: "tel://" + num) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    func openGoogleMapsInBrowser(query: String) {
        if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
