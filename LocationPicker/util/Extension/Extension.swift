import UIKit
import MapKit
import AVFoundation
import AVKit

extension UISlider {
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.inset(by: UIEdgeInsets(top: 20, left:20, bottom: 20, right: 20) )
        return expandedBounds.contains(point)
    }
}

extension Double {
    
    func milesTransform() -> String {
        if self < 1000 {
            return String(format: "%.0f 公尺", self)
        } else {
            let kilometers = self / 1000
            return String(format: "%.1f 公里", kilometers)
        }
    }
}




extension UIImage {
    func detectImageOrientation() -> UIImageView.ContentMode {
        if self.size.width / self.size.height > 0.8 {
            return .scaleAspectFit
        } else if self.size.width < self.size.height {
            return .scaleAspectFill
        } else {
            return .scaleAspectFill
        }
    }
    
    func compressImage() throws -> Data {
        if let imageData = self.jpegData(compressionQuality: 0.7) {
            return imageData
        }
        throw CompressError.compressImageFail
    }
}





extension URL {
    static func urlIsImage(url : URL) throws -> Bool {
        switch url.pathExtension {
        case "jpg", "png":
            return true
        case "mp4", "MP4", "MOV", "mov" :
            return false
        default :
            throw GetImageError.URLExtensionError
        }
    }
    
    func generateThumbnail() async throws -> UIImage {
        let asset = AVURLAsset(url: self)
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 1) 
        do {
            let cachedURLString = self.lastPathComponent.replacingOccurrences(of: "." + self.pathExtension, with: "")
            if let cachedImage = CacheManager.shared.getFromCache(key: cachedURLString) as? UIImage {
                return cachedImage
            }
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            CacheManager.shared.cache(object: thumbnail, key: cachedURLString)
            return thumbnail
        } catch {
            return UIImage()
        }
    }
    func getImageFromURL() async throws -> UIImage {
        do {
            let cachedURLString = self.lastPathComponent.replacingOccurrences(of: "." + self.pathExtension, with: "")
            if let cachedImage = CacheManager.shared.getFromCache(key: cachedURLString) as? UIImage {
                return cachedImage
            }
            var imageResult : UIImage!
            let isImage = try URL.urlIsImage(url: self)
            
            if isImage {
                let (data, _) = try await URLSession.shared.data(from: self)
                
                guard let image = UIImage(data: data) else {
                    return UIImage()
                }
                
                imageResult = image
            } else {
                imageResult = try await self.generateThumbnail()
            }
            CacheManager.shared.cache(object: imageResult, key: cachedURLString)
            return imageResult
        } catch {
            print("下載Media image失敗", error)
            return UIImage(systemName: "pencil.circle.fill")!
        }
    }
    
    
    func detectVideoOrientation() -> AVLayerVideoGravity {
        let asset = AVAsset(url: self)
        let track = asset.tracks(withMediaType: AVMediaType.video).first
        if let track = track {
            let transform = track.preferredTransform
            let videoSize = track.naturalSize
            let aspectRatio = videoSize.width / videoSize.height
            let videoOrientation = UIImage.Orientation(transform: transform)
            let aspectRatioThreshold: CGFloat = 1.0
            
            if videoOrientation == .up || videoOrientation == .down {
                if aspectRatio > aspectRatioThreshold {
                    return .resizeAspect
                } else {
                    return .resizeAspectFill
                }
            } else {
                return .resizeAspect
            }
            
            if transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0 {
                return .resizeAspectFill
            } else if transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0 {
                return .resizeAspectFill
            } else if transform.a == 1 && transform.b == 0 && transform.c == 0 && transform.d == 1 {
                return .resizeAspect
            } else if transform.a == -1 && transform.b == 0 && transform.c == 0 && transform.d == -1 {
                return .resizeAspect
            }
            
        }
        return AVLayerVideoGravity.resizeAspect
    }
}

extension UIImage.Orientation {
    init(transform: CGAffineTransform) {
        let angle = atan2(transform.b, transform.a)
        let degrees = angle * CGFloat(180) / CGFloat.pi
        switch degrees {
        case 0:
            self = .up
        case 90:
            self = .right
        case -90:
            self = .left
        case 180:
            self = .down
        default:
            self = .up
        }
        
    }
}

extension AVAsset {
    func detectVideoOrientation() -> AVLayerVideoGravity {
        let track = self.tracks(withMediaType: AVMediaType.video).first
        if let track = track {
            let transform = track.preferredTransform
            if transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0 {
                return AVLayerVideoGravity.resizeAspectFill
            } else if transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0 {
                return AVLayerVideoGravity.resizeAspectFill
            } else if transform.a == 1 && transform.b == 0 && transform.c == 0 && transform.d == 1 {
                return AVLayerVideoGravity.resizeAspect
            } else if transform.a == -1 && transform.b == 0 && transform.c == 0 && transform.d == -1 {
                return AVLayerVideoGravity.resizeAspect
            }
        }
        
        return AVLayerVideoGravity.resizeAspect
    }
}

extension MKMapRect {
    
    init(Rectwidth : CGFloat, Rectheight : CGFloat, mappoint : MKMapPoint, moveditance : Double) {
        self = MKMapRect(x: mappoint.x - Rectwidth / 2, y: mappoint.y - Rectheight / 2 + moveditance + UIApplication.shared.statusBarFrame.height , width: Rectwidth, height: Rectheight)
    }
}


extension Date {
    
    
    func timeAgoFromDate() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1 // 限制显示的最大单位为两个
        formatter.calendar?.locale = Locale(identifier: "zh_TW")
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: self, to: now)
        
        guard let timeAgoString = formatter.string(from: components) else {
            return "剛剛"
        }
        
        return timeAgoString + "前"
    }
}

extension Character {
    var isChinese: Bool {
        let scalar = String(self)
        let range = UnicodeScalar(0x4E00)!...UnicodeScalar(0x9FA5)!
        return scalar.unicodeScalars.allSatisfy { range.contains($0) }
    }
}


extension String {
    func timeAgoFromString() -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: self) else {
            print(self)
            print("timeAgoFromString 失敗")
            return nil
        }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar?.locale = Locale(identifier: "zh_TW")
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: date, to: now)
        if components.year! == 0 && components.month! == 0 && components.hour! == 0 && components.minute! == 0 {
            if components.second! < 5 {
                return "剛剛"
            }
        }

        
        guard let timeAgoString = formatter.string(from: components)
        else {
            return "剛剛"
        }
        
        return timeAgoString + "前"
    }
    
    func timeAgeFromStringOrDateString() ->  String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: self) else {
            print(self)
            print("timeAgoFromString 失敗")
            return nil
        }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar?.locale = Locale(identifier: "zh_TW")
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: date, to: now)
        if let weeks = components.weekOfMonth, weeks >= 1 {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "MMMM d EEE" // "April 4 Mon."
            
            let formattedDate = outputDateFormatter.string(from: date)
            return formattedDate
        }
        if components.year! == 0 && components.month! == 0 && components.hour! == 0 && components.minute! == 0 {
            if components.second! < 5 {
                return "剛剛"
            }
        }

        
        guard let timeAgoString = formatter.string(from: components)
        else {
            return "剛剛"
        }
        
        return timeAgoString + "前"
        
    }
    
    var halfCount : Int {
        var characterCount = 0
        for char in self {
            if char.isChinese {
                characterCount += 2
            } else {
                characterCount += 1
            }
        }
        return characterCount
    }
    
    func isValidEmail() -> Bool {
        // 定义电子邮件地址的正则表达式
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        // 创建 NSPredicate 对象，并使用正则表达式初始化
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        // 调用 evaluate(with:) 方法来检查字符串是否匹配正则表达式
        return emailPredicate.evaluate(with: self)
    }
    
    
    
}

extension AVPlayer {
    func captureCurrentFrame() async -> UIImage? {
        guard let currentItem = self.currentItem else {
            return nil
        }
        let generator = AVAssetImageGenerator(asset: currentItem.asset)
        generator.appliesPreferredTrackTransform = true
        
        let currentTime = self.currentTime()
        let time = CMTime(seconds: CMTimeGetSeconds(currentTime), preferredTimescale: 600)
        guard let (cgimage, _ ) = try? await generator.image(at: time) else { return nil }
        let uiImage = UIImage(cgImage: cgimage)
        return uiImage
    }
    
    func captureSnapshot() -> UIImage? {
        let playerOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
        self.currentItem?.add(playerOutput)
        
        if let imageBuffer = playerOutput.copyPixelBuffer(forItemTime: (self.currentItem?.currentTime())! , itemTimeForDisplay: nil) {
            let ciimage = CIImage(cvImageBuffer: imageBuffer, options: nil)
            let uiimage = UIImage(ciImage: ciimage)
            return uiimage
        }
        return nil
    }
}

extension UIFont {
    static func weightSystemSizeFont(systemFontStyle : UIFont.TextStyle, weight : UIFont.Weight) -> UIFont {
        let bodyFont = UIFont.preferredFont(forTextStyle: systemFontStyle)
        return UIFont.systemFont(ofSize: bodyFont.pointSize, weight: weight)
    }
    
    func calculateHeight(text: String, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: self],
                                            context: nil)
        return boundingBox.height
    }
    
}

extension UIVisualEffectView  {
    
    convenience init(frame : CGRect, style : UIBlurEffect.Style ) {
            self.init(frame: frame)
            self.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: style)
            self.effect = blurEffect
            self.frame = frame
        }

    
}

extension UIBlurEffect.Style {
    static var userInterfaceStyle : UIBlurEffect.Style {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .systemUltraThinMaterialDark
        }
        return .systemUltraThinMaterialLight
    }

    
}




extension UIImage {
    func scale(newWidth: CGFloat) -> UIImage {
        // 確認所給定的寬度與⽬前的不同
        if self.size.width == newWidth {
            return self
        }
        // 計算縮放因⼦
        let scaleFactor = newWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func withOrientation(_ orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: orientation)
    }
    
    func fixImageOrientation(inputImage: UIImage) -> UIImage? {
        guard let cgImage = inputImage.cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(inputImage.size, false, inputImage.scale)
        inputImage.draw(in: CGRect(origin: .zero, size: inputImage.size))
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return fixedImage
    }
    
}



extension Media {
    
    static func compress(inputMedias : [Media]) async throws -> [(Media, Data?)] {
        
        do {
            
            var results : [(Media, Data?)] = .init(repeating: (Media(), nil), count: inputMedias.count)
            
            var mediaMap : [String : Int] = [ :]
            var unEncodedURLsArray : [URL] = []
            //var videos : [LightCompressor.Video] = []
            
            //    let config = LightCompressor.Video.Configuration(quality: .very_high)
            for (index, media) in inputMedias.enumerated() {
                if let image = media.image {
                    results[index] = (media, try Media.compressImage(image: image))
                    mediaMap[media.DonwloadURL.absoluteString] = index
                } else {
                    results[index] = (media, nil)
                    mediaMap[media.DonwloadURL.absoluteString] = index
                    unEncodedURLsArray.append(media.DonwloadURL)
                }
            }
            
            let encodedResults = try await Media.startEncodeToMP4(inputURLs: unEncodedURLsArray )
            
            for (index , result) in encodedResults.enumerated() {
                let resultsIndex = mediaMap[result!.0!.absoluteString]
                results[resultsIndex!].1 = try Data(contentsOf: result!.1!)
                let media = results[index].0
                media.DonwloadURL = result!.1
                /* let lastPathComponent = media.DonwloadURL.lastPathComponent
                 let newLastPathComponent = "compressed_" + lastPathComponent
                 let outputURL = media.DonwloadURL.deletingLastPathComponent().appendingPathComponent(newLastPathComponent)
                 let video = LightCompressor.Video(source: media.DonwloadURL, destination: outputURL, configuration: config)
                 videos.append(video)
                 videoMap[outputURL.absoluteString] = index*/
            }
            // lightCompressor轉完會曝光 無解
            /*  let videoCompressor = LightCompressor()
             
             
             let _: [URL]? = try await withCheckedThrowingContinuation { continuation in
             _ = videoCompressor.compressVideo(videos: videos, progressQueue: .global(qos: .background),
             progressHandler: { progress in
             
             // print("\(String(format: "%.0f", progress.fractionCompleted * 100))%")
             // Handle progress- "\(String(format: "%.0f", progress.fractionCompleted * 100))%"
             }, completion: { result in
             do {
             switch result {
             
             case .onSuccess(let index, let path):
             
             
             let indexInResults = videoMap[path.absoluteString]
             print("index : \(index) ,URL : \(path.absoluteString)")
             results[indexInResults!].1 = try Data(contentsOf: path, options: .alwaysMapped)
             print("onSuccess")
             case .onStart:
             print("onStart")
             
             case .onFailure(_, let error):
             continuation.resume(throwing: error)
             print("onFailure")
             case .onCancelled:
             print("onCancelled")
             }
             
             if case .onSuccess(videos.count - 1, _) = result {
             continuation.resume(returning: nil)
             }
             } catch {
             continuation.resume(throwing: error)
             }
             
             })
             
             }
             return results*/
            return results
        } catch {
            throw error
        }
    }
    
    static func startEncodeToMP4(inputURLs : [URL]) async throws -> [(URL?, URL?)?] {
        do {
            return try await withThrowingTaskGroup(of: (index: Int, inputURL : URL?,  outputURL: URL?).self, returning: [(URL?, URL?)?].self) { group in
                for (i, inputURL) in inputURLs.enumerated() {
                    group.addTask {
                        do {
                            let urlAsset = AVURLAsset(url: inputURL, options: nil)
                            
                            guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: String(AVAssetExportPresetHighestQuality)) else {
                                throw CompressError.compressVideoFail
                            }
                            
                            let lastPathComponent = inputURL.lastPathComponent
                            let newLastPathComponent = "encoded_" + (inputURL.deletingPathExtension().lastPathComponent) + ".mp4"
                            let outputURL = inputURL.deletingLastPathComponent().appendingPathComponent(newLastPathComponent)
                            exportSession.outputURL =  outputURL
                            
                            
                            exportSession.outputFileType = AVFileType.mp4
                            exportSession.shouldOptimizeForNetworkUse = true
                            
                            
                            
                            await exportSession.export()
                            
                            switch exportSession.status {
                            case .completed:
                                if let outputURL = exportSession.outputURL {
                                    return (i, inputURL, outputURL)
                                }
                                let userInfo = ["failedURLString" : inputURL.absoluteString ]
                                let error = NSError(domain: "Export OutpurURLError", code: -1, userInfo: userInfo)
                                
                                throw error
                            case .failed:
                                let userInfo = ["failedURLString" : inputURL.absoluteString ]
                                let error = NSError(domain: "Export session failed", code: -1, userInfo: userInfo)
                                
                                throw error
                            default:
                                let userInfo = ["failedURLString" : inputURL.absoluteString ]
                                
                                let error = NSError(domain: "Export session encountered an unexpected error", code: -1, userInfo: userInfo)
                                throw error
                            }
                            
                        } catch {
                            return (-1, nil, nil)
                        }
                    }
                }
                
                var outputURLs: [(URL?, URL?)?] = Array.init(repeating: nil , count: inputURLs.count)
                var isError : Bool = false
                for try await result in group {
                    if isError {
                        if let url = result.outputURL {
                            try FileManager.default.removeItem(at: url)
                        }
                        continue
                    }
                    if result.index == -1 {
                        isError = true
                        if let url = result.outputURL {
                            try FileManager.default.removeItem(at: url)
                        }
                        continue
                    }
                    outputURLs[result.index] = (result.inputURL , result.outputURL)
                }
                
                return outputURLs
            }
        } catch {
            throw error
        }
    }
    
    
    
    func compressVideo(inputURL: URL) async throws -> AVAssetExportSession {
        let scale: Double = 0.7
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let videoTrack = urlAsset.tracks(withMediaType: .video).first else {
            throw CompressError.compressVideoFail
        }
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.width * scale, height: videoTrack.naturalSize.height * scale)
        
        // Set up video composition instructions
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: urlAsset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 24)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetPassthrough) else {
            throw CompressError.compressVideoFail
        }
        let lastPathComponent = inputURL.lastPathComponent
        let newLastPathComponent = "compressed_" + lastPathComponent
        let outputURL = inputURL.deletingLastPathComponent().appendingPathComponent(newLastPathComponent)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        
        
        return try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: exportSession)
                case .failed:
                    let error = NSError(domain: "Export session failed", code: -1, userInfo: nil)
                    continuation.resume(throwing: error)
                default:
                    let error = NSError(domain: "Export session encountered an unexpected error", code: -1, userInfo: nil)
                    continuation.resume(throwing: error)
                }
            }
            
        }
    }
    
    
    static func compressImage(image : UIImage) throws -> Data {
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            return imageData
        }
        throw CompressError.compressImageFail
    }
}


extension Date {
    static func isCurrentTimeInRange(startTime: String, endTime: String) -> Bool {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        let currentDate = dateFormatter.string(from: date)
        
        if endTime <= startTime {
            return currentDate >= startTime
        }
        return currentDate >= startTime && currentDate <= endTime
    }
}


extension String {
    func formattedAddress() -> String? {
        if let range = self.range(of: "灣") {
            let formattedAddress = String(self[range.upperBound...])
            return formattedAddress// 输出：三重區龍濱路239號
        } else {
            return self
        }
    }
}

extension UIColor {
    
    
    static let systemBackground = backgroundPrimary
    
    static let backgroundPrimary = UIColor { (trait) -> UIColor in
        switch (trait.userInterfaceStyle, trait.userInterfaceLevel) {
        case (.dark, _):
            // For this color set you can set "Appearances" to "none"
            return .black
        default:
            // This color set has light and dark colors specified
            return .white
        }
    }
    
    static let secondaryLabelColor = UIColor { (trait) -> UIColor in
        switch (trait.userInterfaceStyle, trait.userInterfaceLevel) {
        case (.dark, _):

            return .lightGray
        default:

            return .darkGray
        }
    }
    
    static let secondaryBackgroundColor = UIColor  { (trait) -> UIColor in
        switch (trait.userInterfaceStyle, trait.userInterfaceLevel) {
        case (.dark, _):
                
            return .darkGray
        default:

            return .systemGray3
        }
    }
    
    static let gradeStarYellow = UIColor  { (trait) -> UIColor in
        switch (trait.userInterfaceStyle, trait.userInterfaceLevel) {
        case (.dark, _):
            
            return .systemYellow
        default:
            
            return .systemYellow
        }
    }
    
    

}

extension String {
    mutating func trimTrailingWhitespace() {
       
        self = self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension UITextView {
    
    func numberOfLines() -> Int {
        guard let font = self.font else {
            return 0
        }
        
        let textSize = CGSize(width: self.bounds.width - self.contentInset.left - self.contentInset.right, height: CGFloat(MAXFLOAT))
        let textHeight = self.sizeThatFits(textSize).height
        let lineHeight = font.lineHeight
        
        return Int(textHeight / lineHeight)
    }
    
}












