import UIKit
import Alamofire


class FriendManager {
    let ip = APIKey.IP
    static let shared = FriendManager()
    lazy var API = ip + "/friends"
    
    func getUserFriendsFromUserID(user_id : String, Date : String) async throws -> [Friend]  {
        do {
            let urlstring = API + "/friendships/\(user_id)?request_user_id=\(Constant.user_id)"
            guard  urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                   let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.timeoutInterval = 2.0
            let decoder = JSONDecoder()
            let (data, res) = try await URLSession.shared.data(for: req)
            if let httpRes = res as? HTTPURLResponse {
                if 200...299 ~= httpRes.statusCode  {
                    let json = try decoder.decode([FriendJson].self, from: data)
                    let friends = json.compactMap() {
                        return Friend(json: $0)
                    }
                    return friends
                }
            }
            throw FriendsAPIError.getFriendsError
            
        } catch {
            throw error
        }
    }
    
    func getUserFriendReceiveRequestsFromUserID(user_id : String, date : String) async throws -> [UserFriendRequest]  {
        do {
            let urlstring = API + "/friendrequests/receive-friend-request?request_user_id=\(user_id)&date=\(date)"
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
    
    func getUserFriendSentRequestsFromUserID(user_id : String, date : String) async throws -> [UserFriendRequest]  {
        do {
            let urlstring = API + "/friendrequests/sent-friend-request?request_user_id=\(user_id)&date=\(date)"
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
    
    func acceptFriendRequestFromRequestID(request_id: String, accept_user_id : String) async throws -> Int {
        
        do {
            let urlstring = self.API + "/friendrequests/accept/\(request_id)"
            guard  urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                   let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: String] = [
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
    
    func acceptFriendRequestByEachUserID(accept_user_id: String, sentReqeust_user_id : String) async throws {
        
        do {
            let urlstring = self.API + "/friendships/accept"
            guard  urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                   let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: String] = [
                "accept_user_id": accept_user_id,
                "request_user_id" : sentReqeust_user_id
            ]
            let body = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            req.httpBody = body
            req.timeoutInterval = 2.0
            var (_, res) = try await URLSession.shared.data(for: req)
            let httpRes = res as! HTTPURLResponse
            if 200...299 ~= httpRes.statusCode  {
                return
               // return httpRes.statusCode
            } else {
                throw FriendsAPIError.acceptFriendRequestError
            }

        } catch {
            throw error
        }
    }
    
    func sendFriendRequest(from from_user_id : String,  to to_user_id : String)  async throws {
        do {
            let urlstring = API + "/friendrequests/send"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.timeoutInterval = 2.0
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let request = FriendRequestBody(request_user_id: from_user_id, to_user_id: to_user_id)
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
    
    func cancelFriendRequest(from from_user_id : String, to to_user_id : String) async throws {
        do {
            let urlstring = API + "/friendrequests"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "DELETE"
            req.timeoutInterval = 2.0
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let request = FriendRequestBody(request_user_id: from_user_id, to_user_id: to_user_id)
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
        var request_user_id : String
        var to_user_id : String
    }
    
    
}
