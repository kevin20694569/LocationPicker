import UIKit

class StaticImageViewCollectionCell : ImageViewCollectionCell, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    weak var mediaCellDelegate : MediaTableCellDelegate!
    
    @objc func IntoLargePost(_ gesture : UILongPressGestureRecognizer) {
        if gesture.state == .began {
            mediaCellDelegate.presentWholePageMediaViewController(post: nil)
        }
    }
    
    override func configure(media: Media) {
        super.configure(media: media)
        let gesture = {
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(IntoLargePost (_ :)))
            longTapGesture.minimumPressDuration = 0.5
            return longTapGesture
        }()
        self.contentView.addGestureRecognizer(gesture)
        contentView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
}

class NewPostImageViewCollectionCell : ImageViewCollectionCell, UITextFieldDelegate, UIGestureRecognizerDelegate, NewPostCellDelegate {
    
    var titledelegate : PhotoPostViewControllerDelegate!
    
    var descriptionTextfield : RoundedTextField! { didSet {
        descriptionTextfield.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextfield.backgroundColor = .black
        descriptionTextfield.layer.opacity = 0.3
        descriptionTextfield.clipsToBounds = true
        descriptionTextfield.layer.cornerRadius = 10
        descriptionTextfield.isUserInteractionEnabled = true
        descriptionTextfield.delegate = self
        descriptionTextfield.placeholder = "品項標題..."
        descriptionTextfield.textColor = .white
        descriptionTextfield.returnKeyType = .done
        descriptionTextfield.adjustsFontSizeToFitWidth = true
    }}
    
    var mediaTableViewDelegate : MediaTableCellDelegate!
    
    @objc func IntoLargePost(_ gesture : UILongPressGestureRecognizer) {
        if gesture.state == .began {
            mediaTableViewDelegate.presentWholePageMediaViewController(post: nil)
        }
    }
    
    override func configure(media: Media) {
        
        super.configure(media: media)
        if descriptionTextfield == nil {
            descriptionTextfield = RoundedTextField()
            imageView.addSubview(descriptionTextfield)
        }
        self.imageView.layer.borderWidth = 0
        descriptionTextfield.text = media.title
        descriptionTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        descriptionTextfield.backgroundColor = .black
        NSLayoutConstraint.activate([
            descriptionTextfield.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            descriptionTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100),
            descriptionTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            descriptionTextfield.heightAnchor.constraint(greaterThanOrEqualToConstant: contentView.bounds.height / 11)
        ])
        let gesture = {
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(IntoLargePost (_ :)))
            longTapGesture.minimumPressDuration = 0.5
            return longTapGesture
        }()
        
        self.contentView.addGestureRecognizer(gesture)
        contentView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        if descriptionTextfield == nil {
            descriptionTextfield = RoundedTextField()
            contentView.addSubview(descriptionTextfield)
        }
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let newText = textField.text {
            titledelegate.changeMediaTitle(title: newText)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.endEditing(true)
    }

    
    
}


