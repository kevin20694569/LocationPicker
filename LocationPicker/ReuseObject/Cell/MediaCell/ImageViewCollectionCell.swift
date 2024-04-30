import UIKit


class ImageViewCollectionCell: UICollectionViewCell, MediaCollectionCell {
    var mediaCornerRadius : CGFloat! {
        return Constant.standardCornerRadius
    }
    var imageView : UIImageView! = UIImageView()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func reload(media : Media?) {
        imageView.layer.cornerRadius = mediaCornerRadius
        if let media = media {
            configure(media: media)
        }
        contentView.addSubview(imageView)
        imageView.isHidden = false
        self.isHidden = false
        self.contentView.isHidden = false
        self.layoutIfNeeded()
    }
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageViewSetup()
        contentViewSetup()
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    
    func imageViewSetup() {
        contentView.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .darkGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = mediaCornerRadius
    }
    
    func contentViewSetup() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = mediaCornerRadius
    }
    
    
    func configure(media: Media) {

        if let image = media.image {
            self.imageView.image = image
        } else {
            Task(priority: .low) {
                let image = try await media.DonwloadURL.getImageFromURL()
                media.image = image
                self.imageView.image = image
           }
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






