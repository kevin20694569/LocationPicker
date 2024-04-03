import Alamofire
import Foundation

final class PostManager : NSObject {
    let ip = APIKey.IP
    
    let user_id = Constant.user_id
    
    static let shared : PostManager = PostManager()
    
    var latitude : String =  {
        String(LocationManager.shared.currentLocation?.coordinate.latitude ?? 25)
    }()
    var longitude : String = {
        String(LocationManager.shared.currentLocation?.coordinate.longitude ?? 121)
    }()
    
    var friends_Ids : [Int]?
    
    lazy var API = ip + "/posts"
    
    func getPublicNearLocationPosts(distance: Double) async throws -> [Post] {
        
        do {
            let urlstring = API + "/nearlocation?latitude=\(latitude)&longitude=\(longitude)&distance=\(distance)&user_id=\(user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2.0
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let results = try decoder.decode([PostJson].self, from: data)
            guard results.count > 0 else {
                throw PostError.PostNotFound
            }
            var newPosts : [Post] = []
            results.forEach() {
                newPosts.append(Post(postJson: $0))
            }
            return newPosts
        } catch {
            throw error
        }
    }
    
    func uploadPostTask(post_title : String? = nil, post_content : String? = nil, medias : [Media]!, user_id: Int, placemodel : Restaurant, grade : Double?) async throws {
        let urlString = API
        guard let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.URLnotFound(urlString)
        }
        
        guard let placeName = placemodel.name ,
              let placeAddress = placemodel.Address,
              let placeID = placemodel.restaurantID,
              let socket_id = SocketIOManager.shared.socket_id else {
            throw PostError.uploadDetailError
        }
        
        let multipartFormData = MultipartFormData()
        do {
            
            var post_itemtitles: [String] = []
            for media in medias {
                post_itemtitles.append(media.title ?? "")
            }
            let parameters: [String: Any?] = [
                "post_title" : post_title,
                "post_content" : post_content,
                "user_id" : user_id,
                "post_itemtitles" : post_itemtitles,
                "restaurant_name" : placeName,
                "restaurant_address" : placeAddress,
                "restaurant_ID" : placeID,
                "socket_id" : socket_id,
                "grade" : grade
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            multipartFormData.append(jsonData, withName: "json", mimeType: "application/json")
            
            let tupleArray = try await Media.compress(inputMedias: medias)
            for (media, data) in tupleArray {
                if let data = data {
                    if media.isImage {
                        multipartFormData.append(data, withName: "media",fileName: UUID().uuidString, mimeType: "image/jpeg")
                    } else {
                        multipartFormData.append(data, withName: "media",fileName: UUID().uuidString, mimeType: "video/mp4")
                    }
                }
            }
            
            // 在异步任务中构建multipartFormData
            AF.upload(multipartFormData: multipartFormData, to: url, method: .post, headers: .default).responseDecodable(of: String.self ) { response in
                // 处理服务器响应
                switch response.result {
                case .success(let data):
                    print("成功上傳")
                case .failure(let error):
                    print("上傳失敗 Error訊息：", error)
                }
            }
            
        } catch {
            throw error
        }
    }
    
    
    
    
    
    func getRestaurantPostsByID(restaurantID : String, date : String) async throws -> [Post] {
        do {
            let urlstring = API + "/restaurants/\(restaurantID)?date=\(date)&user_id=\(user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let req = try URLRequest(url: url, method: .get)
            let (data, _) = try await URLSession.shared.data(for: req)
            let results = try decoder.decode([PostJson].self, from: data)
            
            var newPosts : [Post] = []
            results.forEach() {
                newPosts.append(Post(postJson: $0))
            }
            return newPosts
        } catch {
            throw PostError.PostNotFound
        }
    }
    
    func getUserPostsByID(user_id : Int, date : String) async throws -> [Post] {
        do {
            let urlstring = API + "/users/\(user_id)?date=\(date)&user_id=\(Constant.user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let req = try URLRequest(url: url, method: .get)
            let (data, _) = try await URLSession.shared.data(for: req)
            let results = try decoder.decode([PostJson].self, from: data)
            var newPosts : [Post] = []
            results.forEach() {
                newPosts.append(Post(postJson: $0))
            }
            return newPosts
        } catch {
            print(error)
            throw PostError.PostNotFound
        }
    }
    
    func getFriendsNearLocationPosts(user_id: Int ,distance: Double) async throws -> [Post] {
        do {
            let urlstring = API + "/nearlocation/friends/\(user_id)?latitude=\(latitude)&longitude=\(longitude)&distance=\(distance)&user_id=\(Constant.user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let req = try URLRequest(url: url, method: .get)
            let (data, _) = try await URLSession.shared.data(for: req)
            let results = try decoder.decode([PostJson].self, from: data)
            var newPosts : [Post] = []
            results.forEach() {
                newPosts.append(Post(postJson: $0))
            }
            return newPosts
        } catch {
            print(error)
            throw PostError.PostNotFound
        }
    }
    
    func getFriendsPostsByCreatedTime(user_id: Int ,date: String) async throws -> [Post] {
        do {
            let urlstring = API + "/friends/\(user_id)?latitude=\(latitude)&longitude=\(longitude)&date=\(date)&user_id=\(Constant.user_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let req = try URLRequest(url: url, method: .get)
            let (data, _) = try await URLSession.shared.data(for: req)
            let results = try decoder.decode([PostJson].self, from: data)
            var newPosts : [Post] = []
            results.forEach() {
                newPosts.append(Post(postJson: $0))
            }
            return newPosts
        } catch {
            print(error)
            throw PostError.PostNotFound
        }
    }
    
    func getPostDetail(post_id : String, request_user_id: Int ) async throws -> Post {
        do {
            let urlstring = API + "/\(post_id)?request_user_id=\(request_user_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let req = try URLRequest(url: url, method: .get)
            let (data, _) = try await URLSession.shared.data(for: req)
            let json = try decoder.decode(PostJson.self, from: data)
            let post = Post(postJson: json)
            return post
        } catch {
            print(error)
            throw PostError.PostNotFound
        }
    }
    
    
    
}
