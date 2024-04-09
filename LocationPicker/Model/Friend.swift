
struct Friend  {
    
    var friendship_time : String!
    
    var user : User!
    
    var isFriend : Bool! = false
    
    
    static let examples : [Friend] = {
        Array.init(repeating: Friend(friendship_time: "", user: User.example, isFriend: true), count: 20)
        
    }()
    
    
    init(json : FriendJson) {
        self.friendship_time = json.friendship?.friendship_time
        let user = User(userJson: json.userJson)
        self.isFriend = json.isFriend
        self.user = user
    }
    
    init(friendship_time : String, user : User, isFriend : Bool) {
        self.friendship_time = friendship_time
        self.isFriend = isFriend
        self.user = user
    }
    
}

struct FriendJson : Codable {
    var friendship : FriendShipJson!
    
    var userJson : UserJson!
    
    var isFriend : Bool! = false
    
    enum CodingKeys : String, CodingKey {
        case friendship = "friendship"
        case userJson = "user"
        case isFriend = "isFriend"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.friendship = try container.decodeIfPresent(FriendShipJson.self, forKey: .friendship)
        self.userJson = try container.decodeIfPresent(UserJson.self, forKey: .userJson)
        self.isFriend = try container.decodeIfPresent(Bool.self, forKey: .isFriend)
    }
    
    
}

struct FriendShipJson : Codable {
    var friendship_time : String?
    
    
    enum CodingKeys : String, CodingKey {
        case friendship_time = "friendship_time"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.friendship_time = try container.decodeIfPresent(String.self, forKey: .friendship_time)
    }
}
