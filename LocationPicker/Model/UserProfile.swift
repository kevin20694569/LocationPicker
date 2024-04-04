

import UIKit

struct UserProfile  {
    
    var user : User!
    
    var isFriend : Bool? = false
    
    var userProfileStatus : UserStatus! = .default
    
    init(user: User, isFriend: Bool) {
        self.user = user
        self.isFriend = isFriend
    }
    
    init(profileJson : UserProfileJson) {
        if let userJson = profileJson.userJson {
            self.user = User(userJson:userJson)
            if userJson.user_id == Constant.user_id {
                self.userProfileStatus = .isSelfProfile
            } else {
                self.userProfileStatus = profileJson.isFriend ?? false ? .isFriend : .notFriend
            }
        }
        self.isFriend = profileJson.isFriend

    }
    
    static let example = UserProfile(user: User.example, isFriend: false)
    
    init() {
        self.user = User()
    }
}

struct UserProfileJson : Codable {
    
    var isFriend : Bool? = false
    
    var userJson : UserJson?
    
    enum CodingKeys : String, CodingKey {
        case userJson = "user"
        case isFriend = "isFriend"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userJson = try container.decodeIfPresent(UserJson.self, forKey: .userJson)
        self.isFriend = try container.decodeIfPresent(Bool.self, forKey: .isFriend)
    
    }
    
}
