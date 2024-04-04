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
        
        socket.on("messages") { data, SocketAckEmitter in
            let array = data.first as? [[String : Any]]
            array?.forEach() {
                let jsonData = $0
                if let sender_id = jsonData["sender_id"] as? Int {
                    let message = jsonData["message"] as? String ?? "錯誤"
                    let room_id = jsonData["room_id"] as? String ?? "錯誤"
                    let created_time = jsonData["created_time"] as? String ?? "錯誤"
                    let isRead = jsonData["isRead"] as? Bool ?? false
                    let messageModel = Message(room_id: room_id, sender_id: sender_id, message: message, isRead: isRead, created_time: created_time)
                    let notification = Notification(name: Notification.Name(rawValue: "ReceivedMessageNotification"), object: nil, userInfo: ["message": messageModel])
                    NotificationCenter.default.post(notification)
                }
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
    
    func joinRooms(room_ids : [String]) {
        let dict : [String : Any] = [ "room_ids" : room_ids]
        socket.emit("joinRooms", dict)
        
    }
    

    
    func sendMessage(to_room_id: String , sender_id : Int, message: String) {
        let dict : [String : Any?] = [ "room_id" : to_room_id,
                                      "message" : message,
                                      "sender_id" : sender_id,

        ]
        socket.emit("message", dict)
    }
    
    func sharePost(to_user_ids: [Int], sender_id : Int, post : Post) {
        let dict : [String : Any?] = [ "sender_id" : sender_id,
                                       "receive_ids" : to_user_ids,
                                      "shared_post_id" : post.PostID,
        ]
        
        socket.emit("sharePostByMessage", dict)
    }
    
    func shareRestaurant(to_user_ids : [Int], sender_id : Int, restaurant : Restaurant) {
        let dict : [String : Any?] = [ "sender_id" : sender_id,
                                       "receive_ids" : to_user_ids,
                                       "shared_restaurant_id" : restaurant.restaurantID,
        ]
        socket.emit("shareRestaurantByMessage", dict)
    }
    
    func shareUser(to_user_ids : [Int], sender_id : Int, user : User) {
        let dict : [String : Any?] = [ "sender_id" : sender_id,
                                       "receive_ids" : to_user_ids,
                                       "shared_user_id" : user.user_id,
        ]
        socket.emit("shareUserByMessage", dict)
    }
    
    
}

