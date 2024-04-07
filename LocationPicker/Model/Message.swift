import UIKit

enum MessageType : Int, Codable {
    case General = 0
    case PostShare = 1
    case UserShare = 2
    case RestaurantShare = 3
    case ErrorType = -1
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
    var sender_id: Int!
    var message: String?
    var isRead: Bool!
    var created_time: String!
    var agoTime : String!
    
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
    
    init(messageType : MessageType, message_id: String? = nil, room_id : String, sender_id: Int, message: String, isRead: Bool,  created_time : String) {
        self.message_id = message_id
        self.room_id = room_id
        self.sender_id = sender_id
        self.message = message
        self.isRead = isRead
        self.created_time = created_time
        self.agoTime = created_time.timeAgoFromString()
        self.messageType = messageType
    }
    
    init(json : MessageJson) {
        self.messageType = MessageType(rawValue: json.type ?? -1)!
        self.message_id = json.message_id
        self.room_id = json.room_id
        self.sender_id = json.sender_id
        self.message = json.message
        self.isRead = json.isRead
        self.created_time = json.created_time
        self.agoTime = json.created_time?.timeAgoFromString()
        self.postJson = json.sharedPost
        if let userJson = json.sharedUser {
            self.sharedUser = User(userJson:userJson)
        }
        if let sharedPostRestaurantJson = json.sharedPostRestaurant {
            self.sharedPostRestaurant = Restaurant(json: sharedPostRestaurantJson)
        }
        if let restaurantJson = json.sharedRestaurant {
            self.sharedRestaurant = Restaurant(json: restaurantJson )
        }


        
        switch self.messageType {
        case .General :
            return
        case .PostShare :
            guard let url = json.sharedPost?.media?.first?.url else {
                return
            }
            self.snapshotImageURL = URL(string: url)
        case .UserShare :
            guard let url = json.sharedUser?.user_imageurl else {
                return
            }
            self.snapshotImageURL = URL(string: url)
        case .RestaurantShare :
            guard let url = json.sharedRestaurant?.imageurl else {
                return
            }
            self.snapshotImageURL = URL(string: url)
        case .none:
            return
        case .some(.ErrorType):
            return
        }
        

    }
    
    
    
    static let examples = Array(repeating: Message( messageType : .General, room_id: "1_2", sender_id: [1, 2].randomElement()!, message: "你好", isRead: false, created_time: "0"), count: 80)
    
}


struct MessageJson : Codable {
    var message_id: String?
    var room_id: String?
    var sender_id: Int?
    var message: String?
    var isRead: Bool?
    var created_time: String?
    
    var shared_Post_id : String?
    
    var type : Int?
    
    var sharedPost : PostDetailJson?
    
    var sharedUser : UserJson?
    
    var sharedPostRestaurant : RestaurantJson?
    
    var sharedRestaurant : RestaurantJson?
    
    
    
    enum CodingKeys : String, CodingKey {
        case message_id = "_id"
        case room_id = "room_id"
        case sender_id = "sender_id"
        case message = "message"
        case isRead = "isRead"
        case created_time = "created_time"
        case shared_Post_id = "shared_Post_id"
        case sharedPost = "sharedPost"
        case sharedPostRestaurant = "sharedPostRestaurant"
        case sharedUser = "sharedUser"
        case sharedRestaurant = "sharedRestaurant"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message_id = try container.decodeIfPresent(String.self, forKey: .message_id)
        self.room_id = try container.decodeIfPresent(String.self, forKey: .room_id)
        self.sender_id = try container.decodeIfPresent(Int.self, forKey: .sender_id)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead)
        self.created_time = try container.decodeIfPresent(String.self, forKey: .created_time)
        self.shared_Post_id = try container.decodeIfPresent(String.self, forKey: .shared_Post_id)
        self.sharedPost = try container.decodeIfPresent(PostDetailJson.self, forKey: .sharedPost)
        
        self.sharedPostRestaurant = try container.decodeIfPresent(RestaurantJson.self, forKey: .sharedPostRestaurant)
        
        self.sharedUser = try container.decodeIfPresent(UserJson.self, forKey: .sharedUser)

        self.sharedRestaurant = try container.decodeIfPresent(RestaurantJson.self, forKey: .sharedRestaurant)
        self.type = try container.decodeIfPresent(Int.self, forKey: .type)
        

    }
    
    
    
}
