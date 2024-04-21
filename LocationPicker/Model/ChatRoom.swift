import UIKit

class ChatRoomPreview : Hashable , Equatable {
    static func == (lhs: ChatRoomPreview, rhs: ChatRoomPreview) -> Bool {
        lhs.room_id == rhs.room_id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(room_id)
    }
    
    var room_id : String!
    var name : String!
    
    var messages : [Message]? = []
    var user : User?
    
    var chatRoom : ChatRoom!
    
    init (messagesJson : [MessageJson]?, user : UserJson, chatroomJson : ChatRoomJson){
        self.room_id = chatroomJson.room_id
        if let messagesJson = messagesJson {
            messagesJson.forEach { json in
                self.messages?.append(Message(json: json))
            }
            self.room_id = messagesJson.first?.room_id
        }
        self.chatRoom = ChatRoom(json: chatroomJson)
        self.name = user.name
       
        self.user = User(userJson: user)
    }
    
    static var hasRecievedRoom_IDs : [String : String]! = [ : ]
    
}

struct ChatRoom {
    var user_ids : [String]! = []
    var room_id : String!
    
    
    init(json : ChatRoomJson) {
        self.user_ids = json.user_ids
        self.room_id = json.room_id
    }
}

struct ChatRoomPreviewJson : Codable {
    
    var messages : [MessageJson]?
    
    var chatroom : ChatRoomJson!
    
    var user : UserJson!
    
    
    enum CodingKeys : String, CodingKey {
        case user = "user"
        case messages = "messages"
        case chatroom = "chatroom"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messages = try container.decodeIfPresent([MessageJson].self, forKey: .messages)
        self.user = try container.decodeIfPresent(UserJson.self, forKey: .user)
        self.chatroom = try container.decodeIfPresent(ChatRoomJson.self, forKey: .chatroom)
    }
    
}

struct ChatRoomJson : Codable {
    var user_ids : [String]!
    
    var room_id : String!
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_ids = try container.decodeIfPresent([String].self, forKey: .user_ids)
        self.room_id = try container.decodeIfPresent(String.self, forKey: .room_id)
    }
    
}
