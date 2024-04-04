import UIKit
class ChatRoomsManager {
    let ip = APIKey.IP
    let user_id : Int = Constant.user_id
    static let shared = ChatRoomsManager()
    lazy var API =  ip + "/chatrooms"
    
    func getChatroomsPreviewFromUserID(user_id : Int, date : String) async throws -> [ChatRoom]   {
        do{
            let valueArray = Array(ChatRoom.hasRecievedRoom_IDs.values)
            let urlstring = API + "/requestuserid/\(user_id)?date=\(date)"
            
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
            if let chatroomsJson = try? decoder.decode([ChatroomJson].self, from: data) {
                let chatrooms = chatroomsJson.map { json in
                    
                    return ChatRoom(json: json)
                }
                
                return chatrooms
            }
        } catch  {
            throw error
        }
        return []
    }
    
    func getSingleChatroomsPreviewFromUserID(room_id : String) async throws -> ChatRoom  {
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
            let chatroomsJson = try decoder.decode(ChatroomJson.self, from: data)
            return  ChatRoom(json: chatroomsJson)
        } catch  {
            throw error
        }
    }
    

}
