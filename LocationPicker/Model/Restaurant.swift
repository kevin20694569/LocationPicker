import Foundation
import UIKit
import MapKit

class Restaurant: Hashable, Equatable {
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.ID == rhs.ID
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(ID)
    }
    
    init() { }
    
    var name : String!
    var Address :  String!
    var ID : String!
    
    var imageURL : URL?
    var distance : String?
    var image : UIImage?
    var Posts : [Post]? = []
    var openingDays : OpeningDays?
    
    var posts_count : Int! = 0
    var average_grade : Double?

    var takeout : Bool?
    
    var reservable : Bool?
    var price_level : Int?
    
   var priceString : String? {
       if let price_level = price_level {
           return PriceString(rawValue: price_level)?.priceString
       }
       return nil
    }
    
    enum PriceString : Int {
        case Free ,Inexpensive ,Moderate ,Expensive ,Very_Expensive
        
        var priceString : String {
            switch self {
            case .Free:
                "免費"
            case .Inexpensive:
                "便宜"
            case .Moderate:
                "中等"
            case .Expensive:
                "貴"
            case .Very_Expensive:
                "超貴"
            }
        }
        
        
    }
    var website: String?
    var formatted_phone_number : String?
    
    init(name: String!, Address: String!, restaurantID : String, image : UIImage?) {
        self.name = name
        self.Address = Address
        self.ID = restaurantID
        self.image = image
    }
    
    init(json: RestaurantJson)   {
        self.ID = json.id
        self.name = json.name
        self.Address = json.address?.formattedAddress()
 
        if let str = json.imageurl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: str) {
            
            self.imageURL = url
        }
        if let posts_count = json.posts_count {
            self.posts_count = posts_count
        }
        self.average_grade = json.average_grade
        
        self.openingDays = json.opening_days
        
        self.takeout = json.takeout
        
        self.reservable = json.reservable
        self.price_level = json.price_level
        
        self.website = json.website
        
        self.formatted_phone_number = json.formatted_phone_number
        
    }
    
    init(json : GoogleMapLocationJsonModel) {
        self.name = json.name
        self.Address = json.formatted_address?.formattedAddress() ?? json.vicinity?.formattedAddress()
        self.ID = json.place_id
    }
    
    static var example : Restaurant = Restaurant(name: "雞二拉麵", Address: "台灣台北市大安區文昌街30號", restaurantID: "ChIJ6VOxmM2rQjQRfiQ6tvqm-3I", image: UIImage(named: "ChIJ6VOxmM2rQjQRfiQ6tvqm-3I_1")!)

    static var localExamples : [Restaurant] = [
        Restaurant(name: "有夠鮮-烤蚵吃到飽-東石鮮蚵吃到飽|烤蚵吃到飽|必吃鮮蚵|必吃烤蚵|道地美食|在地推薦餐廳", Address: "嘉義縣東石鄉", restaurantID: "hIJcZwPjtGdbjQRi5Crxhf2cyk", image: UIImage(named: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_2")!),
        Restaurant(name: "這里民宿", Address: "嘉義縣中埔鄉義仁村15鄰田寮仔20-7號", restaurantID: "ChIJzX6ag3qVbjQRrXIrYvoydGk", image: UIImage(named: "ChIJzX6ag3qVbjQRrXIrYvoydGk_1")!),
         
        Restaurant(name: "雞二拉麵", Address: "台灣台北市大安區文昌街30號", restaurantID: "ChIJ6VOxmM2rQjQRfiQ6tvqm-3I", image: UIImage(named: "ChIJ6VOxmM2rQjQRfiQ6tvqm-3I_1")!),
        
        
        Restaurant(name: "スシロー壽司郎 台北林森店", Address: "B1, 欣欣大眾百貨No. 247號林森北路中山區台北市", restaurantID: "ChIJiyGm7cupQjQRvh4ipZERQcw", image: UIImage(named: "ChIJiyGm7cupQjQRvh4ipZERQcw_1")!),

        
        Restaurant(name: "小豬很忙蔬果滷味三重力行店", Address: "新北市三重區力行路二段71-2號", restaurantID: "ChIJ0zybGjupQjQRyNW1QbZilHA", image: UIImage(named: "ChIJ0zybGjupQjQRyNW1QbZilHA_1")!),
        Restaurant(name: "公園老店涼麵", Address: "嘉義市東區維新路36號", restaurantID: "ChIJAwKQ5kqUbjQRpjKKDhyUEX4", image: UIImage(named: "ChIJAwKQ5kqUbjQRpjKKDhyUEX4_1")!),
        Restaurant(name: "吾二酸菜魚", Address: "台北市大安區忠孝東路四段205巷7弄5號", restaurantID: "ChIJpVwNjmerQjQReyXPmpQn7Cg", image: UIImage(named: "ChIJpVwNjmerQjQReyXPmpQn7Cg_1")!),
        
        Restaurant(name: "耘豆養生•麻辣臭豆腐(中壢夜市)", Address: "桃園市中壢區新明路明德路", restaurantID: "ChIJIeU7y5QjaDQR63dFe9KvspU", image: UIImage(named: "ChIJIeU7y5QjaDQR63dFe9KvspU_1")!),
        
        Restaurant(name: "酸研酸魚重慶酸菜魚蘆洲店", Address: "新北市蘆洲區中山二路103號1樓", restaurantID: "ChIJX7_HEwCpQjQRpQGoSKkxVWE", image: UIImage(named: "ChIJX7_HEwCpQjQRpQGoSKkxVWE_1")!),
        
        Restaurant(name: " 興加臭豆腐", Address: "嘉義市東區興業東路191號", restaurantID: "ChIJe2XGItM1BhQRtMUBxFrKia4", image: UIImage(named: "ChIJe2XGItM1BhQRtMUBxFrKia4_1")!),
    ]
    
    
    
    
    
}


struct RestaurantJson: Codable {
    
    var imageurl : String?
    var id : String!
    var name: String?
    var address: String?

    var latitude : Double?
    var longitude : Double?
    var posts_count : Int?
    var average_grade : Double?
    var opening_days : OpeningDays?
    
    var takeout : Bool?
    
    var reservable : Bool?
    var price_level : Int?
    
    var website : String?
    
    var formatted_phone_number : String?
    
    
    enum CodingKeys: String, CodingKey {
        case imageurl = "restaurant_imageurl"
        case id = "id"
        case name = "name"
        case address = "address"
        case latitude  = "latitude"
        case longitude  = "longitude"
        case opening_days = "opening_hours"
        case posts_count = "posts_count"
        case average_grade = "average_grade"
        case takeout = "takeout"
        
        case reservable = "reservable"
        case price_level = "price_level"
        
        case website = "website"
        
        case formatted_phone_number = "formatted_phone_number"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageurl = try container.decodeIfPresent(String.self, forKey: .imageurl)
        self.id = try container.decodeIfPresent(String.self, forKey: .id )
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.opening_days = try container.decodeIfPresent(OpeningDays.self, forKey: .opening_days)
        self.posts_count = try container.decodeIfPresent(Int.self, forKey: .posts_count)
        self.average_grade = try container.decodeIfPresent(Double.self, forKey: .average_grade)
        
        if let intValue = try? container.decode(Int.self, forKey: .takeout) {
            self.takeout = intValue != 0
        } else {
            self.takeout = try container.decode(Bool.self, forKey: .takeout)
        }
        
        self.reservable = try container.decodeIfPresent(Bool.self, forKey: .reservable)
        self.price_level = try container.decodeIfPresent(Int.self, forKey: .price_level)
        
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        
        self.formatted_phone_number = try container.decodeIfPresent(String.self, forKey: .formatted_phone_number)
    }
}

struct OpeningDays : Codable {
    var mon : [OpeningHours]?
    var tues : [OpeningHours]?
    var wed : [OpeningHours]?
    var thur : [OpeningHours]?
    var fri : [OpeningHours]?
    var sat : [OpeningHours]?
    var sun : [OpeningHours]?
    
    enum CodingKeys: String, CodingKey {
        case mon = "mon"
        case tues = "tues"
        case wed = "wed"
        case thur = "thur"
        case fri = "fri"
        case sat = "sat"
        case sun = "sun"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mon = try container.decodeIfPresent([OpeningHours].self, forKey: .mon)
        self.tues = try container.decodeIfPresent([OpeningHours].self, forKey: .tues)
        self.wed = try container.decodeIfPresent([OpeningHours].self, forKey: .wed)
        self.thur = try container.decodeIfPresent([OpeningHours].self, forKey: .thur)
        self.fri = try container.decodeIfPresent([OpeningHours].self, forKey: .fri)
        self.sat = try container.decodeIfPresent([OpeningHours].self, forKey: .sat)
        self.sun = try container.decodeIfPresent([OpeningHours].self, forKey: .sun)
    }
    
    init() {
        
    }
    
    
}

struct OpeningHours : Codable {
    var open : String?
    var close : String?
    
    enum CodingKeys: String, CodingKey {
        case open = "open"
        case close = "close"
    }
    
    init(open: String? = nil, close: String? = nil) {
        self.open = open
        self.close = close
    }
    
    static let example : OpeningHours = OpeningHours(open: nil, close: nil)
}

enum WeekDay : String {
    case sun = "Sunday", mon = "Monday", tues = "Tuesday", wed = "Wednesday", thur = "Thursday", fri = "Friday", sat = "Saturday"
    
    
    var dayString  : String {
        switch self {
            
        case .mon:
            "星期一"
        case .tues:
            "星期二"
        case .wed:
            "星期三"
        case .thur:
            "星期四"
        case .fri:
            "星期五"
        case .sat:
            "星期六"
        case .sun:
            "星期日"
        }
    }
    
    var isToday : Bool {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayString = dateFormatter.string(from: date)
        return rawValue == dayString
    }
    
    static func indexTranslate(index : Int) -> WeekDay? {
        switch index {
        case 0:
            return WeekDay.mon
        case 1:
            return WeekDay.tues
        case 2:
            return WeekDay.wed
        case 3:
            return WeekDay.thur
        case 4:
            return WeekDay.fri
        case 5:
            return WeekDay.sat
        case 6 :
            return WeekDay.sun
        default:
            return nil
        }
    }
    
}

/*struct RestaurantResultJSON : Codable {
 
 var Post_ID : Int!
 var mediaurl : String!
 var created_at : String!
 
 enum CodingKeys : String, CodingKey {
 case Post_ID = "Post_ID"
 case mediaurl = "mediaurl"
 case created_at = "created_at"
 }
 
 init(from decoder: Decoder) throws {
 let container = try decoder.container(keyedBy: CodingKeys.self)
 self.Post_ID = try container.decodeIfPresent(Int.self, forKey: .Post_ID)
 self.mediaurl = try container.decodeIfPresent(String.self, forKey: .mediaurl)
 self.created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
 }
 
 
 }
 
 struct PostPreview : Hashable {
 var Post_ID : Int! = nil
 var image : UIImage!
 var created_at : String! = nil
 }*/
