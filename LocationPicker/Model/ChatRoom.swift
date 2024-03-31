import UIKit

class ChatRoom : Hashable , Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.room_id == rhs.room_id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(room_id)
    }
    
    var room_id : String!
    var lastMessage : String?
    var senderId : Int?
    var isRead : Bool?
    
    var lastTimeStamp : String?

    var room_name : String!
    
    var user : User?
    
    init(room_id: String!, lastMessage: String? = nil, senderId: Int? = nil, isRead: Bool? = nil, room_name: String!, lastTimeStamp : String? ,  user : User?) {
        self.room_id = room_id
        self.lastMessage = lastMessage
        self.senderId = senderId
        self.isRead = isRead
        self.lastTimeStamp = lastTimeStamp
        self.room_name = room_name
        self.user = user
    }
    
    convenience init(json : ChatroomJson) {
        var user : User?
        if let userJson = json.user {
            user = User(userJson: userJson)
        }
        let messageJson = json.lastMessageJson!
        let room_id = json.lastMessageJson.room_id!
        var lastMessage = json.lastMessageJson.message

        self.init(room_id: messageJson.room_id, lastMessage: lastMessage,  senderId: messageJson.sender_id, isRead: messageJson.isRead , room_name: user?.name, lastTimeStamp: messageJson.created_time, user: user)
    }
    
    static var hasRecievedRoom_IDs : [String : String]! = [ : ]
    
}

struct ChatroomJson : Codable {
    
    var lastMessageJson : MessageJson!

    
    var user : UserJson?
    
    
    enum CodingKeys : String, CodingKey {
        case user = "user"
        case lastMessageJson = "lastMessage"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lastMessageJson = try container.decodeIfPresent(MessageJson.self, forKey: .lastMessageJson)
        self.user = try container.decodeIfPresent(UserJson.self, forKey: .user)
    }
    
    
}
