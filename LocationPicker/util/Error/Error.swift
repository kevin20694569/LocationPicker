import Foundation

enum APIError : LocalizedError {
    case URLnotFound(_ urlString : String)
    var errorDescription : String? {
        switch self  {
        case .URLnotFound(let url) :
            return "URL錯誤"
        }
    }
}

enum PostError  : LocalizedError {
    case PostNotFound
    case DownloadPostFail
    case uploadDetailError
    
    var errorDescription: String? {
        switch self {
        case .PostNotFound :
            return "找不到相關Post"
        case .DownloadPostFail :
            return "Posts下載失敗"
        case .uploadDetailError :
            return "上傳問題"
        }
    }
}

enum RestaurantError : LocalizedError {
    case NotFoundRestaurant
    var errorDescription : String? {
        switch self {
        case .NotFoundRestaurant :
            return "搜尋不到此餐廳"
        }
    }
}

enum GoogleMapAPIError : LocalizedError {
    case resultsIsEmpty
    var errorDescription : String? {
        switch self {
        case .resultsIsEmpty :
            return "GoogleMapAPI回傳結果為0"
        }
    }
}

enum UserAPIError : LocalizedError {
    case Usererror
    var errorDescription : String? {
        switch self {
        case .Usererror :
            return "GoogleMapAPI回傳結果為0"
        }
    }
}

enum FriendsAPIError : LocalizedError {
    case acceptFriendRequestError
    case sendFriendRequestError
    
    var errorDescription: String? {
        switch self {
        case .acceptFriendRequestError:
            return "接受朋友邀請失敗"
        case .sendFriendRequestError :
            return "寄送朋友邀請失敗"
        }
    }
}

enum ReactionsAPIError : LocalizedError {
    case postReactionFailError
    
    var errorDescription: String? {
        switch self {
        case .postReactionFailError :
            return "發送reaction失敗"
        }
    }
}

enum CompressError : LocalizedError {
    case compressVideoFail
    case compressImageFail
    
    var errorDescription: String? {
        switch self {
        case .compressImageFail :
            return "compressImageFail"
        case .compressVideoFail : 
            return "compressVideoFail"
        }
    }
}

enum MessageError : LocalizedError {
    case noMoreMessages
    
    var errorDescription: String? {
        switch self {
        case .noMoreMessages :
            return "noMoreMessages"
        }
    }
}
