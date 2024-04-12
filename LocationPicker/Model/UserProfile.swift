

import UIKit

struct UserProfile  {
    
    var user : User!
    var friendStatus : FriendStatus! = .default
    
    init(user: User, isFriend: Bool) {
        self.user = user
        self.friendStatus = isFriend ? .isFriend : .notFriend
    }
    
    init(profileJson : UserProfileJson) {
        if let userJson = profileJson.userJson {
            self.user = User(userJson:userJson)
            self.friendStatus = FriendStatus(rawValue: profileJson.friendStatus)
        }


    }
    
    static let example = UserProfile(user: User.example, isFriend: false)
    
    init() {
        self.user = User()
    }
}

struct UserProfileJson : Codable {
    
    var friendStatus : String!
    
    var userJson : UserJson?
    
    enum CodingKeys : String, CodingKey {
        case userJson = "user"
        case friendStatus = "friendStatus"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userJson = try container.decodeIfPresent(UserJson.self, forKey: .userJson)
        self.friendStatus = try container.decodeIfPresent(String.self, forKey: .friendStatus)
    
    }
    
}
