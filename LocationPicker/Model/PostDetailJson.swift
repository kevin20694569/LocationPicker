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
        case publicReactoinsJson = "publicReactions"
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
    var id : String?
    var title : String?
    var content : String?
    var media : [mediaJSON]?
    var user_id: String?
    var restaurant_id : String!
    var created_at : String?
    var distance : Double?
    var reactionsCount : ReactionsCount!
    
    var grade : Double?
    
    var isdeleted : Bool! = false
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case content = "content"
        case media = "media"
        case user_id = "user_id"
        case restaurant_id = "restaurant_id"
        case created_at = "created_at"
        case grade = "grade"
        case reactionsCount = "reactions"
        case distance = "distance"
        case isdeleted = "isdeleted"
    }
    
    init(contenttext : String, media : [mediaJSON]!, user_id: String, restaurant_id : String, restaurantname: String?, restaurantaddress : String?) {
        
        self.content = contenttext
        self.media = media
        self.user_id = user_id
        self.restaurant_id = restaurant_id
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.media = try container.decodeIfPresent([mediaJSON].self, forKey: .media)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.restaurant_id = try container.decodeIfPresent(String.self, forKey: .restaurant_id)
        self.created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        self.reactionsCount = try container.decodeIfPresent(ReactionsCount.self, forKey: .reactionsCount)
        self.grade = try container.decodeIfPresent(Double.self, forKey: .grade)
        self.distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        self.isdeleted = try? container.decodeIfPresent(Bool.self, forKey: .isdeleted) ?? false
    }
}


