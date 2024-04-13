import UIKit

class UserFriendRequest : Equatable, Hashable {
    static func == (lhs: UserFriendRequest, rhs: UserFriendRequest) -> Bool {
        lhs.request_ID == rhs.request_ID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(request_ID)
    }
    
    var request_ID: Int!
    var sent_time: String!

    var isResponsed : Bool! = false
    
    var user : User?
    
    var friendStatus : FriendStatus! = .requestNeedRespond
    
    
    
    init(request_ID: Int!, sent_time: String!, user_ID: Int!, name: String!, user_imageurl : URL?, userimage : UIImage? ) {
        self.request_ID = request_ID
        self.sent_time = sent_time
    }
    
    init(json: UserRequestJson) {
        if let request = json.request {
            
           // self.request_ID = Int(request.request_ID!)
            self.sent_time = request.sent_time
        }
        
        if let userJson = json.user {
            self.user = User(userJson: userJson)
        }
        
        
    }
    
    
    
    static var examples : [UserFriendRequest] = {
        var array : [UserFriendRequest] = []
        (0...20).forEach { index in
           let req = UserFriendRequest(request_ID: index, sent_time: "111", user_ID: index, name: String(index), user_imageurl: nil, userimage: UIImage())
            array.append(req)
        }
        return array
    }()
    
}


struct UserRequestJson : Codable {
    var user : UserJson?
    var request : FriendRequestJson?
    
    enum CodingKeys : String, CodingKey {
        case user = "user"
        case request = "request"

    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.request = try container.decodeIfPresent(FriendRequestJson.self, forKey: .request)
        self.user = try container.decodeIfPresent(UserJson.self, forKey: .user)
    }
    
}

struct FriendRequestJson : Codable {
    var sent_time : String?
   // var request_ID : Double?
    
    enum CodingKeys : String, CodingKey {
        case sent_time = "sent_time"
      //  case request_ID = "request_ID"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sent_time = try container.decodeIfPresent(String.self, forKey: .sent_time)
       // self.request_ID = try container.decode(Double.self, forKey: .request_ID)
    }
}


