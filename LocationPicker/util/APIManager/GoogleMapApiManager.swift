import UIKit
import GoogleMaps

class GoogleMapApiManager {
    static let shared = GoogleMapApiManager()
    let apiKey = Constant.GoogleMapAPIKey
    let textSearchJsonURL = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
    let nearbySeatchJsonURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    var location : (lat : Double, lng: Double )! {
        let coordinate = LocationManager.shared.currentLocation?.coordinate
        return (coordinate?.latitude, coordinate?.longitude) as! (lat: Double, lng: Double)
    }
    
    func fetchGoogleMapLocation(query : String) async throws -> ([Restaurant], String?) {
        let urlstring = textSearchJsonURL + "query=\(query)&location=\(location.lat),\(location.lng)&type=restautant&language=zh-TW&key=\(apiKey)"
        do {
            guard (urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil),
                  let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try decoder.decode(GoogleMapLocationResultsJson.self, from: data)
            guard let results = decodedData.results else {
                throw GoogleMapAPIError.resultsIsEmpty
            }
            let array = await initLocationModelsWithTaskGroup(results: results)
            return (array, decodedData.next_page_token ?? nil)
        } catch {
            throw error
        }
    }
    
    
    func fetchGoogleMapLocationNearbySeatch() async throws -> ([Restaurant], String?) {
        do {
            let urlstring = nearbySeatchJsonURL + "location=\(location.lat),\(location.lng)&radius=1500&language=zh-TW&type=restaurant&key=\(apiKey)"
            guard (urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil),
                  let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try decoder.decode(GoogleMapLocationResultsJson.self, from: data)
            guard let results = decodedData.results else {
                throw GoogleMapAPIError.resultsIsEmpty
            }
            let array = await initLocationModelsWithTaskGroup(results: results)
            return (array, decodedData.next_page_token ?? nil)
        } catch {
            throw error
        }
    }
    
    func fetchGoogleMapLocationNearbyToken(token : String) async throws -> ([Restaurant], String?) {
        let urlstring = textSearchJsonURL + "pagetoken=\(token)&key=\(apiKey)"
        do {
            guard urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil,
                  let url = URL(string: urlstring) else {
                throw APIError.URLnotFound(urlstring)
            }
            let decoder = JSONDecoder()
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try decoder.decode(GoogleMapLocationResultsJson.self, from: data)
            guard let results = decodedData.results else {
                throw GoogleMapAPIError.resultsIsEmpty
            }
            let array = await initLocationModelsWithTaskGroup(results: results)
            return (array, decodedData.next_page_token ?? nil)
        } catch {
            throw error
        }
    }
}

extension GoogleMapApiManager {
    
    private func initLocationModelsWithTaskGroup(results: [GoogleMapLocationJsonModel]) async -> [Restaurant] {
        return await withTaskGroup(of: (index: Int, result : Restaurant).self , returning: [Restaurant].self) {
            group in
            for (i,result) in results.enumerated() {
                group.addTask() {
                    return (i, Restaurant(json: result))
                }
            }
            var array : [Restaurant] = .init(repeating: Restaurant() , count: results.count)
            for await result in group {
                array[result.index] = result.result
            }
            return array
        }
    }
}
