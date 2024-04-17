

import UIKit

class EditEmailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var tableView : UITableView! = UITableView()
    
    var profile : UserProfile!
    
    var headerView : UIView! = UIView()
    
    var nextTapButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    

    
    init(profile : UserProfile) {
        super.init(nibName: nil, bundle: nil)
        self.profile = profile
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        headerViewSetup()
        buttonSetup()
        tableViewSetup()
        registerCell()
    }
    
    
    func registerCell() {
        tableView.register(EditUserEmailTextFieldTableCell.self, forCellReuseIdentifier: "EditUserEmailTextFieldTableCell")
    }
    
    func headerViewSetup() {
        let titleLabel = UILabel()
        titleLabel.text = "更換電子郵件"
        titleLabel.textColor = .label
        titleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title1, weight: .medium)
        self.headerView.addSubview(titleLabel)
        headerView.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
        ])
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    
    
    func tableViewSetup() {
        tableView.dataSource = self
        tableView.delegate  = self
        tableView.delaysContentTouches = false
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.separatorColor = .label
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.sectionHeaderTopPadding = 0
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func buttonSetup() {
        let container = AttributeContainer([.font : UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)])
        var config = UIButton.Configuration.filled()
        let attriString = AttributedString("寄送驗證碼", attributes: container)
        config.baseBackgroundColor = .tintOrange
        config.baseForegroundColor = .label
        config.titleAlignment = .center
        config.attributedTitle = attriString
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        self.nextTapButton.configuration = config
        nextTapButton.isEnabled = false
    }
    
     
    func layoutSetup() {
        self.view.addSubview(tableView)
        self.view.addSubview(nextTapButton)
        
        self.view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            nextTapButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -Constant.bottomBarViewHeight - 16),
            nextTapButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nextTapButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditUserEmailTextFieldTableCell") as! EditUserEmailTextFieldTableCell
        let textSize = ("Email" as NSString).size(withAttributes: [.font : UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .regular)])
        cell.configure(profile: profile, value: profile.user.email, themeLabelSize: textSize)
        return cell
    }
}


