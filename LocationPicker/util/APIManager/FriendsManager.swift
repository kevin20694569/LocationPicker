import UIKit
import Alamofire


class FriendsManager {
    static let shared = FriendsManager()
    let API = Constant.httpIP + "friends/"
    
    func getUserFriendsFromUserID(user_id : Int, Date : String) async throws -> [Friend]  {
        do {
            let urlstring = API + "\(user_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2.0
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let friendsJson = try decoder.decode([FriendJson].self, from: data)
            let friends = friendsJson.map { json in
                return Friend(json: json)
            }
            return friends
        } catch  {
            throw error
        }
    }
    
    func getUserFriendsRequestsFromUserID(user_id : Int, date : String) async throws -> [UserFriendRequest]  {
        do {
            let urlstring = API + "friendrequests/\(user_id)?date=\(date)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2.0
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)

            let requestsJson = try decoder.decode([UserRequestJson].self, from: data)
           let requests = requestsJson.map { json in
                return UserFriendRequest(json: json)
            }
            return requests
        } catch  {
            throw error
        }
    }
    
    func acceptFriendRequestFromRequestID(request_id: Int, accept_user_id : Int) async throws -> Int {
        
        do {
            let urlstring = self.API + "friendships/accept/\(request_id)"
            guard  urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                   let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: Int] = [
                "accept_user_id": accept_user_id,
            ]
            let body = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            req.httpBody = body
            req.timeoutInterval = 2.0
            var (_, res) = try await URLSession.shared.data(for: req)
            let httpRes = res as! HTTPURLResponse
            return httpRes.statusCode
        } catch {
            throw error
        }
    }
    
    func sendBeingFriendRequest(from from_user_id : Int,  to to_user_id : Int)  async throws {
        do {
            let urlstring = API + "friendrequests/"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.timeoutInterval = 2.0
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let request = FriendRequestBody(from_user_id: from_user_id, to_user_id: to_user_id)
            let body = try encoder.encode(request)
            req.httpBody = body
            let (data, res) = try await URLSession.shared.data(for: req)
            if let httpRes = res as? HTTPURLResponse {
                if 200...299 ~= httpRes.statusCode  {
                    return
                }
                throw FriendsAPIError.sendFriendRequestError
            }
        } catch  {
            throw error
        }
    }
    
    
    struct FriendRequestBody : Encodable {
        var from_user_id : Int
        var to_user_id : Int
    }
    
    
}
