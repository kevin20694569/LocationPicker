import UIKit


class FriendRequestViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, UISearchControllerDelegate, UITextFieldDelegate, FriendRequestsCellDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userRequest = userRequests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestsTableViewCell") as! FriendRequestsTableViewCell
        cell.friendRequestsDelegate = self
        cell.configure(userRequest: userRequest)
        return cell
    }
    
    
    func showUserProfileViewController(userRequst userRequest : UserFriendRequest) {
        let controller = MainUserProfileViewController(presentForTabBarLessView: true, user: userRequest.user, user_id: userRequest.user?.id)
        controller.navigationItem.title = userRequest.user?.name
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    var userRequests : [UserFriendRequest]! = []
    var currentIndexPath : IndexPath?
    //var headerViewMinY : CGFloat!

    @IBOutlet var TitleLabel: UILabel!
   /* @IBOutlet var SearchBar : UISearchBar! { didSet {
        SearchBar.delegate = self
        SearchBar.delegate = self
        SearchBar.searchBarStyle = .minimal
        SearchBar.placeholder = "搜尋..."
        SearchBar.returnKeyType = .search
        SearchBar.backgroundColor = .clear
        SearchBar.showsCancelButton = false
    }}*/

    var previousOffsetY :CGFloat = 0
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        tableViewSetup()
        registerCells()

        Task {
            await loadUserFriendsRequests(user_id: Constant.user_id)
        }
        
    }
    
    
    func registerCells() {
        tableView.register(FriendRequestsTableViewCell.self, forCellReuseIdentifier: "FriendRequestsTableViewCell")
    }
    
    func viewSetup() {

      //  headerViewMinY = self.navigationController?.navigationBar.frame.maxY
        
    }
    
    func tableViewSetup() {
        let bounds = UIScreen.main.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.delaysContentTouches = false
        tableView.rowHeight = bounds.height / 10
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     //   SearchBar.endEditing(true)
    }
    
    
}
extension FriendRequestViewController {
    func loadUserFriendsRequests(user_id : String) async {
        do {
            let newRequests = try await FriendManager.shared.getUserFriendReceiveRequestsFromUserID(user_id: Constant.user_id, date: "")
            
            if newRequests.count > 0 {
                tableView.beginUpdates()
                let insertionIndexPaths = (self.userRequests.count..<self.userRequests.count + newRequests.count).map { IndexPath(row: $0, section: 0) }
                self.userRequests.insert(contentsOf: newRequests, at: self.userRequests.count)
                self.tableView.insertRows(at:insertionIndexPaths, with: .automatic)
                tableView.endUpdates()
            }
        } catch {
            print("error", error)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        if let cell = cell as? FriendRequestsTableViewCell {
            self.showUserProfileViewController(userRequst: cell.userRequestInstance)
        }

    }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! FriendRequestsTableViewCell
        let userRequest = cell.userRequestInstance
        Task {
            let image = try await userRequest?.user?.imageURL?.getImageFromURL()
            userRequest?.user?.image = image
            cell.userImageView.image = image
        }
    }
    
    
}

extension FriendRequestViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //    SearchBar.endEditing(true)
        previousOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      /*  guard userRequests.count >= 8 else {
            return
        }
        let barMaxY = self.navigationController?.navigationBar.frame.maxY ?? 0
        let diffY = scrollView.contentOffset.y - previousOffsetY
        if let cell = tableView.visibleCells.last as? FriendRequestsTableViewCell {
            if userRequests.last?.request_ID == cell.userRequestInstance.request_ID && diffY > 0 {
                return
            }
        }
      //  var newY: CGFloat = headerView.frame.origin.y - diffY
        let persent : Float = Float( ( newY - barMaxY + headerView.bounds.height) / 40 )
        if scrollView.contentOffset.y <= 0 {
            previousOffsetY = scrollView.contentOffset.y
            return
        }
        if diffY < 0 {
            newY = min(headerViewMinY, newY)
        } else {
     //       newY = max(barMaxY - headerView.bounds.height, newY )
        }
      //  headerView.layer.opacity = persent
      //  headerView.frame.origin.y  = newY
        previousOffsetY = scrollView.contentOffset.y*/
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        return
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            Task {
                //await self.MainpresentedView.Search(searchText ,offset: nil, IsnewSearch: true)
            }
        }
    }
}
