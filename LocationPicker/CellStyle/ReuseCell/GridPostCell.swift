import UIKit
import AVFoundation

class GridPostCell: UICollectionViewCell {
    
    
    let cornerRadius = Constant.GridPostCellRadius
    
    var imageView : UIImageView!
    
    var currentPost : Post!
    
    var medias : [Media]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondaryBackgroundColor
        imageView.layer.cornerRadius = cornerRadius
        contentView.addSubview(imageView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondaryBackgroundColor
        imageView.layer.cornerRadius = cornerRadius
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondaryBackgroundColor
        imageView.layer.cornerRadius = cornerRadius
        contentView.addSubview(imageView)
    }
    
    func configureImageView(post : Post , image : UIImage?, mediaIndex : Int) {
        self.currentPost = post
        self.medias = post.media
        layoutIfNeeded()
        if let image = image {
            self.imageView.image = image
            self.imageView.contentMode =  .scaleAspectFill
            
            return
        }
        let media = medias[mediaIndex]
        if let image = media.image {
            self.imageView.image = image
            self.imageView.contentMode =   .scaleAspectFill
            return
        }
        if media.isImage {
            Task(priority : .background) {
                let image = await media.DonwloadURL.getImageFromImageURL()
                media.image = image
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
        } else {
            Task(priority : .background)  {
                let image = await media.DonwloadURL.generateThumbnail()
                media.image = image
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
        }

        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.imageView.frame = bounds
    }
    

    
    func changeImage(changeToIndex : Int) {
        configureImageView(post: currentPost, image: nil, mediaIndex: changeToIndex)
    }
    
    func reloadCollectionCell() {
        self.isHidden = false
        self.contentView.isHidden = false
        self.imageView.isHidden = false
        self.imageView.layer.cornerRadius = self.cornerRadius 
        self.configureImageView(post: currentPost, image: nil, mediaIndex: currentPost.CurrentIndex)
        self.contentView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.currentPost = nil
        self.medias = nil
        self.imageView.image = nil
    }
}
