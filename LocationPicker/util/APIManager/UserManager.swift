import Alamofire
import UIKit

final class UserManager {
    let ip = APIKey.IP
    static let shared : UserManager = UserManager()
    private init() { }
    lazy var API = self.ip + "/users"
    
}

final class UserProfileManager {
    let ip = APIKey.IP
    static let shared : UserProfileManager = UserProfileManager()
    private init() { }
    lazy var API = self.ip + "/users"
    
    func getProfileByID(user_ID: String) async throws -> UserProfile? {
        do {
            let urlstring = API + "/\(user_ID)?request_user_id=\(Constant.user_id)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.timeoutInterval = 2
            req.httpMethod = "GET"
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let json = try decoder.decode(UserProfileJson.self, from: data)

            let userProfile = UserProfile(profileJson: json)
            return userProfile
        } catch {
            throw error
        }
    }
}










