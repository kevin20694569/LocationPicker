import UIKit

class FriendViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ShowViewControllerDelegate {
    
    var user : User!
    
    
    var presentForTabBarLessView : Bool! = false
    init(presentForTabBarLessView : Bool, user : User) {
        super.init(nibName: nil, bundle: nil)
        self.presentForTabBarLessView  = presentForTabBarLessView
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friends.count
    }

    var friends : [Friend]! = []//Friend.examples
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableCell", for: indexPath) as! FriendTableCell
        let friend = friends[indexPath.row]
        cell.configure(friend: friend)
        cell.delegate = self
        return cell
    }
    
    
    var tableView : UITableView! = UITableView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLayout()
        
    }
    
    
    func insertFriends() async  {
        do {
            let newFriends = try await FriendsManager.shared.getUserFriends(user_id: self.user.user_id)
            if newFriends.count > 0 {
                let insertionIndexPaths = (self.friends.count..<self.friends.count + newFriends.count).map { IndexPath(row: $0, section: 0) }
               
                self.friends.insert(contentsOf: newFriends, at: friends.count)
                self.tableView.insertRows(at:insertionIndexPaths, with: .fade)
            }
        } catch {
            print(error)
        }
    }
    
    func setupTableView() {
        let bounds = UIScreen.main.bounds
        registerCells()
        tableView.delaysContentTouches = false
        if !self.presentForTabBarLessView  {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constant.bottomBarViewHeight - Constant.safeAreaInsets.bottom , right: 0)
        }
        tableView.rowHeight = bounds.height / 10
        tableView.allowsSelection = false
        Task {
            tableView.delegate = self
            tableView.dataSource = self
            await insertFriends()
        }
        

    }
    
    func registerCells() {
        self.tableView.register(FriendTableCell.self, forCellReuseIdentifier: "FriendTableCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }
         
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    func setupLayout() {
        self.view.addSubview(tableView)
        
        self.view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        
        ])
    }
    
    func configureNavBar() {
        self.navigationItem.title = user.name + "的朋友們"
    }
    
    
    
}
