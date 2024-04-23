import Alamofire
import UIKit

final class UserManager {
    let ip = APIKey.IP
    static let shared : UserManager = UserManager()
    private init() { }
    lazy var API = self.ip + "/users"
    
}

final class UserAccountManager {
    let ip = APIKey.IP
    static let shared : UserAccountManager = UserAccountManager()
    private init() { }
    lazy var API = self.ip + "/useraccount"
    
    
    func updateUserAccount(user_id : String, name : String?, email : String?, password : String?, userImage : UIImage?) async throws -> User {
        do {
            let urlstring = API + "/\(user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            let parameters: [String: Any?] = [
                "name" : name,
                "email" : email,
                "password" : password
            ]
            let multipartFormData = MultipartFormData()
            let jsonEncoder = JSONEncoder()
            
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
            jsonEncoder.outputFormatting = .prettyPrinted
            if let userImage = userImage {
                let data = try Media.compressImage(image: userImage)
                multipartFormData.append(data, withName: "userimage",fileName: UUID().uuidString, mimeType: "image/jpeg")
            }
           
            
            let data = try await withUnsafeThrowingContinuation{ (continuation : UnsafeContinuation<Data, Error>) in

                AF.upload(multipartFormData: multipartFormData, to: url, method: .put, headers: .default).response { response in
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            continuation.resume(returning: data)
                            return
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error )
                        return
                    }
                    continuation.resume(throwing: UserAPIError.Usererror)
                }
            }
            
            let decoder = JSONDecoder()
            
            let json = try decoder.decode(UserJson.self, from: data)
            let user = User(userJson: json)
            return user
            
        } catch {
            throw error
        }
    }
}










