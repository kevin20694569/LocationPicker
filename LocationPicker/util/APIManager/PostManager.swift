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
        } catch  {
            print(error)
            if error is PostError {
                
            } else {
                PresentErrorMessageManager.shared.presentErrorMessage(error: error)
            }
            throw error
        }
    }
    
    func uploadPostTask(post_title : String? = nil, post_content : String? = nil, medias : [Media]!, user_id: String, placemodel : Restaurant, grade : Double?) async throws {
        let urlString = API
        guard let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.URLnotFound(urlString)
        }
        
        guard let placeID = placemodel.ID,
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
                "title" : post_title,
                "content" : post_content,
                "user_id" : user_id,
                "media_titles" : post_itemtitles,
                "restaurant_id" : placeID,
                "socket_id" : socket_id,
                "grade" : grade
            ]
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            for (key, value) in parameters {
                if let string = value as? String {
                    if let data = string.data(using: .utf8) {
                        multipartFormData.append(data, withName: key, mimeType: "application/json")
                    }
                    continue
                }
                if let value = value as? any Encodable {
                    if let data = try? jsonEncoder.encode(value) {
                        multipartFormData.append(data, withName: key, mimeType: "application/json")
                    }
                }
            }
            
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
    
    func getUserPostsByID(user_id : String, date : String) async throws -> [Post] {
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
    
    func getFriendsNearLocationPosts(user_id: String ,distance: Double) async throws -> [Post] {
        do {
            let urlstring = API + "/nearlocation/friendsbynearlocation?latitude=\(latitude)&longitude=\(longitude)&distance=\(distance)&request_user_id=\(Constant.user_id)"
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
    
    func getFriendsPostsByCreatedTime(user_id: String ,date: String) async throws -> [Post] {
        do {
            let urlstring = API + "/friendsbyordertime?latitude=\(latitude)&longitude=\(longitude)&date=\(date)&request_user_id=\(Constant.user_id)"
            
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
    
    func getPostDetail(post_id : String, request_user_id: String ) async throws -> Post {
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
    
    
    func updatePostDetail(post_id : String, title : String?, content : String?, grade : Double?, medias : [Media]) async throws  {
        var mediasTextValid = false
        var mediaTitleArray : [String?] = []
        for media in medias {
            mediaTitleArray.append(media.title)
            if media.title != nil {
                mediasTextValid = true
            } else {
                media.title = nil
            }
        }
        guard title != nil || content != nil || grade != nil || mediasTextValid else {
            return
        }
        do {
            let urlstring = API + "/\(post_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            let encoder = JSONEncoder()
           
            var req = URLRequest(url: url)
            req.httpMethod = "PUT"
            let body = updatePostDetailRequestBody(title: title, content: content, grade: grade, mediatitles: mediaTitleArray)
            let bodyData = try? encoder.encode(body)
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = bodyData
            let (_, res) = try await URLSession.shared.data(for: req)
            if let res = res as? HTTPURLResponse {
                if 200...299 ~= res.statusCode  {
                    print("updatePost成功")
                } else {
                    throw PostError.UpdatePostError
                }
            }
        } catch {
            throw PostError.UpdatePostError
        }
        
        struct updatePostDetailRequestBody : Encodable {
            var title : String?
            var content : String?
            var grade : Double?
            var mediatitles : [String?]?
        }
        
    }
    
    func deletePost(post_id : String) async throws {
        do {
            let urlstring = API + "/\(post_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "DELETE"
            let (data, res) = try await URLSession.shared.data(for: req)
            if let res = res as? HTTPURLResponse {
                if 200...299 ~= res.statusCode  {
                    print("deletePost成功")
                } else {
                    throw PostError.UpdatePostError
                }
            }
        } catch {
            throw PostError.UpdatePostError
        }
    }
    
    
    
}
