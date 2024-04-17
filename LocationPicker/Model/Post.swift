import UIKit
import AVFoundation
import AVKit

class Post : Hashable, Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id : String!
    var timestamp : String!
    var distance : Double?
    var media : [Media]! = []
    var postTitle : String?
    var postContent : String?
    var grade : Double?
    
    var likedTotal : Int! = 0
    var lovedTotal : Int! = 0
    var vomitedTotal : Int! = 0
    var angryTotal : Int! = 0
    var sadTotal : Int! = 0
    var surpriseTotal : Int! = 0
    var liked: Bool = false
    
    var CurrentIndex : Int! = 0
    
    var selfReaction : Reaction?
    var publicReactions : [Reaction]?
    
    var restaurant : Restaurant?
    
    var user : User?
    
    
    enum PostInfoKey {
        static let user = "user"
        static let mediaFileURL = "mediaFileURL"
        static let RestaurantName = "RestaurantName"
        static let RestaurantAddress = "RestaurantAddress"
        static let UserPhoto = "UserPhoto"
        static let likeTotal = "likeTotal"
        static let timestamp = "timestamp"
    }
    init() { }
    
    init(postId : String, username : String?, restanrantname: String?, restaurantaddress: String?, mediacontents: [Media], timestamp : String, distance : Double?, RestaurantID : String, userID : String, content : String? , title : String?, selfReaction : Reaction?, publicReactions : [Reaction]?, liked : Bool?, likedTotal : Int, lovedTotal : Int?, vomitedTotal : Int?, angryTotal : Int?, sadTotal : Int?, surpriseTotal : Int?, grade : Double?) {
        self.id = postId
        self.liked = liked ?? false
        self.media = mediacontents
        self.timestamp = timestamp
        self.distance = distance ?? 0
        self.postTitle = title
        self.postContent = content
        self.selfReaction = selfReaction
        self.publicReactions = publicReactions
        self.likedTotal = likedTotal
        self.lovedTotal = lovedTotal
        self.vomitedTotal  = vomitedTotal
        self.angryTotal = angryTotal
        self.sadTotal = sadTotal
        self.surpriseTotal = surpriseTotal
        self.grade = grade
    }
    
    
    
    convenience init(postJson: PostJson) {
        
        let post_title = postJson.postDetail?.title
        let post_content = postJson.postDetail?.content
        let post_id = postJson.postDetail?.id
        let created_at = (postJson.postDetail?.created_at!)!
        let restaurant_id = (postJson.postDetail?.restaurant_id!)!
        let user_id = (postJson.postDetail?.user_id!)!
        let grade : Double? = postJson.postDetail?.grade
        let user_name = postJson.user?.name
        let restaurant_name = postJson.restaurant?.name
        let restaurant_address = postJson.restaurant?.address?.formattedAddress()
        let distance = postJson.postDetail?.distance
        
        let liked = postJson.selfReaction?.liked
        
        
        var selfReaction : Reaction?
        var publicReactions : [Reaction]?
        
        let likedTotal : Int! = postJson.postDetail?.reactionsCount.likedTotal
        let lovedTotal : Int! = postJson.postDetail?.reactionsCount.lovedTotal
        let vomitedTotal : Int! = postJson.postDetail?.reactionsCount.vomitedTotal
        let angryTotal : Int! = postJson.postDetail?.reactionsCount.angryTotal
        let sadTotal : Int! = postJson.postDetail?.reactionsCount.sadTotal
        let surpriseTotal : Int! = postJson.postDetail?.reactionsCount.surpriseTotal
        
        
        if let selfReactionJson = postJson.selfReaction {
            selfReaction = Reaction(json: selfReactionJson)
        }
        if let publicReactionsJson = postJson.publicReactoinsJson {
            publicReactionsJson.forEach() { reactionJson in
                publicReactions?.append( Reaction(json: reactionJson))
            }
        }
        let mediaContents : [Media] = test(mediajsonArray: postJson.postDetail!.media!)
        
        func test(mediajsonArray : [mediaJSON] ) -> [Media] {
            var mediaArray : [Media] = []
            for mediaJson in mediajsonArray {
                
                if let url = URL(string: mediaJson.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    switch url.pathExtension {
                    case "jpg", "png":
                        if let image = CacheManager.shared.getFromCache(key: url.absoluteString) as? UIImage {
                            let cachedMedia = Media(title: mediaJson.title, DownloadURL: url, image: image)
                            mediaArray.append(cachedMedia)
                        } else {
                            let media = Media(title:mediaJson.title, DownloadURL: url)
                            mediaArray.append(media)
                        }
                    case "mp4", "MP4" :
                        mediaArray.append(Media(title: mediaJson.title, DownloadURL: url, isImage: false))
                    default:
                        mediaArray.append(Media())
                    }
                }
            }
            return mediaArray
        }
        
        self.init(postId: post_id!, username: user_name, restanrantname: restaurant_name, restaurantaddress: restaurant_address, mediacontents: mediaContents, timestamp: created_at, distance: distance, RestaurantID: restaurant_id, userID: user_id, content: post_content, title: post_title, selfReaction: selfReaction, publicReactions: publicReactions, liked : liked, likedTotal: likedTotal, lovedTotal: lovedTotal, vomitedTotal: vomitedTotal, angryTotal: angryTotal, sadTotal: sadTotal, surpriseTotal: surpriseTotal, grade : grade )
        if let restaurantJson = postJson.restaurant {
            
            self.restaurant = Restaurant(json: restaurantJson)
        }
        if let user = postJson.user {
            self.user = User(userJson: user)
        }
    }
    
    
    init(restaurant : Restaurant? ,  like: Bool! = false, currentIndex: Int = 0 , Media : [Media] , user : User, postTitle : String? = nil, postContent : String? = nil, grade : Double? = nil) {
        self.id = UUID().uuidString
        self.restaurant = restaurant
        self.liked = like
        self.CurrentIndex = currentIndex
        self.media = Media
        self.user = user
        self.postTitle = postTitle
        self.postContent = postContent
        self.grade = grade
    }
    
    init(postDetailJson : PostDetailJson, restaurant : Restaurant?,  Media : [Media] , user : User) {
        self.id = UUID().uuidString
        self.restaurant = restaurant
        self.media = Media
        self.user = user
    }
    
    
    
    static var localPostsExamples : [Post] =   {
        var array : [Post] = []
        Restaurant.localExamples.enumerated().forEach { (i, restaurant) in
            let post = Post(restaurant: restaurant, Media: Media.localExampleMedias[i], user: User.examples[i], postTitle: restaurant.name + "Title Here", postContent: restaurant.Address + "Content Here", grade: nil )
            array.append(post)
        }
        return array
    }()
    
    
    
    var shouldPostReaction : Bool! = false {
        didSet {
            cacelTimer()
            if shouldPostReaction {
                startTimer()
            }
        }
    }
    
    var postReactionRequestTimer : DispatchSourceTimer?
    
    func startTimer() {
        postReactionRequestTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        postReactionRequestTimer?.schedule(deadline: .now() + 1)
        postReactionRequestTimer?.setEventHandler() { [self] in
            if self.shouldPostReaction {
                self.postReaction()
            }
        }
        postReactionRequestTimer?.resume()
    }
    
    func cacelTimer() {
        postReactionRequestTimer?.cancel()
        postReactionRequestTimer = nil
    }
    
    var lastReactionInDataBase : Reaction?
    
    func initNewReaction(reactionTag : Int?, liked : Bool? ) {
        
        self.cacelTimer()
        let liked = liked ?? lastReactionInDataBase?.liked
        let reactionInt : Int?  = reactionTag
        var reaction : Reaction?
        
        reaction = Reaction(post_id: id, reaction: reactionInt ,  user_id: Constant.user_id, liked: liked ?? false , update_at: nil, isFriend: nil)
        self.selfReaction = reaction
        self.shouldPostReaction = true
    }
    
    private func postReaction() {
        guard let reaction = self.selfReaction else {
            return
        }
        Task { [weak self ] in
            guard let self = self else {
                return
            }
            if lastReactionInDataBase?.reactionInt != reaction.reactionInt || lastReactionInDataBase?.liked != reaction.liked {
                
                self.cacelTimer()
                do {
                    try await ReactionsManager.shared.postReactionToPost(post_id: reaction.post_id, user_id: reaction.user_id , reaction: reaction.reactionInt, liked: reaction.liked! )
                    lastReactionInDataBase = reaction
                } catch {
                    print(error )
                }
                self.shouldPostReaction = false
            }
        }
    }
    
    deinit {
        postReaction()
    }
    
}
