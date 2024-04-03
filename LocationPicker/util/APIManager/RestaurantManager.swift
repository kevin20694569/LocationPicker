import Alamofire
import UIKit

final class RestaurantManager {
    let ip = APIKey.IP
    var distance : Double?
    static let shared : RestaurantManager = RestaurantManager()
    private init() { }
    
    lazy var API = self.ip + "/restaurants"
    func getRestaurantIDasync(restaurantID: String) async throws -> Restaurant? {
        do {
            guard let latitude = LocationManager.shared.currentLocation?.coordinate.latitude,
                  let longitude = LocationManager.shared.currentLocation?.coordinate.longitude else {
                print("拿不到位置")
                throw LocationError.UserLocationNotFound
            }
            let urlstring = API + "/\(restaurantID)?latitude=\(latitude)&longitude=\(longitude)"
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(for: req)
            let result = try decoder.decode(RestaurantJson.self, from: data)
            let restaurant = Restaurant(json: result)
            return restaurant
        } catch {
            throw error
        }
    }
    
    
    
}










