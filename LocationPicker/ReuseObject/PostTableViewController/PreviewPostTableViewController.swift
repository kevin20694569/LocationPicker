import UIKit
import AVFoundation

class PreviewPostTableViewController : MainPostTableViewController {
    
    @IBAction func dismissSelf() {
        self.pauseCurrentMedia()
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MainPostTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MainPostTableCell
        let post = self.posts[indexPath.row]
        cell.currentPost = self.posts[0]
        cell.mediaTableCellDelegate = self
        cell.configureData(post: post)
        return cell
    }
    
    override func segueToProFile(user_id: Int, user_name: String, user_image: UIImage?) {
        return
    }
    
    override func configureBarButton() {
        return
    }
    
    
    override func presentWholePageMediaViewController(post: Post?) {
        guard let post = post else {
            return
        }
        let controller = PreviewWholePageMediaViewController(presentForTabBarLessView: false, post: post)
        let navController = SwipeEnableNavViewController(rootViewController: controller)
        if let currentPostIndex = self.posts.firstIndex(of: post) {
            self.currentTableViewIndexPath = IndexPath(row: currentPostIndex, section: self.currentTableViewIndexPath.section)
        }

        controller.mediaAnimatorDelegate = self
        controller.wholePageMediaDelegate = self
        navController.modalPresentationStyle = .overFullScreen
        navController.transitioningDelegate = self
        navController.delegate = self
        self.present(navController, animated: true)
    }
    
    override func viewStyleSet() {
        super.viewStyleSet()
        tableView.isScrollEnabled = false
        self.navigationItem.title = "貼文預覽"
    }
    
    
    override func layoutTitleButton() {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    override func refreshPosts() {
        
    }
}

class PreviewWholePageMediaViewController : WholePageMediaViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.isUserInteractionEnabled = false
        self.locationimageView.isUserInteractionEnabled = false
    }
    

    
    
    
}
