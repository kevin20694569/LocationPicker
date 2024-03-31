import Foundation
struct GoogleMapLocationResultsJson : Codable {
    var results : [GoogleMapLocationJsonModel]?
    var next_page_token : String?
    
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
        case next_page_token = "next_page_token"
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decode([GoogleMapLocationJsonModel].self, forKey: .results)
        self.next_page_token = try? container.decode(String.self, forKey: .next_page_token)
    }
    
}

struct GoogleMapLocationJsonModel : Codable {
    var name : String?
    var formatted_address : String?
    var place_id : String?
    var vicinity : String?
    
    var geometry : GoogleMapLocationGeometryModel?
    
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case formatted_address = "formatted_address"
        case place_id = "place_id"
        case vicinity = "vicinity"
        case geometry = "geometry"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.formatted_address = try container.decodeIfPresent(String.self, forKey: .formatted_address)
        self.vicinity = try container.decodeIfPresent(String.self, forKey: .vicinity)
        self.place_id = try container.decodeIfPresent(String.self, forKey: .place_id)
        self.geometry = try container.decodeIfPresent(GoogleMapLocationGeometryModel.self, forKey: .geometry)
    }
    
    
    
}

struct GoogleMapLocationGeometryModel : Codable {
    var location : GoogleMapLocationLatAndLng?
    
    
    
    enum CodingKeys: String, CodingKey {
        case location = "location"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try container.decodeIfPresent(GoogleMapLocationLatAndLng.self, forKey: .location)
    }
    
}

struct GoogleMapLocationLatAndLng : Codable {
    var lat : Double?
    var lng : Double?
    
    
    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lat = try container.decodeIfPresent(Double.self, forKey: .lat)
        self.lng = try container.decodeIfPresent(Double.self, forKey: .lng)
    }
    
}
