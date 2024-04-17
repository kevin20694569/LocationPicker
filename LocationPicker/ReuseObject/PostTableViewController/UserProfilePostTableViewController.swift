import UIKit

class UserProfilePostTableViewController : PostTableViewController {
    
    var user : User!
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoadingPost, posts.count - indexPath.row == 1,
              let user_id = user.id else {
            return
        }
        
        Task {
            isLoadingPost = true
            let lastPost = self.posts.last
            
            guard let timestamp = lastPost?.timestamp else {
                return
            }
            do {
                
                let newposts = try await PostManager.shared.getUserPostsByID(user_id: user_id, date: timestamp)
                
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
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        var cell : StandardPostTableCellProtocol!
        if post.postTitle != nil && post.postContent == nil {
            let cellIdentifier = "StandardPostTitleTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostTitleTableCell
        } else if post.postTitle == nil && post.postContent != nil  {
            let cellIdentifier = "StandardPostContentTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostContentTableCell
        } else if post.postTitle != nil && post.postContent != nil {
            let cellIdentifier = "StandardPostAllTextTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostAllTextTableCell
        } else {
            let cellIdentifier = "StandardPostTableCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StandardPostTableCell
            
        }
        cell.collectionViewHeight = Constant.standardMinimumTableCellCollectionViewHeight
        cell.configureData(post: post)
        cell.userImageView.isUserInteractionEnabled = false
        cell.userNameLabel.isUserInteractionEnabled = false
        
        cell.standardPostCellDelegate = self
        cell.mediaTableCellDelegate = self
        return cell
    }
    
    override func configureNavBar(title: String?) {
        super.configureNavBar(title: title)
        self.navigationItem.title = user.name
    }
    
}


