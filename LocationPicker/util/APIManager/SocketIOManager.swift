import UIKit
import SocketIO



class SocketIOManager : NSObject {
    
    weak var progressDelegate : UploadDelegate?
    
    var socket_id : String?
    
    static let shared = SocketIOManager()
    
    var chatRoomViewController : ChatRoomViewController?
    
    let  manager = SocketManager(socketURL: URL(string: APIKey.IP)! , config: [
        .log(true),
        .compress,
        .reconnectWait(1)
    ])
    var socket : SocketIOClient!
    
    override init () {
        super.init()
        socket = manager.defaultSocket
        listening()
        socket.connect()

    }
    
    
    func listening() {
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket has been connected")
            if let dict = data[1] as? Dictionary<String, Any>,
               let id = dict["sid"] as? String {
                self.socket_id = id
            }
            let dict : Dictionary<String, any Hashable> = ["socket_id" : self.socket_id ,"user_id": Constant.user_id]
            self.socket.emit("connectParams", dict )
        }
        
        socket.on(clientEvent: .error) {data, ack in
            print("Socket error")
        }
        
        socket.on("message") { dataArray, SocketAckEmitter in
            let decoder = JSONDecoder()
            guard let data = dataArray.first as? Data else {
                return
            }
            let messagesJson = try? decoder.decode([MessageJson].self, from: data)
            messagesJson?.forEach() {
                let message = Message(json: $0)
                let notification = Notification(name: Notification.Name(rawValue: "ReceivedMessageNotification"), object: nil, userInfo: [
                    "message": message])
                
                NotificationCenter.default.post(notification)
            }
            
        }
        
        
        socket.on("messageIsRead") { data , SocketAckEmitter in
            if let dict = data.first as? [String : Any],
               let room_id = dict["room_id"] as? String {
                let notification = Notification(name: Notification.Name(rawValue: "ReceivedMessageIsReadNotification"), object: nil, userInfo: ["room_id": room_id])
                NotificationCenter.default.post(notification)
            }
            
        }
        
        socket.on(clientEvent: .reconnect){ data, ack in
            let dict : Dictionary<String, any Hashable> = ["socket_id" : self.socket_id ,"user_id": Constant.user_id]
            self.socket.emit("connectParams", dict )
            self.chatRoomViewController?.refreshChatRoomsPreview()
        }
        
        
        socket.on("uploadProgress") { data , SocketAckEmitter in
            
            if let jsonData = data.first as? [String : Any],
               let progress = jsonData["progress"] as? Double {
                self.progressDelegate?.receiveUploadProgress(progress: progress)
            }
        }
        socket.on("uploadTaskFinished") { data , SocketAckEmitter in
            if let jsonData = data.first as? [String : Any],
               let successInt = jsonData["success"] as? Int
            {
                let success = successInt == 1 ? true : false
                self.progressDelegate?.receiveUploadFinished(success: success)
            }
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket has been disconnected")
        }
        
        
    }
    
    func recursivelyConvertToJsonString(from dictionary: [String: Any]) -> [String : Any]  {
        var convertedDictionary = dictionary
        for (key, value) in dictionary {
            if let nestedDictionary = value as? [String: Any] {
                convertedDictionary[key] = recursivelyConvertToJsonString(from: nestedDictionary)
            } else if let nestedArray = value as? [[String: Any]] {
                convertedDictionary[key] = nestedArray.map { recursivelyConvertToJsonString(from: $0) }
            }
        }
        return convertedDictionary
    }
    
    func convertToJsonString(from dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }
        return nil
    }
    
    func joinRooms(room_ids : [String]) {
        let dict : [String : Any] = [ "room_ids" : room_ids]
        socket.emit("joinRooms", dict)
        
    }
    

    
    func sendMessageByRoomID(to_room_id: String , sender_id : String, message: String) {
        
        let dict : [String : Any?] = [ "room_id" : to_room_id,
                                      "message" : message,
                                      "sender_id" : sender_id,

        ]
        socket.emit("message", dict)
    }
    
    func sendMessageByToUserIDs(to_user_ids: [String] , sender_id : String, message: String) {
        
        let dict : [String : Any?] = [ "receive_ids" : to_user_ids,
                                      "message" : message,
                                      "sender_id" : sender_id,

        ]
        socket.emit("message", dict)
    }
    
    func sharePost(to_user_ids: [String], sender_id : String, post : Post) {
        let dict : [String : Any?] = [ "sender_id" : sender_id,
                                       "receive_ids" : to_user_ids,
                                      "shared_post_id" : post.id,
        ]
        
        socket.emit("sharePostByMessage", dict)
    }
    
    func shareRestaurant(to_user_ids : [String], sender_id : String, restaurant : Restaurant) {
        let dict : [String : Any?] = [ "sender_id" : sender_id,
                                       "receive_ids" : to_user_ids,
                                       "shared_restaurant_id" : restaurant.ID,
        ]
        socket.emit("shareRestaurantByMessage", dict)
    }
    
    func shareUser(to_user_ids : [String], sender_id : String, user : User) {
        let dict : [String : Any?] = [ "sender_id" : sender_id,
                                       "receive_ids" : to_user_ids,
                                       "shared_user_id" : user.id,
        ]
        socket.emit("shareUserByMessage", dict)
    }
    
    func markAsRead(room_id : String, sender_id : String) {
        let dict : [String : Any] = ["room_id": room_id,
                                     "sender_id" : sender_id]
        socket.emit("isRead", dict)
    }
    
    
    
    
    
}

