import UIKit

class UserProfileOptionViewController : StandardSheetTableViewController {
    
    var profile : UserProfile!
    
    init(profile : UserProfile) {
        super.init()
        self.profile = profile
    }
    
    weak var mainUserProfileViewController : MainUserProfileViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dict : [Int: (logo : UIImage, title : String)] = [ 0 : (logo : UIImage(systemName: "person.badge.minus")!, title : "解除朋友關係")]
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileOptionCell", for: indexPath) as! UserProfileOptionCell
        cell.selectionStyle = .none
        if let data = dict[indexPath.row] {
            cell.configure(title: data.title, logoImage: data.logo )
        }
        if indexPath.row == dict.count - 1 {
            cell.logoImageView.tintColor = .systemRed
            cell.titleLabel.textColor = .systemRed
        }
        if dict.count == 1 {
            cell.backgroundViewCorners(topCornerMask: nil)
        } else if indexPath.row == 0 {
            cell.backgroundViewCorners(topCornerMask: true)
        } else if indexPath.row == self.dict.count - 1 {
            cell.backgroundViewCorners(topCornerMask: false)
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict.count
    }
    
    override func registerCell() {
        super.registerCell()
        tableView.register(UserProfileOptionCell.self, forCellReuseIdentifier: "UserProfileOptionCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 :
            presentDeleteFriendShipAlertController()

        default:
            return
        }
    }
    
    func presentDeleteFriendShipAlertController() {
        let alertController = UIAlertController(title: "確定要解除朋友關係？", message: nil, preferredStyle: .alert)
    
       
        let cacnelAction = UIAlertAction(title: "取消", style: .cancel) { action in

        }
        
        
        let deleteAction = UIAlertAction(title: "解除", style: .destructive) { action in
            Task {
                do {
                    try await FriendManager.shared.deleteFriendShip(request_user_id: Constant.user_id , to_user_id: self.profile.user.id )
                    self.profile.friendStatus = .notFriend
                    self.mainUserProfileViewController?.collectionView.reloadSections([0])
                    self.dismiss(animated: true)
                } catch {
                    print(error)
                }
            }
        }
        alertController.addAction(cacnelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true)
    }
    
}
