import Foundation
import UIKit

struct ReactionsCount : Codable {
    var likedTotal : Int! = 0
    var lovedTotal : Int! = 0
    var vomitedTotal : Int! = 0
    var angryTotal : Int! = 0
    var sadTotal : Int! = 0
    var surpriseTotal : Int! = 0
    
    enum CodingKeys : String, CodingKey {
        case likedTotal = "like"
        case lovedTotal = "love"
        case vomitedTotal = "vomit"
        case angryTotal = "angry"
        case sadTotal = "sad"
        case surpriseTotal = "surprise"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.likedTotal = try container.decodeIfPresent(Int.self, forKey: .likedTotal)
        self.lovedTotal = try container.decodeIfPresent(Int.self, forKey: .lovedTotal)
        self.vomitedTotal = try container.decodeIfPresent(Int.self, forKey: .vomitedTotal)
        self.angryTotal = try container.decode(Int.self, forKey: .angryTotal)
        self.sadTotal = try container.decodeIfPresent(Int.self, forKey: .sadTotal)
        self.surpriseTotal = try container.decodeIfPresent(Int.self, forKey: .surpriseTotal)
    }
}

struct PostJson : Codable {
    var postDetail : PostDetailJson?
    var user : UserJson?
    var restaurant : RestaurantJson?
    var selfReaction : ReactionJson?
    
    var publicReactoinsJson : [ReactionJson]?
    
    enum CodingKeys: String, CodingKey {
        case postDetail = "postDetail"
        case user = "user"
        case restaurant = "restaurant"
        case selfReaction = "selfReaction"
        case publicReactoinsJson = "publicReactoinsJson"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postDetail = try container.decodeIfPresent(PostDetailJson.self, forKey: .postDetail)
        self.user = try container.decodeIfPresent(UserJson.self, forKey: .user)
        self.restaurant = try container.decodeIfPresent(RestaurantJson.self, forKey: .restaurant)
        self.selfReaction = try container.decodeIfPresent(ReactionJson.self, forKey: .selfReaction)
        self.publicReactoinsJson = try container.decodeIfPresent([ReactionJson].self, forKey: .publicReactoinsJson)
    }
    
    init(postDetailJson : PostDetailJson?, userJson : UserJson?, restaurantJson : RestaurantJson?, selfReactionJson : ReactionJson?, publicReactoinsJson : [ReactionJson]? ) {
        self.postDetail = postDetailJson
        self.user = userJson
        self.restaurant = restaurantJson
        self.selfReaction = selfReactionJson
        self.publicReactoinsJson = publicReactoinsJson
    }
}



struct PostDetailJson : Codable {
    var post_id : String?
    var post_title : String?
    var post_content : String?
    var media : [mediaJSON]?
    var user_id: Int?
    var restaurant_id : String!
    var created_at : String?
    var distance : Double?
    var reactionsCount : ReactionsCount!
    
    var grade : Double?
    
    
    enum CodingKeys: String, CodingKey {
        case post_id = "post_id"
        case post_title = "post_title"
        case post_content = "post_content"
        case media = "media_data"
        case user_id = "user_id"
        case restaurant_id = "restaurant_id"
        case created_at = "created_at"
        case grade = "grade"
        case reactionsCount = "reactions"
        case distance = "distance"
    }
    
    init(contenttext : String, media : [mediaJSON]!, user_id: Int, restaurant_id : String, restaurantname: String?, restaurantaddress : String?) {
        
        self.post_content = contenttext
        self.media = media
        self.user_id = user_id
        self.restaurant_id = restaurant_id
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.post_id = try container.decodeIfPresent(String.self, forKey: .post_id)
        self.post_title = try container.decodeIfPresent(String.self, forKey: .post_title)
        self.post_content = try container.decodeIfPresent(String.self, forKey: .post_content)
        self.media = try container.decodeIfPresent([mediaJSON].self, forKey: .media)
        self.user_id = try container.decode(Int.self, forKey: .user_id)
        self.restaurant_id = try container.decodeIfPresent(String.self, forKey: .restaurant_id)
        self.created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        self.reactionsCount = try container.decodeIfPresent(ReactionsCount.self, forKey: .reactionsCount)
        self.distance = try container.decodeIfPresent(Double.self, forKey: .distance)
    }
}

struct mediaJSON : Codable {
    var url : String!
    var itemtitle : String? = ""
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case itemtitle = "itemtitle"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.itemtitle = try container.decodeIfPresent(String.self, forKey: .itemtitle)
    }
}
