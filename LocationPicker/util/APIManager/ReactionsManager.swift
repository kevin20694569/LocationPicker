import UIKit
import Alamofire
struct Reaction : Equatable {
    var post_id : String!
    var reactionInt : Int? { didSet {
        self.reactionType = ReactionType(rawValue: reactionInt!)
    }}
    var user_id : Int!
    var liked : Bool?
    var updated_at : String?
    var isFriend : Bool?
    var reactionType : ReactionType? { didSet {
        self.reactionInt = reactionType?.rawValue
    }}
    
    init (post_id : String ,reaction : Int? = nil, user_id : Int, liked : Bool = false, update_at : String? = nil, isFriend : Bool? = nil) {
        self.post_id = post_id
        self.reactionInt = reaction
        self.user_id = user_id
        self.liked = liked
        self.isFriend = isFriend
        if let reaction = reaction {
            self.reactionType = ReactionType(rawValue: reaction)
        }
    }
    
    
    
    init(json : ReactionJson) {
        self.post_id = json.post_id
        self.reactionInt = json.reaction
        self.user_id = json.user_id
        self.liked = json.liked
        self.updated_at = json.updated_at
        self.isFriend = json.isFriend
        if let reaction = json.reaction {
            self.reactionType = ReactionType(rawValue: reaction)
        }
    }
    
    
}

enum ReactionType : Int {
    case love, vomit, angry, sad, surprise
    
    var reactionString : String {
        switch self {
        case .love:
            return "love"
        case .vomit:
            return "vomit"
        case .angry:
            return "angry"
        case .sad:
            return "sad"
        case .surprise:
            return "surprise"
        }
    }
    
    var reactionImage : UIImage {
        switch self {
        case .love:
            return UIImage(named: "love")!
        case .vomit:
            return UIImage(named: "vomit")!
        case .angry:
            return UIImage(named: "angry")!
        case .sad:
            return UIImage(named: "sad")!
        case .surprise:
            return UIImage(named: "surprise")!
        }
    }
    
    var emojiString : String {
        switch self {
        case .love:
            return "😍"
        case .vomit:
            return "🤮"
        case .angry:
            return "😡"
        case .sad:
            return "😥"
        case .surprise:
            return "😮"
        }
    }
    
    var reactionTag : Int {
        switch self {
        case .love:
            return 0
        case .vomit:
            return 1
        case .angry:
            return 2
        case .sad:
            return 3
        case .surprise:
            return 4
        }
    }
    
    
}

struct ReactionJson : Codable {
    var post_id : String?
    var reaction : Int?
    var user_id : Int?
    var liked : Bool?
    var updated_at : String?
    var isFriend : Bool?
    
    enum CodingKeys: String, CodingKey {
        case post_id  = "post_id"
        case reaction = "reaction"
        case user_id  = "user_id"
        case liked = "liked"
        case updated_at  = "updated_at"
        case isFriend  = "isFriend"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.post_id = try container.decodeIfPresent(String.self, forKey: .post_id)
        self.reaction = try container.decodeIfPresent(Int.self, forKey: .reaction)
        self.user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
        self.liked = try container.decodeIfPresent(Bool.self, forKey: .liked)
        self.updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
        self.isFriend = try container.decodeIfPresent(Bool.self, forKey: .isFriend)
    }

}




class ReactionsManager {
    let ip = APIKey.IP
    static let shared = ReactionsManager()
    lazy var API = ip + "/reactions"
    
    func postReactionToPost(post_id : String, user_id : Int ,reaction : Int? = nil, liked : Bool? = false) async throws   {
        do {
            
            let urlstring = API + "/post/\(post_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: Any?] = [
                "user_id": user_id,
                "reaction" : reaction,
                "liked" : liked
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
            let code = try await withUnsafeThrowingContinuation{ continuation in
                AF.request(request).responseDecodable(of: String.self) { response in
                    // 处理服务器响应
                    if let code = response.response?.statusCode {
                        continuation.resume(returning: code)
                    } else {
                        
                        continuation.resume(throwing: ReactionsAPIError.postReactionFailError )
                    }
                }
            }
            if 200...299 ~= code {
                return
            } else {
                throw ReactionsAPIError.postReactionFailError
            }
        } catch  {
            throw error
        }
    }
    
    func getUserFriendsReactionsFromUserID(post_id : String) async throws -> [Reaction]  {
        do {
            let urlstring = API + "/\(post_id)"
            
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw  APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 2.0
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let reactionsJson = try decoder.decode([ReactionJson].self, from: data)
            let reactions = reactionsJson.map { json in
                return Reaction(json: json)
            }
            return reactions
        } catch  {
            throw error
        }
    }
}
