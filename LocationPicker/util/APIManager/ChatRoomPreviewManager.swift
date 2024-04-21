import UIKit
class ChatRoomPreviewManager {
    let ip = APIKey.IP
    let user_id : String = Constant.user_id
    static let shared = ChatRoomPreviewManager()
    lazy var API = ip + "/chatrooms/previews"
    
    func getChatroomPreviewsByLastMessageOrderFromUserID(user_id : String, date : String) async throws -> [ChatRoomPreview]   {
        do{
            let valueArray = Array(ChatRoomPreview.hasRecievedRoom_IDs.values)
            let urlstring = API + "/lastmessageorder/\(user_id)?date=\(date)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.timeoutInterval = 2.0
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let dict: [String: Any?] = [
                "room_idsToExclude" : valueArray
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            req.httpBody = jsonData
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let chatRoomPreviewResultJson = try decoder.decode(ChatRoomPreviewResultJson.self, from: data)
            if let previews = chatRoomPreviewResultJson.previews {
                var chatrooms = previews.map { json in
                    let preview = ChatRoomPreview(messagesJson: json.messages, user: json.user, chatroomJson: json.chatroom)
                    preview.messages?.reverse()
                    return preview
                }
                return chatrooms
            }
            return []

            
        } catch  {
            throw error
        }
    }
    
    func getSingleChatroomPreviewFromRoom_ID(room_id : String) async throws -> ChatRoomPreview  {
        do {
            let urlstring = API + "/\(room_id)?request_user_id=\(self.user_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2.0
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let chatroomsJson = try decoder.decode(ChatRoomPreviewJson.self, from: data)
            let preview = ChatRoomPreview(messagesJson: chatroomsJson.messages, user: chatroomsJson.user, chatroomJson: chatroomsJson.chatroom)
            preview.messages?.reverse()
            return preview
        } catch  {
            throw error
        }
    }
    
    func getSingleChatRoomPreviewFromEachID(user_ids : [String]) async throws -> ChatRoomPreview {
        do {
            let urlstring = API + "?request_user_id=\(self.user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)

            let params : [String : Any] = [ "user_ids" : user_ids]
         

            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpMethod = "POST"
            req.timeoutInterval = 2.0
            let body = try JSONSerialization.data(withJSONObject: params)
            req.httpBody = body
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let chatroomsJson = try decoder.decode(ChatRoomPreviewJson.self, from: data)
            let preview = ChatRoomPreview(messagesJson: chatroomsJson.messages, user: chatroomsJson.user, chatroomJson: chatroomsJson.chatroom)
            preview.messages?.reverse()
            return preview
            
        } catch {
            throw error
        }
    }
    

    

}

class ChatRoomManager : NSObject {
    let ip = APIKey.IP
    let user_id : String = Constant.user_id
    static let shared = ChatRoomManager()
    lazy var API =  ip + "/chatrooms"
    
    
    func getSingleChatRoom(user_ids : [String]) async throws -> ChatRoom  {
        do {
            let urlstring = API + "?request_user_id=\(self.user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)

            let params : [String : Any] = [ "user_ids" : user_ids]
         

            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpMethod = "POST"
            req.timeoutInterval = 2.0
            let body = try JSONSerialization.data(withJSONObject: params)
            req.httpBody = body
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let chatroomsJson = try decoder.decode(ChatRoomJson.self, from: data)
            return  ChatRoom(json: chatroomsJson)
            
        } catch {
            throw error
        }
    }
}


struct ChatRoomPreviewResultJson : Codable {
    var responded_room_ids : [String]?
    
    var previews : [ChatRoomPreviewJson]?
    
    enum CodingKeys : String,  CodingKey  {
        case responded_room_ids = "responded_room_ids"
        case previews = "previews"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.responded_room_ids = try container.decodeIfPresent([String].self, forKey: .responded_room_ids)
        self.previews = try container.decodeIfPresent([ChatRoomPreviewJson].self, forKey: .previews)
    }
}
