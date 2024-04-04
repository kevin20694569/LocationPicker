
import UIKit

class MessageManager {
    let ip = APIKey.IP
    let user_id : Int = Constant.user_id
    static let shared = MessageManager()
    lazy var API =  ip + "/chatrooms/messages"
    
    func getMessagesFromChatroomID(chatroom_id : String, date: String) async throws -> [Message] {
        do {
            let urlstring = API + "/\(chatroom_id)?date=\(date)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2.0
            
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoder = JSONDecoder()
            let messagesJson = try decoder.decode([MessageJson].self, from: data)
            let messages = messagesJson.map { json in
                return Message(json: json)
            }
            return messages
        } catch  {
            throw error
        }
    }
    
    func getInitMessagesFromUser_ID( user_ids : [Int]) async throws -> [Message] {
        do {
            let urlstring = API
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.timeoutInterval = 2.0
            
            let params = [ "user_ids" : user_ids ]
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            req.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoder = JSONDecoder()
            let messagesJson = try decoder.decode([MessageJson].self, from: data)
            let messages = messagesJson.map { json in
                return Message(json: json)
            }
            return messages
        } catch  {
            throw error
        }
    }
    
    
    
    
    
    struct MessageRequestBody : Encodable {
        var room_id : String
        var date : String
    }
    
}
