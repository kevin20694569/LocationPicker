
import UIKit
import PhotosUI
class EditUserImageTableCell : UITableViewCell {
    var targetImage : UIImage!
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard let result = results.first else {
            return
           
        }
        
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self)   { (data, error) in
                if let error = error {
                    print("image失敗 \(error.localizedDescription)" )
                }
                
                if var image = data as? UIImage {
                    if let fixedImage = image.fixImageOrientation(inputImage: image) {
                        image =  fixedImage
                        DispatchQueue.main.async {
                            UIView.transition(with: self.userImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                self.userImageView.image = image
                            }) { bool in
                                self.delegate?.saveButtonEnableToggle(true)
                                
                            }
                           
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    var replaceButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    var userImageView : UIImageView! = UIImageView()
    
    weak var delegate : EditUserProfileCellDelegate?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
        imageViewSetup()
        buttonSetup()
        targetSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func targetSetup() {
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(showPhotoSelectController ( _ :)  ))
        self.userImageView.addGestureRecognizer(imageGesture)
        userImageView.isUserInteractionEnabled = true
        
        self.replaceButton.addTarget(self, action: #selector(showPhotoSelectController), for: .touchUpInside)
    }
    
    @objc func showPhotoSelectController( _ gesture : UITapGestureRecognizer ) {
        guard let delegate = delegate else {
            return
        }
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.selection = .default
        configuration.preferredAssetRepresentationMode = .current
        let phppicker = PHPickerViewController(configuration: configuration)
        phppicker.delegate = self
        phppicker.modalPresentationStyle = .pageSheet
        delegate.present(phppicker, animated: true)
    }
    
    @objc func dismiss() {
        delegate?.dismiss(animated: true)
    }
    
    func configure(profile : UserProfile) {
        if let image = profile.user.image {
            self.userImageView.image = image
        } else {
            Task {
                if let image = try? await profile.user.imageURL?.getImageFromURL() {
                    userImageView.image = image
                    profile.user.image = image
                }
            }
        }
        
    }
    
    func buttonSetup() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration.init(font: .weightSystemSizeFont(systemFontStyle: .body, weight: .bold)))
        config.baseBackgroundColor = .tintOrange
        config.baseForegroundColor = .white
        self.replaceButton.configuration = config
        replaceButton.clipsToBounds = true
        replaceButton.animatedEnable = false
    }
    
    func layoutSetup() {
        self.contentView.addSubview(userImageView)
        self.contentView.addSubview(replaceButton)
        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            self.userImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 1)
        ])
        layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            replaceButton.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: -userImageView.bounds.height / 4),
            replaceButton.trailingAnchor.constraint(equalToSystemSpacingAfter: userImageView.trailingAnchor, multiplier: -userImageView.bounds.width / 4),
            replaceButton.heightAnchor.constraint(equalTo: userImageView.heightAnchor, multiplier: 0.3),
            replaceButton.widthAnchor.constraint(equalTo: replaceButton.heightAnchor)
        ])
    }
    
    
    func imageViewSetup() {
        userImageView.clipsToBounds = true

        userImageView.backgroundColor = .gray
        userImageView.contentMode = .scaleAspectFill
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        replaceButton.layer.cornerRadius = replaceButton.bounds.height / 2
    }
    
    
}

extension EditUserImageTableCell : PHPickerViewControllerDelegate {
    
}

