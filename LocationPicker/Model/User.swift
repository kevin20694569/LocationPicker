import UIKit


class User : Equatable, Hashable {

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id : String!
    var name : String!
    var image : UIImage?
    var imageURL : URL?
    
    var email : String?
    
    var posts_count : Int?
    var friends_count : Int?
    
    static var defaultExample : User! = User(user_id: "", name: "", image: UIImage(), imageURL: nil)
    

    

    
    static var examples : [User] = {
        var array : [User] = []
        for id in 1...50 {
            let user = User( user_id: String(id), name: "kevin" , image : UIImage(named: "user"), imageURL: nil)
            array.append(user)
        }
        return array
                
    }()
    
    init() {
        
    }
    
    static let example : User = User(user_id: Constant.user_id, name: "example", image: UIImage(named: "user"), imageURL: nil)
    
    
    
    init(user_id: String, name: String , image : UIImage?, imageURL : URL?) {
        self.id = user_id
        self.name = name
        self.image = image
        self.imageURL = imageURL
    }
    
    init(userJson: UserJson) {
        self.id = userJson.id
        self.name = userJson.name
        self.posts_count = userJson.posts_count
        self.friends_count = userJson.friends_count
        if let imageURL = userJson.imageurl {
            self.imageURL = URL(string: imageURL)
        }
        self.posts_count = userJson.posts_count
        self.friends_count = userJson.friends_count
        self.email = userJson.email
    }
    
    
}




struct UserJson : Codable {
    var id : String!
    var name : String?
    var posts_count : Int?
    var email : String?
    var friends_count : Int?
    var imageurl : String?
    var created_at : String?
    
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "name"
        

        case email = "email"
        case posts_count = "posts_count"
        case friends_count = "friends_count"

        case created_at = "created_at"
        case imageurl = "user_imageurl"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imageurl = try container.decodeIfPresent(String.self, forKey: .imageurl)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.posts_count = try container.decodeIfPresent(Int.self, forKey: .posts_count)
        self.friends_count = try container.decodeIfPresent(Int.self, forKey: .friends_count)
        self.created_at =  try container.decodeIfPresent(String.self, forKey: .created_at)
    }
}
