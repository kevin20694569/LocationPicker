import UIKit

class EditUserTextFieldTableCell : UITableViewCell, UITextFieldDelegate {
    
    
    var themeLabel : UILabel! = UILabel()
    var textField : UITextField! = UITextField()
    var statusImageBackgroundView : UIView! = UIView()
    var statusImageView : UIImageView! = UIImageView()
    
    var alarmLabel : UILabel! = UILabel()
    

    
    var characterLimit : Int! {
        8
    }
    
    weak var delegate : EditUserProfileCellDelegate?
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutSetup()
        labelSetup()
        fieldSetup()
        imageViewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(profile : UserProfile, value : String?, themeLabelSize : CGSize) {
        self.textField.text = value
        NSLayoutConstraint.activate([
            themeLabel.widthAnchor.constraint(equalToConstant: themeLabelSize.width + 2)
        ])
    }
    
    func layoutSetup() {
        self.contentView.addSubview(statusImageBackgroundView)
        self.contentView.addSubview(statusImageView)
        self.contentView.addSubview(themeLabel)
        self.contentView.addSubview(textField)
        self.contentView.addSubview(alarmLabel)
        contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            themeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            themeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            
            statusImageBackgroundView.leadingAnchor.constraint(equalTo: themeLabel.trailingAnchor, constant: 8),
            statusImageBackgroundView.heightAnchor.constraint(equalTo: themeLabel.heightAnchor, multiplier: 1.02),
            statusImageBackgroundView.centerYAnchor.constraint(equalTo: themeLabel.centerYAnchor),
            statusImageBackgroundView.widthAnchor.constraint(equalTo: statusImageBackgroundView.heightAnchor, multiplier: 1),
            
            statusImageView.centerXAnchor.constraint(equalTo: statusImageBackgroundView.centerXAnchor),
            statusImageView.centerYAnchor.constraint(equalTo: statusImageBackgroundView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalTo: statusImageBackgroundView.widthAnchor, multiplier: 0.8),
            statusImageView.heightAnchor.constraint(equalTo: statusImageView.widthAnchor, multiplier: 1),

            textField.topAnchor.constraint(equalTo: statusImageBackgroundView.bottomAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textField.leadingAnchor.constraint(equalTo: themeLabel.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            alarmLabel.leadingAnchor.constraint(equalTo: statusImageBackgroundView.trailingAnchor, constant: 8),
            alarmLabel.centerYAnchor.constraint(equalTo: statusImageBackgroundView.centerYAnchor, constant: 2),
        ])
    }

    func labelSetup() {
        self.themeLabel.font = .weightSystemSizeFont(systemFontStyle: .title3, weight: .regular)
        self.alarmLabel.font = .weightSystemSizeFont(systemFontStyle: .footnote, weight: .regular)
        alarmLabel.textColor = .secondaryLabelColor
    }
    
    func fieldSetup() {
        textField.font = .weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        textField.delegate = self
    }
    
    func imageViewSetup() {
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .body, weight: .bold)))
        statusImageView.tintColor = .white
        
        statusImageBackgroundView.clipsToBounds = true
        statusImageBackgroundView.layer.cornerRadius = 8
        statusImageBackgroundView.backgroundColor = .systemGreen
        
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()

        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterLimit = characterLimit else {
            delegate?.saveButtonEnableToggle(true)
            return true
        }
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        delegate?.saveButtonEnableToggle(newText.count <= characterLimit)
        return true
        
    }
    
    func isValidInput(_ input: String) -> Bool {
        let halfCount = input.halfCount
        let valid = halfCount <= self.characterLimit
        changeStatusImageView(isValid: valid)
        return valid
    }
    
    func changeStatusImageView(isValid : Bool) {
        alarmLabel.text = "格式不符"
        self.statusImageBackgroundView.backgroundColor = isValid ? .systemGreen : .systemRed
        self.statusImageView.image = isValid ? UIImage(systemName: "checkmark") :  UIImage(systemName: "xmark")
        alarmLabel.isHidden = isValid
    }
    

    

    
}

class EditUserNameTextFieldTableCell : EditUserTextFieldTableCell {
    override var characterLimit : Int! {
        20
    }
    
    override func changeStatusImageView(isValid: Bool) {
        super.changeStatusImageView(isValid: isValid)
        alarmLabel.text = "限制\(characterLimit / 2)個中文字符 (\(String(describing: characterLimit))個英文字符)"
        self.statusImageBackgroundView.backgroundColor = isValid ? .systemGreen : .systemRed
        self.statusImageView.image = isValid ? UIImage(systemName: "checkmark") :  UIImage(systemName: "xmark")
        alarmLabel.isHidden = isValid
    }

    
    override func configure(profile: UserProfile, value: String?, themeLabelSize: CGSize) {
        super.configure(profile: profile, value: value, themeLabelSize: themeLabelSize)
        self.themeLabel.text = "Name"
        self.textField.placeholder = "輸入名字"
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? "" + string
        let bool = isValidInput(text)
        delegate?.saveButtonEnableToggle(bool)
        return true
    }
}

class EditUserEmailTextFieldTableCell : EditUserTextFieldTableCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(profile: UserProfile, value: String?, themeLabelSize: CGSize) {
        super.configure(profile: profile, value: value, themeLabelSize: themeLabelSize)
        self.themeLabel.text = "Email"
        self.textField.placeholder = "輸入電子郵件"
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? "" + string
        let validEmail = text.isValidEmail()
        changeStatusImageView(isValid: validEmail)
        delegate?.saveButtonEnableToggle(validEmail)
        return true
       
    }
}
