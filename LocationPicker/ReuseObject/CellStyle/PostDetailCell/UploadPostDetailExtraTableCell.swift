import UIKit

class UploadPostDetailTextViewTableCell : UITableViewCell {
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var textView : UITextView!
    
    var textViewDelegate : UITextViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutTextView()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.delegate = textViewDelegate
    }
    
    func layoutTextView() {
        let verOffset : CGFloat = 2
        let horOffset : CGFloat = 6
        let textViewFont = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
        titleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
        textView.font = textViewFont
        textView.textColor = .label
        textView.contentMode = .center
        textView.textAlignment = .left
        textView.contentInset = UIEdgeInsets(top: verOffset, left: horOffset, bottom: verOffset, right: horOffset)
        textView.backgroundColor = .secondaryBackgroundColor
        textView.layer.cornerRadius = 12
        textView.clipsToBounds = true
        textView.showsVerticalScrollIndicator = false


    }
    
}

class UploadPostDetailTitleCell : UploadPostDetailTextViewTableCell {
    
    @IBOutlet var limitCharacterLabel : UILabel! { didSet {
        limitCharacterLabel.isHidden = true
    }}
    @IBOutlet var limitCharacterImageView : UIImageView! { didSet {
        limitCharacterImageView.isHidden = true
    }}
    
    var limitViews : [UIView]! {
        return [limitCharacterLabel, limitCharacterImageView]
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "標題"
    }
    
    
    
    override func layoutTextView() {
        super.layoutTextView()
        self.textView.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: UIFont.weightSystemSizeFont(systemFontStyle: .title1, weight: .medium).lineHeight * 2 + self.textView.contentInset.top  + self.textView.contentInset.bottom )
        ])
    }

}

class UploadPostDetailContentCell : UploadPostDetailTextViewTableCell {
    
    var forbiddenView : UIView!
    
    var forbiddenLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutForbiddenView()
        textView.isEditable = false
        titleLabel.text = "內文"
    }
    
    override func layoutTextView() {
        super.layoutTextView()
        textView.textAlignment = .justified
        self.textView.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .medium)
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .medium).lineHeight * 3 + self.textView.contentInset.top  + self.textView.contentInset.bottom)
        ])
    }
    
    func layoutForbiddenView() {
        forbiddenView = UIView(frame: self.textView.bounds)
        forbiddenView.isUserInteractionEnabled = true
        forbiddenView.clipsToBounds = true
        forbiddenView.layer.cornerRadius = self.textView.layer.cornerRadius
        self.textView.addSubview(forbiddenView)
        forbiddenView.backgroundColor = .systemBackground
        forbiddenView.alpha = 0.6
        forbiddenLabel = UILabel()
        forbiddenLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
        forbiddenLabel.text = "如要編輯內文，標題不得為空"
        forbiddenLabel.textColor = .secondaryLabelColor
        forbiddenLabel.textAlignment = .center
        forbiddenLabel.frame = CGRect(origin: .zero, size: CGSize(width: forbiddenView.frame.width * 0.8, height: forbiddenView.frame.height * 0.5))
       

        self.forbiddenView.addSubview(forbiddenLabel)
        forbiddenLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forbiddenLabel.centerXAnchor.constraint(equalTo: self.textView.centerXAnchor),
            forbiddenLabel.centerYAnchor.constraint(equalTo: self.textView.centerYAnchor   ),

        ])

    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        forbiddenView.frame = self.textView.bounds
    }
        
    
    
    
}

class UploadPostDetailExtraTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel?
    
    @IBOutlet var logoImageView : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let image = UIImage(systemName: "chevron.forward", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .secondaryLabelColor
        
        self.accessoryView = imageView
        titleLabel.adjustsFontSizeToFitWidth = true
        addressLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func configure(image: UIImage, text : String, address : String?) {
        logoImageView.image = image
        titleLabel.text = text
        if let address = address {
            addressLabel?.text = address
            addressLabel?.isHidden = false
        } else {
            addressLabel?.isHidden = true
        }
    }
    
    
}


class UploadPostDetailGradeCell : UITableViewCell {
    
    @IBOutlet var gradeToggleButton : RoundedButton!
    
    var currentGrade : Double?
    
    var commentStatus : Bool = false
    
    let buttonFont = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
    
    let starImageFont = UIFont.weightSystemSizeFont(systemFontStyle: .largeTitle, weight: .medium)
    
    var lastGrade : Double! = 5
    
    @IBOutlet var starStackView : UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .secondaryBackgroundColor, tintColor: .secondaryLabelColor  , font: buttonFont)

        gradeToggleButton.addTarget(self, action: #selector(gradeToggle(_ : )), for: .touchUpInside)
        gradeToggleButton.scaleTargets?.append(gradeToggleButton) 
        gradeToggleButton.isEnabled = true
        gradeToggleButton.animatedEnable = true

        if var config = gradeToggleButton.configuration {
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            gradeToggleButton.configuration = config
        }
       
        for (index, starView) in starStackView.arrangedSubviews.enumerated() {
            if let starImageView = starView as? UIImageView {
                starImageView.tag = index
                let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(fillStar( _ : )))
                doubleGesture.numberOfTapsRequired = 2
                let gesture = UITapGestureRecognizer(target: self, action: #selector(fillStar ( _ : )))
                gesture.numberOfTapsRequired = 1
                gesture.cancelsTouchesInView = false
        
                starImageView.addGestureRecognizer(doubleGesture)
                starImageView.addGestureRecognizer(gesture)
                starImageView.isUserInteractionEnabled = true
                let image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.secondaryLabelColor, renderingMode: .alwaysOriginal)
                starImageView.image = image
            }
        }
    }

    @objc func gradeToggle(_ button : UIButton) {
        commentStatus.toggle()
        let gradeToggleButton = button as! RoundedButton
        if commentStatus {
            self.currentGrade = lastGrade
            gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .tintColor, tintColor: .white, font: buttonFont)
            let integerPart = Int(lastGrade)
            let decimalPart = lastGrade - Double(integerPart)
            
            for index in 0...integerPart - 1 {
                let starImageView = self.starStackView.arrangedSubviews[index] as! UIImageView
                starImageView.image = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            }
            if lastGrade == 5 {
                return
            }
            let starImageView = self.starStackView.arrangedSubviews[integerPart] as! UIImageView
            if decimalPart == 0 {
                starImageView.image = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            } else {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            }
            let round = Int(round(lastGrade))
            if round == 4 {
                return
            } else {
               
                for index in round...4 {
                    
                    let starImageView = self.starStackView.arrangedSubviews[index] as! UIImageView
                    starImageView.image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
                }
            }

        } else {
            gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .secondaryBackgroundColor , tintColor: .secondaryLabelColor, font: buttonFont)
            self.lastGrade = currentGrade
            self.currentGrade = nil

            self.starStackView.arrangedSubviews.forEach { view in
                if let starImageView = view as? UIImageView {
                    starImageView.image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.secondaryLabelColor, renderingMode: .alwaysOriginal)
                }
            }
            
        }
        
    }
    
    @objc func fillStar(_ gesture : UITapGestureRecognizer) {
        self.commentStatus = true
        gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .tintColor, tintColor: .white, font: UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium))
        if let tag = gesture.view?.tag {
            let fillRange = 0...tag
            var totalGrade : Double = 0.0
            for view in starStackView.arrangedSubviews {
                if let starImageView = view as? UIImageView {
                    if fillRange.contains(starImageView.tag) {
                        if gesture.numberOfTapsRequired == 2 && starImageView.tag == tag  {
                            starImageView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
                            totalGrade += 0.5
                        } else {
                            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
                            totalGrade += 1
                            
                        }
                    } else {
                        starImageView.image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
                        
                    }
                }
            }
            currentGrade = totalGrade
            self.lastGrade = currentGrade
        }
    }
}
