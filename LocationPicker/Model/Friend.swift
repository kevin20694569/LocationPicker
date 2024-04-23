import UIKit
enum FriendStatus : String {
    case isSelf, isFriend, notFriend, hasBeenSentRequest, requestNeedRespond, `default`

    var mainButtonTitle : String {
        switch self {
        case .isSelf :
            return ""
        case .isFriend:
            return "朋友"
        case .notFriend:
            return "加朋友"
        case .default:
            return ""
        case .hasBeenSentRequest:
            return "取消邀請"
        case .requestNeedRespond:
            return "接受邀請"
        }
    }

    var mainImage : UIImage? {
        switch self {
        case .isSelf :
            return UIImage(systemName: "checkmark")!
        case .isFriend:
            return UIImage(systemName: "person.fill.checkmark")!
            
        case .notFriend:
            return UIImage(systemName: "person.fill.badge.plus")!

        case .hasBeenSentRequest:
            return UIImage(systemName: "xmark")!
        case .requestNeedRespond:
            return nil
        case .default:
            return nil
        }
    }
    
    var mainColor : UIColor {
        switch self {
        case .isSelf :
            return .white
        case .isFriend:
            return .white
            
        case .notFriend:
            return .white
        case .default:
            return .white
        case .hasBeenSentRequest:
            return .white
        case .requestNeedRespond:
            return .white
        }
    }
    
    var backgroundColor : UIColor {
        switch self {
        case .isSelf:
            return .tintOrange
        case .isFriend:
            return.systemGreen
        case .notFriend:
            return .secondaryLabelColor
        case .hasBeenSentRequest:
            return .systemRed
        case .requestNeedRespond:
            return .tintOrange
        case .default:
            return   .secondaryLabelColor
        }
    }
}

struct Friend  {
    
    var friendship_time : String?
    
    var user : User!

    
    var friendStatus : FriendStatus! = .default
    
    
    static let examples : [Friend] = {
        Array.init(repeating: Friend(friendship_time: "", user: User.example, isFriend: true), count: 20)
        
    }()
    
    
    init(json : FriendJson) {
        self.friendship_time = json.friendship?.created_time
        let user = User(userJson: json.userJson)
        self.friendStatus = FriendStatus(rawValue: json.friendStatus)
        self.user = user
    }
    
    init(friendship_time : String, user : User, isFriend :Bool) {
        self.friendship_time = friendship_time
        self.friendStatus = isFriend ? .isFriend : .notFriend
        self.user = user
    }
    
}

struct FriendJson : Codable {
    var friendship : FriendShipJson!
    
    var userJson : UserJson!
    
    var friendStatus : String!
    
    enum CodingKeys : String, CodingKey {
        case friendship = "friendship"
        case userJson = "user"
        case friendStatus = "friendStatus"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.friendship = try container.decodeIfPresent(FriendShipJson.self, forKey: .friendship)
        self.userJson = try container.decodeIfPresent(UserJson.self, forKey: .userJson)
        self.friendStatus = try container.decodeIfPresent(String.self, forKey: .friendStatus)
    }
    
    
}

struct FriendShipJson : Codable {
    var created_time : String?
    
    
    enum CodingKeys : String, CodingKey {
        case created_time = "created_time"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.created_time = try container.decodeIfPresent(String.self, forKey: .created_time)
    }
}
