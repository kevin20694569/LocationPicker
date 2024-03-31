import UIKit

class Playlist  {
    
    var title : String!
    var imageURL : URL?
    var image : UIImage?
    
    static let examples : [Playlist] = {
        return Array.init(repeating: Playlist(title: "Playlist", image: UIImage(systemName: "map")! , imageURL: Constant.imageURL), count: 20)
    }()
    
    init(title : String, image : UIImage, imageURL : URL) {
        self.title = title
        self.imageURL = imageURL
        self.image = image
    }
}

