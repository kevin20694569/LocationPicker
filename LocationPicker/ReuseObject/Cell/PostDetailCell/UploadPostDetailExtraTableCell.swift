import UIKit

class UploadPostDetailTextViewTableCell : UITableViewCell {
    var titleLabel : UILabel! = UILabel()
    var textView : UITextView! = UITextView()
    
    var warningStackView : UIStackView! = UIStackView()
    
    var warningImageView : UIImageView! = UIImageView()
    
    var warningLabel : UILabel! = UILabel()

    weak var textViewDelegate : UITextViewDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imageViewSetup()
        textViewSetup()
        stackViewSetup()
        labelSetup()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textView.delegate = textViewDelegate
    }
    
    func textViewSetup() {
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
    
    func labelSetup() {
        warningLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        warningLabel.textColor = .systemRed
    }
    
    func stackViewSetup() {
        [warningImageView, warningLabel].forEach() {
            warningStackView.addArrangedSubview($0)
        }
        warningStackView.spacing = 2
        warningStackView.axis = .horizontal
        warningStackView.alignment = .leading
        warningStackView.distribution = .fill
        warningStackView.isHidden = true
        
    }
    
    func imageViewSetup() {
        warningImageView.tintColor = .systemRed
        warningImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        warningImageView.contentMode = .scaleAspectFit
    }
    
    func initLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(textView)
        contentView.addSubview(warningStackView)
        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            warningStackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            warningStackView.lastBaselineAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        
        ])
    }

}

class UploadPostDetailTitleCell : UploadPostDetailTextViewTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier  )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textViewSetup() {
        super.textViewSetup()
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: UIFont.weightSystemSizeFont(systemFontStyle: .title1, weight: .medium).lineHeight * 2 + self.textView.contentInset.top  + self.textView.contentInset.bottom )
        ])
    }
    
    override func labelSetup() {
        super.labelSetup()
        warningLabel.text = "不得超過20個字元"
       
        titleLabel.text = "標題"
    }
    
    

}

class UploadPostDetailContentCell : UploadPostDetailTextViewTableCell {
    
    var forbiddenView : UIView! = UIView()
    
    var forbiddenLabel : UILabel! = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutForbiddenView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func textViewSetup() {
        super.textViewSetup()
        textView.textAlignment = .justified
        self.textView.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .medium)
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .medium).lineHeight * 3 + self.textView.contentInset.top  + self.textView.contentInset.bottom)
        ])
        textViewEnableEdit(bool: false)
    }
    
    override func labelSetup() {
        super.labelSetup()
        titleLabel.text = "內文"
        
    }
    
    func layoutForbiddenView() {
        forbiddenView.frame = self.textView.bounds
        forbiddenView.isUserInteractionEnabled = true
        forbiddenView.clipsToBounds = true
        forbiddenView.layer.cornerRadius = self.textView.layer.cornerRadius
        textView.addSubview(forbiddenView)
        forbiddenView.backgroundColor = .systemBackground
        forbiddenView.alpha = 0.6
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
    
    func textViewEnableEdit(bool : Bool) {
        forbiddenView.isHidden = bool
        textView.isEditable = bool
    }
        
    
    
    
}

class UploadPostDetailExtraTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel?
    
    @IBOutlet var logoImageView : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryViewSetup()
        labelSetup()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryViewSetup()
        labelSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func accessoryViewSetup() {
        let image = UIImage(systemName: "chevron.forward", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .headline, weight: .bold)))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .secondaryLabelColor
        
        self.accessoryView = imageView
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
    
    func labelSetup() {
        titleLabel.adjustsFontSizeToFitWidth = true
        addressLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
}



class UploadPostDetailGradeCell : UITableViewCell  {
    
    var gradeToggleButton : RoundedButton! = RoundedButton()
    
    var currentGrade : Double?
    
    weak var uploadPostDetailGradeCellDelegate : UploadPostDetailGradeCellDelegate?
    
    var commentStatus : Bool = false
    
    let buttonFont = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
    
    let starImageFont = UIFont.weightSystemSizeFont(systemFontStyle: .largeTitle, weight: .medium)
    
    var lastGrade : Double?
    
    var starStackView : UIStackView! = UIStackView()
    func initLayout() {
        
        contentView.addSubview(gradeToggleButton)
        contentView.addSubview(starStackView)
        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            starStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            starStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            starStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            starStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            starStackView.trailingAnchor.constraint(equalTo: gradeToggleButton.leadingAnchor, constant: -8),
            starStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            
            gradeToggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant : -28),
            gradeToggleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func buttonSetup() {
        gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .secondaryBackgroundColor, tintColor: .secondaryLabelColor  , font: buttonFont)

        gradeToggleButton.addTarget(self, action: #selector(gradeToggle(_ : )), for: .touchUpInside)
        gradeToggleButton.scaleTargets?.append(gradeToggleButton)
        gradeToggleButton.isEnabled = true
        gradeToggleButton.animatedEnable = true
        gradeToggleButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    }
    
    func stackViewSetup() {
        starStackView.alignment = .fill
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 2
        for index in 0...4 {
            let starImageView = UIImageView(image: UIImage(systemName : "star"))
            starImageView.contentMode = .scaleAspectFill
            starStackView.addArrangedSubview(starImageView)
            starImageView.tag = index
            let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(starTapped( _ : )))
            doubleGesture.numberOfTapsRequired = 2
            let gesture = UITapGestureRecognizer(target: self, action: #selector(starTapped ( _ : )))
            gesture.numberOfTapsRequired = 1
            gesture.cancelsTouchesInView = false
    
            starImageView.addGestureRecognizer(doubleGesture)
            starImageView.addGestureRecognizer(gesture)
            starImageView.isUserInteractionEnabled = true
            let image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.secondaryLabelColor, renderingMode: .alwaysOriginal)
            starImageView.image = image
        }

    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buttonSetup()
        stackViewSetup()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func gradeToggle(_ button : UIButton) {
        
        commentStatus.toggle()
        let gradeToggleButton = button as! RoundedButton
        if commentStatus {
            if lastGrade == nil {
                lastGrade = 5
            }
            guard let lastGrade = lastGrade else {
                return
            }
            self.currentGrade = lastGrade
            gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .tintColor, tintColor: .white, font: buttonFont)
            fillStar(grade : lastGrade)

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
        uploadPostDetailGradeCellDelegate?.updateReleaseButtonStatus()
        
    }
    
    @objc func starTapped(_ gesture : UITapGestureRecognizer) {
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
        uploadPostDetailGradeCellDelegate?.updateReleaseButtonStatus()
    }
    
    func fillStar(grade : Double?) {
        currentGrade = grade
        guard let grade = grade else {
            return
        }
        let integerPart = Int(grade)
        guard grade != 0 else {
            return
        }
        
        gradeToggleButton.updateTitle(Title: "啟用", backgroundColor: .tintColor, tintColor: .white, font: UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium))
        
        let decimalPart = grade - Double(integerPart)
        if integerPart > 0 {
            for index in 0...integerPart - 1 {
                let starImageView = self.starStackView.arrangedSubviews[index] as! UIImageView
                starImageView.image = UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            }
        }
        if grade == 5 {
            return
        }
        let starImageView = self.starStackView.arrangedSubviews[integerPart] as! UIImageView
        if decimalPart == 0 {
            starImageView.image = UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
        } else {
            starImageView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
        }
        if integerPart + 1 < 4 {
            for index in integerPart + 1...4 {
                let starImageView = self.starStackView.arrangedSubviews[index] as! UIImageView
                starImageView.image = UIImage(systemName: "star",withConfiguration: UIImage.SymbolConfiguration(font: starImageFont))?.withTintColor(.gradeStarYellow, renderingMode: .alwaysOriginal)
            }
        }
        
    }
}
