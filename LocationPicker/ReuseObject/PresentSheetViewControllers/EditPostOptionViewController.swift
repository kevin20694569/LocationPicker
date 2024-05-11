import UIKit

class EditPostOptionViewController : StandardSheetTableViewController {
    
    
    var dict : [Int: (logo : UIImage, title : String)] = [0 : (logo : UIImage(systemName: "pencil")!, title : "編輯貼文"),
                                                          1 : (logo : UIImage(systemName: "trash")!, title : "刪除貼文")
    ]
    
    var post : Post  = Post()
    
    weak var postTableViewController : StandardPostCellDelegate?
    
    
    init(post : Post) {
        super.init()
        self.post = post
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditPostOptionCell", for: indexPath) as! EditPostOptionCell
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
        tableView.register(EditPostOptionCell.self, forCellReuseIdentifier: "EditPostOptionCell")
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
                self.dismiss(animated: true)
            }
        }
        alertController.addAction(cacnelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true)
    }
    
    func deletePost(post_id : String) async  {
        do {
            try await PostManager.shared.deletePost(post_id: post_id)
            postTableViewController?.deletePostCell(post: post )
        } catch {
            print(error)
        }
    }
    
    func showEditPostViewController() {
        self.dismiss(animated: true)
        postTableViewController?.showEditPostViewController(post: self.post)
    }
    
}
