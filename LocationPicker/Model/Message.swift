import UIKit

enum MessageType {
    case Text, SharedPost
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
    
    var restaurantJson : RestaurantJson?
    
    var snapshotMedia : Media?
    
    var messageType : MessageType! {
        if let postJson = postJson {
            return .SharedPost
        }
        return .Text
    }
    
    init(message_id: String? = nil, room_id : String, sender_id: Int, message: String, isRead: Bool,  created_time : String) {
        self.message_id = message_id
        self.room_id = room_id
        self.sender_id = sender_id
        self.message = message
        self.isRead = isRead
        self.created_time = created_time
        self.agoTime = created_time.timeAgoFromString()
    }
    
    init(json : MessageJson) {
        self.message_id = json.message_id
        self.room_id = json.room_id
        self.sender_id = json.sender_id
        self.message = json.message
        self.isRead = json.isRead
        self.created_time = json.created_time
        self.agoTime = json.created_time?.timeAgoFromString()
        self.postJson = json.post
        self.restaurantJson = json.restaurant
        self.snapshotMedia = Media(json: json.post?.media?.first)
    }
    
    
    
    static let examples = Array(repeating: Message(room_id: "1_2", sender_id: [1, 2].randomElement()!, message: "你好", isRead: false, created_time: "0"), count: 80)
    
}


struct MessageJson : Codable {
    var message_id: String?
    var room_id: String?
    var sender_id: Int?
    var message: String?
    var isRead: Bool?
    var created_time: String?
    
    var shared_Post_id : String?
    
    var post : PostDetailJson?
    
    var restaurant : RestaurantJson?
    
    enum CodingKeys : String, CodingKey {
        case message_id = "_id"
        case room_id = "room_id"
        case sender_id = "sender_id"
        case message = "message"
        case isRead = "isRead"
        case created_time = "created_time"
        case shared_Post_id = "shared_Post_id"
        case post = "post"
        case restaurant = "restaurant"
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
        self.post = try container.decodeIfPresent(PostDetailJson.self, forKey: .post)
        self.restaurant = try container.decodeIfPresent(RestaurantJson.self, forKey: .restaurant)

    }
    
    
    
}
