import UIKit

enum UserStatus {
    case isSelfProfile, isFriend, notFriend, `default`
    
    var mainButtonTitle : String {
        switch self {
        case .isSelfProfile :
            return ""
        case .isFriend:
            return "朋友"
        case .notFriend:
            return "加朋友"
        case .default:
            return ""
        }
    }

    var mainImage : UIImage? {
        switch self {
        case .isSelfProfile :
            return UIImage(systemName: "checkmark")!
        case .isFriend:
            return UIImage(systemName: "person.fill.checkmark")!
            
        case .notFriend:
            return UIImage(systemName: "person.fill.badge.plus")!
        case .default:
            return nil
        }
    }
    
    var mainColor : UIColor {
        switch self {
        case .isSelfProfile :
            return .tintOrange
        case .isFriend:
            return .systemGreen
            
        case .notFriend:
            return .secondaryLabelColor
        case .default:
            return .secondaryLabelColor
        }
    }
}
class User : Equatable, Hashable {

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.user_id == rhs.user_id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(user_id)
    }
    
    var user_id : Int!
    var name : String!
    var image : UIImage?
    var imageURL : URL?
    
    var posts_count : Int?
    var isFriend : Bool! = false
    var friends_count : Int?
    

    

    
    static var examples : [User] = {
        var array : [User] = []
        for id in 1...50 {
            let user = User( user_id: id, name: "kevin" , image : UIImage(named: "user"), imageURL: nil)
            array.append(user)
        }
        return array
                
    }()
    
    init() {
        
    }
    
    static let example : User = User(user_id: Constant.user_id, name: "example", image: UIImage(named: "user"), imageURL: nil)
    
    
    
    init(user_id: Int, name: String , image : UIImage?, imageURL : URL?) {
        self.user_id = user_id
        self.name = name
        self.image = image
        self.imageURL = imageURL
        self.isFriend = .random()
    }
    
    init(userJson: UserJson) {
        
        self.user_id = userJson.user_id
        self.name = userJson.name
        self.posts_count = userJson.posts_count
        self.friends_count = userJson.friends_count

        if let imageURL = userJson.user_imageurl {
            self.imageURL = URL(string: imageURL)
        }
        self.posts_count = userJson.posts_count
        self.friends_count = userJson.friends_count


    }
    
    
}




struct UserJson : Codable {
    var user_id : Int!
    var name : String?

    
    var posts_count : Int?
    
    var friends_count : Int?
    var user_imageurl : String?
    
    
    enum CodingKeys : String, CodingKey {
        case user_id = "user_id"
        case name = "user_name"
        case user_imageurl = "user_imageurl"
        case posts_count = "posts_count"
        case friends_count = "friends_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.user_imageurl = try container.decodeIfPresent(String.self, forKey: .user_imageurl)
       
        self.posts_count = try container.decodeIfPresent(Int.self, forKey: .posts_count)
        self.friends_count = try container.decodeIfPresent(Int.self, forKey: .friends_count)
    }
}
