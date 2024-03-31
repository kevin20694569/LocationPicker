import UIKit
enum FriendsSection {
    case main
}

class FriendsViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, UISearchControllerDelegate, UITextFieldDelegate, FriendRequestsCellDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userRequest = userRequests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendRequestsTableViewCell
        cell.friendRequestsDelegate = self
        cell.configure(userRequest: userRequest)
        return cell
    }
    
    
    func segueToUserProfileView(userRequst userRequest : UserFriendRequest) {
        let controller = MainUserProfileViewController(presentForTabBarLessView: true)
        controller.user_id = userRequest.user_ID
        controller.navigationItem.title = userRequest.name
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    var userRequests : [UserFriendRequest]! = []
    var currentIndexPath : IndexPath?
    var headerViewMinY : CGFloat!

    @IBOutlet var TitleLabel: UILabel!
    @IBOutlet var SearchBar : UISearchBar! { didSet {
        SearchBar.delegate = self
        SearchBar.delegate = self
        SearchBar.searchBarStyle = .minimal
        SearchBar.placeholder = "搜尋..."
        SearchBar.returnKeyType = .search
        SearchBar.backgroundColor = .clear
        SearchBar.showsCancelButton = false
    }}

    var previousOffsetY :CGFloat = 0
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewStyleSet()
        Task {
            tableView.dataSource = self
            tableView.delegate = self
            await loadUserFriendsRequests(user_id: Constant.user_id)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func viewStyleSet() {
        let bounds = UIScreen.main.bounds
        tableView.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCell")

        tableView.allowsSelection = false
        tableView.rowHeight = bounds.height / 8.5
        SearchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerViewMinY = self.navigationController?.navigationBar.frame.maxY
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SearchBar.endEditing(true)
    }
    
    
}
extension FriendsViewController {
    func loadUserFriendsRequests(user_id : Int) async {
        do {
            let newRequests = try await FriendsManager.shared.getUserFriendsRequestsFromUserID(user_id: Constant.user_id, date: "")
            
            if newRequests.count > 0 {
                tableView.beginUpdates()
                let insertionIndexPaths = (self.userRequests.count..<self.userRequests.count + newRequests.count).map { IndexPath(row: $0, section: 0) }
                self.userRequests.insert(contentsOf: newRequests, at: self.userRequests.count)
                self.tableView.insertRows(at:insertionIndexPaths, with: .fade)
                tableView.endUpdates()
            }
        } catch {
            print("error error", error)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! FriendRequestsTableViewCell
        let userRequst = cell.userRequestInstance
        Task {
            if let imageURL = userRequst?.user_imageurl,
               let (data, _)  = try? await URLSession.shared.data(from: imageURL) {
                let image = UIImage(data: data)
                userRequst?.userimage = image
                cell.userImageView.image = image
            }
        }
    }
}

extension FriendsViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        SearchBar.endEditing(true)
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

extension FriendsViewController {
    /* func tableviewcellEnterDetailView(user : User, indexPath : IndexPath) {
     self.currentIndexPath = indexPath
     let viewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
     viewcontroller.Albumimage = Song.artworkUrl100
     viewcontroller.Song = Song
     viewcontroller.MainViewDelegate = self
     viewcontroller.modalPresentationStyle = .custom
     viewcontroller.transitioningDelegate = self
     self.modalPresentationStyle = .custom
     self.transitioningDelegate = self
     self.present(viewcontroller, animated: true)
     }*/
}

/*extension FriendsViewController: UIViewControllerTransitioningDelegate {
 
 /*  func updateImageView(image: UIImage) {
  let cell = self.tableView.cellForRow(at: currentIndexPath!) as! FriendsTableViewCell
  cell.AlbumImageView.image = image
  cell.AlbumImageView.setNeedsLayout()
  cell.AlbumImageView.layoutIfNeeded()
  }*/
 func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
 return DetailPresentationViewController(presentedViewController: presented, presenting: presenting)
 }
 
 func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
 let viewcontroller = source as! MainViewController
 let cell = viewcontroller.MainpresentedView.tableView.cellForRow(at: viewcontroller.MainpresentedView.tableView.indexPathForSelectedRow!) as! FriendsTableViewCell
 let imageview = cell.AlbumImageView
 let startpoint = cell.AlbumImageView.convert(cell.AlbumImageView.bounds, to: self.view)
 let Animator = DetailViewControllerZoominAnimator(startpoint: startpoint, image: cell.AlbumImageView.image!)
 cell.AlbumImageView.image = nil
 return Animator
 }
 
 func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
 let cell = MainpresentedView.tableView.cellForRow(at: currentIndexPath!) as! FriendsTableViewCell
 let viewcontroller = dismissed as! DetailViewController
 let startpoint = cell.AlbumImageView.convert(cell.AlbumImageView.bounds, to: self.view)
 let Animator = DetailViewControllerZoomOutAnimator(image: viewcontroller.Albumimage, startpoint: startpoint)
 return Animator
 }
 }*/

