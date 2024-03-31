
struct Friend  {
    
    var friendship_time : String!
    
    var user : User!
    
    
    init(json : FriendJson) {
        self.friendship_time = json.friendship?.friendship_time
        let user = User(userJson: json.userJson)
        self.user = user
    }
    
}

struct FriendJson : Codable {
    var friendship : FriendShipJson!
    
    var userJson : UserJson!
    
    enum CodingKeys : String, CodingKey {
        case friendship = "friendship"
        case userJson = "user"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.friendship = try container.decodeIfPresent(FriendShipJson.self, forKey: .friendship)
        self.userJson = try container.decodeIfPresent(UserJson.self, forKey: .userJson)
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
