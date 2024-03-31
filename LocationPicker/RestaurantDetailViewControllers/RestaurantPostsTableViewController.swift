
import UIKit

class RestaurantPostsTableViewController : PostTableViewController {
    
    var restaurant : Restaurant!
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoadingPost, posts.count - indexPath.row == 1,
              let restaurantID  = restaurant.restaurantID else {
            return
        }
        
        Task {
            isLoadingPost = true
            let lastPost = self.posts.last
            
            guard let timestamp = lastPost?.timestamp else {
                return
            }
            do {
                let newposts = try await PostManager.shared.getRestaurantPostsByID(restaurantID: restaurantID, date: timestamp)
                
                if newposts.count > 0 {
                    self.insertNewPosts(newPosts: newposts)
                }
                
                if let refreshControl = self.tableView.refreshControl, refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
                self.isLoadingPost = false
            } catch {
                print("getUserProfilePosts問題", error.localizedDescription)
            }
        }
    }
    
    override func configureNavBar(title: String?) {
        super.configureNavBar(title: title)
        self.navigationItem.title = restaurant.name
        
        
        
        
    }

    
    
}
