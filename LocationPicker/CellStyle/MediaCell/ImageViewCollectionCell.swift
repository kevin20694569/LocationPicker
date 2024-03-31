import UIKit


class ImageViewCollectionCell: UICollectionViewCell, MediaCollectionCell {
    var cornerRadiusfloat : CGFloat! {
        return Constant.standardCornerRadius
    }
    var imageView : UIImageView!
    var maincellDelegate : MediaTableViewCellDelegate!
    

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.imageView = UIImageView(image: nil)
        self.imageView.contentMode = .scaleAspectFill

        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadiusfloat
        contentView.layer.cornerRadius = cornerRadiusfloat
        
        contentView.addSubview(self.imageView)

        
    }
    
    
    
    
    
    func reload(media : Media?) {
        imageView.layer.cornerRadius = Constant.standardCornerRadius
        if let media = media {
            layoutImageView(media: media)
        }
        contentView.addSubview(imageView)
        imageView.isHidden = false
        self.isHidden = false
        self.contentView.isHidden = false
        
        
    }
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView(image: nil)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadiusfloat
        contentView.layer.cornerRadius = cornerRadiusfloat
        contentView.addSubview(self.imageView!)
        self.imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true

    }
    
    func layoutImageView(media: Media) {

        if let image = media.image {
            self.imageView.image = image
        } else {
            Task(priority: .low) {
                let image = await media.DonwloadURL.getImageFromImageURL()
                media.image = image
                self.imageView.image = image
           }
        }
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        UIView.performWithoutAnimation {
            self.imageView.frame = self.bounds
        }
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
}

class StandardImageViewCollectionCell : ImageViewCollectionCell {
    override var cornerRadiusfloat: CGFloat {
        return 0
    }
    override func layoutImageView(media: Media) {
        super.layoutImageView(media: media)
        self.imageView.layer.cornerRadius = cornerRadiusfloat
        self.layoutIfNeeded()
    }
}




