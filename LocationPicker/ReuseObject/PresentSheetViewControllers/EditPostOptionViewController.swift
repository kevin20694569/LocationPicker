import UIKit

class EditPostOptionViewController : PresentedSheetViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var dict : [Int: (logo : UIImage, title : String)] = [0 : (logo : UIImage(systemName: "pencil")!, title : "編輯貼文"),
                                                          1 : (logo : UIImage(systemName: "trash")!, title : "刪除貼文")
    ]
    
    var post : Post  = Post()
    
    weak var postTableViewController : MediaTableViewCellDelegate?
    
    weak var tableViewCell : StandardPostTableCellProtocol?
    
    
    init(post : Post) {
        super.init(nibName: nil, bundle: nil)
        self.post = post
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditPostOptionCell", for: indexPath) as! EditPostOptionCell
        cell.selectionStyle = .none
        if let data = dict[indexPath.row] {
            cell.configure(title: data.title, logoImage: data.logo )
        }
        if indexPath.row == dict.count - 1 {
            cell.logoImageView.tintColor = .systemRed
            cell.titleLabel.textColor = .systemRed
        }
        if indexPath.row == 0 {
            cell.backgroundViewCorners(topCornerMask: true)
        }
        
        if indexPath.row == self.dict.count - 1 {
            cell.backgroundViewCorners(topCornerMask: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict.count
    }
    
    var tableView : UITableView! = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLayout()
        registerCell()
        tableViewSetup()
    }
    
    
    override func initLayout() {
        super.initLayout()
        view.addSubview(tableView)
        view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.titleSlideView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        self.view.backgroundColor = .secondaryBackgroundColor
        self.tableView.backgroundColor = .secondaryBackgroundColor
    }
    
    func registerCell() {
        tableView.register(EditPostOptionCell.self, forCellReuseIdentifier: "EditPostOptionCell")
    }
    
    func tableViewSetup() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as! EditPostOptionCell
        cell.select(true)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EditPostOptionCell
        cell.select(false)

        switch indexPath.row {
        case 0 :
            showEditPostViewController()
        case 1 :
            presentDeletePostAlertController()
        default:
            return
        }
    }
    
    func presentDeletePostAlertController() {
        let alertController = UIAlertController(title: "確定要刪除貼文？", message: nil, preferredStyle: .alert)
        
        let cacnelAction = UIAlertAction(title: "取消", style: .cancel) { action in

        }
        
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { action in
            Task {
                await self.deletePost(post_id: self.post.id )
            }
        }
        alertController.addAction(cacnelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true)
    }
    
    func deletePost(post_id : String) async  {
        do {
            try await PostManager.shared.deletePost(post_id: post_id)
            self.dismiss(animated: true)
            postTableViewController?.deletePostCell(post: post )
            
        } catch {
            print(error)
        }
    }
    
    func showEditPostViewController() {
        self.dismiss(animated: true)
        let controller = EditPostViewController(post: post)
        controller.refreshCellDelegate = self.tableViewCell
        postTableViewController?.show(controller, sender: nil)
    }
    
}
