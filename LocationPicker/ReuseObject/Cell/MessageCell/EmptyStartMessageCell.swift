

import UIKit

class EmptyStartMessageCell : UITableViewCell, MessageTableCellProtocol {
    var mainTextLabel : UILabel! = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelSetup()
        layoutSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message: Message) {

    }
    
    func labelSetup() {
        mainTextLabel.text = "尚未有訊息"
        mainTextLabel.font = .weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)
        mainTextLabel.numberOfLines = 1
        mainTextLabel.textAlignment = .center
    }
    
    func layoutSetup() {
        self.contentView.addSubview(mainTextLabel)
        
        self.contentView.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            mainTextLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            mainTextLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            mainTextLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            mainTextLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16)
        
        ])
    }
    
    
}
