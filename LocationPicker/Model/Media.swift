import AVFoundation
import UIKit

class Media : Hashable, Equatable {
    
    static let mediaTitleCountLimit : Int = 16
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.DonwloadURL == rhs.DonwloadURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(DonwloadURL)
    }
    
    var title : String?
    var DonwloadURL : URL!
    var image : UIImage?
    var player : AVPlayer?
    var isImage : Bool! = true
    
    var titleCountValid : Bool {
        let valid = ( self.title?.halfCount ?? 0 ) <= Self.mediaTitleCountLimit
        return valid
    }
    
    var playerRestartObserverToken : Any?
    
    
    init(title : String? = nil ,DownloadURL: URL, isImage : Bool? = true) {
        self.DonwloadURL = DownloadURL
        self.title = title
        self.isImage = isImage
        if let isImage = try? URL.urlIsImage(url: DownloadURL) {
            self.isImage = isImage
        }
        if !self.isImage {
            self.player = AVPlayer(url: DownloadURL)
        }
    }
    
    init(title : String? = nil ,DownloadURL: URL, image: UIImage) {
        self.title = title
        self.image = image
        self.isImage = true
        self.DonwloadURL = DownloadURL
        self.player = nil
    }
    
    init(title : String? = nil, player : AVPlayer) {
        let array = ["a.mp4", "b.mp4", "c.mp4", "d.mp4", "e.mp4", "f.mp4", "g.mp4", "h.mp4"]
        self.title = title
        self.DonwloadURL = URL(string: array.randomElement()!)
        self.player = player
        self.isImage = false
    }
    
    init() {
        self.image = nil
        self.DonwloadURL = URL(string: ".jpg")
        self.player = nil
    }
    
    convenience init?(json : mediaJSON) {
        if let url = URL(string: json.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            switch url.pathExtension {
            case "jpg", "png":
                if let image = CacheManager.shared.getFromCache(key: url.absoluteString) as? UIImage {
                    self.init(title: json.title, DownloadURL: url, image: image)
                    return
                } else {
                    self.init(title: json.title, DownloadURL: url)
                    return
                }
            case "mp4", "MP4" :
                self.init(title: json.title, DownloadURL: url, isImage: false)
                return
            default:
                break
            }
        }
        return nil
    }

    
    
    static var randomMediasExamples : [Media] = [
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true) ,
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true),
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true),
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true),
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true),
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true),
        Media(DownloadURL: URL(string: "https://picsum.photos/1920/1080")!, isImage: true)
    ]
    
    static var mediaurl : [URL] = [Bundle.main.url(forResource: "video5", withExtension: "mp4")!, Bundle.main.url(forResource: "video2", withExtension: "mp4")!]
    
    static var LocalMediaExamples : [Media] = [
        Media(title: "url", player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
        Media(player: AVPlayer(url: mediaurl.randomElement()!)),
    ]
    
    
    
    static func getImage(fileName : String) -> UIImage? {
        let image = UIImage(named: fileName)
        return image
    }
    
    static func getPlayer(fileURLString : String) -> AVPlayer? {
        let url = Bundle.main.url(forResource: fileURLString , withExtension: "mp4")
        let player = AVPlayer(url: url!)
        return player
    }
    func removePlayerRestartObserverToken() {
        if let token = self.playerRestartObserverToken {
            
            NotificationCenter.default.removeObserver(token)
        }
        playerRestartObserverToken = nil
    }
    
    
    
    deinit {
        removePlayerRestartObserverToken()
    }
    
    static func getSnapShot(media : Media) async -> UIImage? {
        return try? await media.DonwloadURL.getImageFromURL()
    }
    
    static let title : String = "titlekjdwldjwdqjlqw"
}

extension Media {
    static var localExampleMedias : [ [Media] ] = [
        
        
        [
            Media(title: nil, player: Media.getPlayer(fileURLString: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_1")!),
            Media(title: "mnvxdfrxrsx", DownloadURL: URL(string: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_2")! , image: Media.getImage(fileName: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_2")!),
            Media(title: "bmnbmbmnbviuygbjuy", DownloadURL: URL(string: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_3")! , image: Media.getImage(fileName: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_3")!),
            Media(title: "jmbkjn,m", DownloadURL: URL(string: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_4")! , image: Media.getImage(fileName: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_4")!),
            Media(title: "j", DownloadURL: URL(string: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_5")! , image: Media.getImage(fileName: "ChIJcZwPjtGdbjQRi5Crxhf2cyk_5")!)
        ],
        [

            Media(title: title, DownloadURL: URL(string: "ChIJzX6ag3qVbjQRrXIrYvoydGk_2")! , image: Media.getImage(fileName: "ChIJzX6ag3qVbjQRrXIrYvoydGk_1")!),
            Media(title: title, DownloadURL: URL(string: "ChIJzX6ag3qVbjQRrXIrYvoydGk_3")! , image: Media.getImage(fileName: "ChIJzX6ag3qVbjQRrXIrYvoydGk_2")!),
            Media(title: title, player: Media.getPlayer(fileURLString: "ChIJzX6ag3qVbjQRrXIrYvoydGk_3")!),
            Media(title: title, DownloadURL: URL(string: "ChIJzX6ag3qVbjQRrXIrYvoydGk_4")! , image: Media.getImage(fileName: "ChIJzX6ag3qVbjQRrXIrYvoydGk_4")!),
            Media(title: title, DownloadURL: URL(string: "ChIJzX6ag3qVbjQRrXIrYvoydGk_5")! , image: Media.getImage(fileName: "ChIJzX6ag3qVbjQRrXIrYvoydGk_5")!)
        ],
        
        [
            Media(title: title, DownloadURL: URL(string: "ChIJ6VOxmM2rQjQRfiQ6tvqm-3I_1")! , image: Media.getImage(fileName: "ChIJ6VOxmM2rQjQRfiQ6tvqm-3I_1")!),
        ],
        
        
        [
            Media(title: title, DownloadURL: URL(string: "ChIJiyGm7cupQjQRvh4ipZERQcw_1")! , image: Media.getImage(fileName: "ChIJiyGm7cupQjQRvh4ipZERQcw_1")!),
        Media(title: title, DownloadURL: URL(string: "ChIJiyGm7cupQjQRvh4ipZERQcw_2")! , image: Media.getImage(fileName: "ChIJiyGm7cupQjQRvh4ipZERQcw_2")!),
        ],
        [
            
            Media(title: title, DownloadURL: URL(string: "ChIJ0zybGjupQjQRyNW1QbZilHA_1")! , image: Media.getImage(fileName: "ChIJ0zybGjupQjQRyNW1QbZilHA_1")!),
        ],
        
        
        
        [
            Media(title: title, DownloadURL: URL(string: "ChIJAwKQ5kqUbjQRpjKKDhyUEX4_1")! , image: Media.getImage(fileName: "ChIJAwKQ5kqUbjQRpjKKDhyUEX4_1")!),
        ],
        
        
        
        
        [
            Media(title: title, DownloadURL: URL(string: "ChIJpVwNjmerQjQReyXPmpQn7Cg_1")! , image: Media.getImage(fileName: "ChIJpVwNjmerQjQReyXPmpQn7Cg_1")!),
        ],
        
        
        
        [
         Media(title: title, DownloadURL: URL(string: "ChIJIeU7y5QjaDQR63dFe9KvspU_1")! , image: Media.getImage(fileName: "ChIJIeU7y5QjaDQR63dFe9KvspU_1")!),
        ],
        [
         Media(title: title, DownloadURL: URL(string: "ChIJX7_HEwCpQjQRpQGoSKkxVWE_1")! , image: Media.getImage(fileName: "ChIJX7_HEwCpQjQRpQGoSKkxVWE_1")!),
        ],
        [
        Media(title: title, DownloadURL: URL(string: "ChIJe2XGItM1BhQRtMUBxFrKia4_1")! , image: Media.getImage(fileName: "ChIJe2XGItM1BhQRtMUBxFrKia4_1")!)
        ]
    ]
    
}

struct mediaJSON : Codable {
    var url : String!
    var resource_id : String!
    var title : String?

    
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case resource_id = "resource_id"
        case title = "title"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.resource_id = try container.decodeIfPresent(String.self, forKey: .resource_id)
    }
}
