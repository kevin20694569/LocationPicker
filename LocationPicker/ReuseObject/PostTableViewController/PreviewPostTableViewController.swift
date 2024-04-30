import UIKit
import AVFoundation

class PreviewPostTableViewController : MainPostTableViewController {
    
    @IBAction func dismissSelf() {
        self.pauseCurrentMedia()
        self.dismiss(animated: true)
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
        cell.gradeStackView.isUserInteractionEnabled = false
        cell.collectImageView.isUserInteractionEnabled = false
        cell.shareImageView.isUserInteractionEnabled = false
        cell.tapHeartGesture.isEnabled = false
        cell.heartImageView.isUserInteractionEnabled = false
        return cell
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
    
    override func viewStyleSetup() {
        super.viewStyleSetup()
        tableView.isScrollEnabled = false
        self.navigationItem.title = "貼文預覽"
    }
    
    override func navigationSetup() {
        super.navigationSetup()
        self.navigationController?.navigationBar.standardAppearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithOpaqueBackground()
    }
    
    
    override func layoutTitleButton() {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    override func refreshPosts() {
        
    }
    
    override func showUserProfile(user : User) {
        
    }
    override func configureBarButton() {
        
    }
}
