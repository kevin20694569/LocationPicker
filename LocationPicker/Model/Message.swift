import UIKit

enum MessageType : Int, Codable {
    case General = 0
    case PostShare = 1
    case UserShare = 2
    case RestaurantShare = 3
    case ErrorType = -1
    case startEmptyMessage = -2
}



class Message: Equatable, Hashable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return (lhs.sender_id == rhs.sender_id && lhs.created_time == rhs.created_time)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(message_id)
    }
    
    
    var message_id: String!
    var room_id: String!
    var sender_id: String!
    var message: String?
    var isRead: Bool?
    var created_time: String?
    var agoTime : String?
    
    var userImage : UIImage?
    
    var postJson : PostDetailJson?
    
    var sharedPostRestaurant : Restaurant?
    
    var sharedRestaurant : Restaurant?
    
    var sharedUser : User?
    
    var senderUser : User?
    
    var senderUserImage : UIImage?
    
    var senderUserImageURL : URL?
    
    var snapshotImageURL : URL?
    
    var snapshotImage : UIImage?
    
    var messageType : MessageType!
    
    init(messageType : MessageType?, message_id: String? = nil, room_id : String?, sender_id: String?, message: String?, isRead: Bool?,  created_time : String?) {
        self.message_id = message_id
        self.room_id = room_id
        self.sender_id = sender_id
        self.message = message
        self.isRead = isRead
        self.created_time = created_time
        if let created_time = created_time {
            self.agoTime = created_time.timeAgoFromString()
        }
        self.messageType = messageType
    }
    
    init(json : MessageJson) {
        self.messageType = MessageType(rawValue: json.type ?? -1)!
        self.message_id = json.message_id
        self.room_id = json.room_id
        self.sender_id = json.sender_id
        self.message = json.message
        self.isRead = json.isread
        self.created_time = json.created_time
        self.agoTime = json.created_time?.timeAgoFromString()
        self.postJson = json.shared_post
        if let userJson = json.shared_user {
            self.sharedUser = User(userJson:userJson)
        }
        if let sharedPostRestaurantJson = json.shared_post_restaurant {
            self.sharedPostRestaurant = Restaurant(json: sharedPostRestaurantJson)
        }
        if let restaurantJson = json.shared_restaurant {
            self.sharedRestaurant = Restaurant(json: restaurantJson )
        }


        
        switch self.messageType {
        case .General :
            return
        case .PostShare :
            guard let url = json.shared_post?.media?.first?.url else {
                return
            }
            self.snapshotImageURL = URL(string: url)
        case .UserShare :
            guard let url = json.shared_user?.imageurl else {
                return
            }
            self.snapshotImageURL = URL(string: url)
        case .RestaurantShare :
            guard let url = json.shared_restaurant?.imageurl else {
                return
            }
            self.snapshotImageURL = URL(string: url)
        case .none:
            return
        case .some(.ErrorType):
            return
        case .some(.startEmptyMessage):
            return
        }
        

    }
    
    static let examples = Array(repeating: Message( messageType : .General, room_id: "661f99aefd2f5b0eba052b67", sender_id: "Y8hqarQJ_hnpIJYoc72L0", message: "你好", isRead: true, created_time: "2024-04-20T15:49:59.880Z"), count: 20)
    
}


struct MessageJson : Codable {
    var message_id: String?
    var room_id: String?
    var sender_id: String?
    var message: String?
    var isread: Bool?
    var created_time: String?

    var type : Int?
    
    var shared_post_id : String?
    var shared_post : PostDetailJson?
    var shared_post_restaurant : RestaurantJson?
    
    var shared_user_id : String?
    var shared_user : UserJson?
    
    var shared_restaurant_id : String?
    var shared_restaurant : RestaurantJson?
    

    
    
    
    enum CodingKeys : String, CodingKey {
        case message_id = "_id"
        case room_id = "room_id"
        case sender_id = "sender_id"
        case message = "message"
        case isread = "isread"
        case created_time = "created_time"
        case shared_post_id = "shared_post_id"
        case shared_post = "shared_post"
        case shared_post_restaurant = "shared_post_restaurant"
        case shared_user_id = "shared_user_id"
        case shared_user = "shared_user"
        case shared_restaurant_id = "shared_restaurant_id"
        case shared_restaurant = "shared_restaurant"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message_id = try container.decodeIfPresent(String.self, forKey: .message_id)
        self.room_id = try container.decodeIfPresent(String.self, forKey: .room_id)
        self.sender_id = try container.decodeIfPresent(String.self, forKey: .sender_id)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.isread = try container.decodeIfPresent(Bool.self, forKey: .isread)
        self.created_time = try container.decodeIfPresent(String.self, forKey: .created_time)
        self.type = try container.decodeIfPresent(Int.self, forKey: .type)
        
        self.shared_post_id = try container.decodeIfPresent(String.self, forKey: .shared_post_id)
        self.shared_post = try container.decodeIfPresent(PostDetailJson.self, forKey: .shared_post)
        self.shared_post_restaurant = try container.decodeIfPresent(RestaurantJson.self, forKey: .shared_post_restaurant)
        
       
        self.shared_user_id =  try container.decodeIfPresent(String.self, forKey: .shared_user_id)
        self.shared_user = try container.decodeIfPresent(UserJson.self, forKey: .shared_user )
        
        self.shared_restaurant_id =  try container.decodeIfPresent(String.self, forKey: .shared_restaurant_id)
        self.shared_restaurant = try container.decodeIfPresent(RestaurantJson.self, forKey: .shared_restaurant )
        
      

        
       
        

    }
    
    
    
}
