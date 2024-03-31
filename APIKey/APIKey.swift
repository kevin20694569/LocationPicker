import Foundation

import UniformTypeIdentifiers

enum APIKey {
    struct ApiKeyData: Decodable {
        let googleMapAPIKey: String
        let IP : String
    }
    
    static var googleMapAPIKey = {
        guard let fileURL = Bundle.main.url(forResource: "\(Self.self)", withExtension: UTType.propertyList.preferredFilenameExtension) else {
            fatalError("Couldn't find file APIKey.plist")
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            fatalError("Couldn't read data from APIKey.plist")
        }
        guard let apiKey = try? PropertyListDecoder().decode(ApiKeyData.self, from: data).googleMapAPIKey else {
            fatalError("Couldn't find key apiKey")
        }
        return apiKey
    }()
    static var IP = {
        guard let fileURL = Bundle.main.url(forResource: "\(Self.self)", withExtension: UTType.propertyList.preferredFilenameExtension) else {
            fatalError("Couldn't find file APIKey.plist")
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            fatalError("Couldn't read data from APIKey.plist")
        }
        guard let apiKey = try? PropertyListDecoder().decode(ApiKeyData.self, from: data).IP   else {
            fatalError("Couldn't find key apiKey")
        }
        return apiKey
    }()
}
