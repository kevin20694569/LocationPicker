

import UIKit

class  EditUserProfileViewController : UIViewController, EditUserProfileCellDelegate {
    var presentForTabBarLessView: Bool!
    
    var statusImageView : UIImageView! = UIImageView()
    
    var saveButtonEnable : Bool! = false { didSet {
        self.saveItemButton.isEnabled = saveButtonEnable
    }}
    
    
    
    var textFieldSectonDict : [ Int : (theme : String, placeholder : String) ] = [ 0: ( "Name",  "輸入名字"),
                
                                                                                   1: ( "Email",  "")]
    
    var dismissKeyBoardTapGesture : UITapGestureRecognizer! = UITapGestureRecognizer()
    
    var tableView : UITableView! = UITableView()
    
    var saveItemButton : UIBarButtonItem! = UIBarButtonItem()
    
    var userProfile : UserProfile! = UserProfile.example
    
    init(profile : UserProfile) {
        super.init(nibName: nil, bundle: nil)
        self.userProfile = profile
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSetup()
        registerCells()
        tableViewSetup()
        barButtonItemSetup()
        gestureSetup()
    }
    
    func layoutSetup() {
        self.view.addSubview(tableView)
        
        self.view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func barButtonItemSetup() {
        self.navigationItem.rightBarButtonItem = self.saveItemButton
        saveItemButton.title = "儲存"
        saveItemButton.target = self
        saveItemButton.action = #selector(saveUserProfile)
        saveItemButton.isEnabled = saveButtonEnable
        saveItemButton.tintColor = .tintOrange
    }
    
    @objc func saveUserProfile() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableViewSetup() {
        tableView.dataSource = self
        tableView.delegate  = self
        tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        tableView.isScrollEnabled = false
        tableView.separatorColor = .label
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)

    }
    
    func registerCells() {
        self.tableView.register(EditUserImageTableCell.self, forCellReuseIdentifier: "EditUserImageTableCell")
        self.tableView.register(EditUserTextFieldTableCell.self, forCellReuseIdentifier: "EditUserTextFieldTableCell")
        self.tableView.register(EditUserNameTextFieldTableCell.self, forCellReuseIdentifier: "EditUserNameTextFieldTableCell")
        self.tableView.register(EditUserEmailTextFieldTableCell.self, forCellReuseIdentifier: "EditUserEmailTextFieldTableCell")
        
    }
    
    
    func gestureSetup() {
        dismissKeyBoardTapGesture.cancelsTouchesInView = false
        dismissKeyBoardTapGesture.addTarget(self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(dismissKeyBoardTapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    

    
    func saveButtonEnableToggle(_ enable : Bool) {
        self.saveButtonEnable = enable
    }
    
    

}

extension EditUserProfileViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.textFieldSectonDict.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditUserImageTableCell", for: indexPath) as! EditUserImageTableCell
            cell.configure(profile: self.userProfile)
            cell.delegate = self
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.selectionStyle = .none
            
            return cell
            
        } else {
            let user = userProfile.user
            
            let row = indexPath.row
            
            var value : String? = ""
            var cell = tableView.dequeueReusableCell(withIdentifier: "EditUserTextFieldTableCell", for: indexPath) as! EditUserTextFieldTableCell
            cell.selectionStyle = .none
            switch row {
            case 0 :
                value = user?.name
                cell = tableView.dequeueReusableCell(withIdentifier: "EditUserNameTextFieldTableCell", for: indexPath) as! EditUserNameTextFieldTableCell
                cell.selectionStyle = .none
            case 1 :
                value = user?.email
                cell = tableView.dequeueReusableCell(withIdentifier: "EditUserEmailTextFieldTableCell", for: indexPath) as! EditUserEmailTextFieldTableCell
                let imageView = UIImageView(image:  UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title2, weight: .bold))))
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .secondaryLabelColor
                cell.accessoryView = imageView
                cell.textField.isEnabled = false
                cell.selectionStyle = .default
            default :
                break
            }
            let textSize = (self.textFieldSectonDict[0]!.theme as NSString).size(withAttributes: [.font : UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .regular)])
            cell.configure(profile: self.userProfile, value: value, themeLabelSize: textSize)
            cell.delegate = self
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            return cell
            
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bounds = UIScreen.main.bounds
        let section = indexPath.section
        if section == 0 {
            return bounds.height * 0.2
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.section == 1 && indexPath.row == 1 {
            let controller = EditEmailViewController(profile: self.userProfile)
            self.show(controller, sender: nil)
        }
    }
}





