import UIKit

class PostDetailTableViewcontroller: UITableViewController {
    
    var MediaStorage: [Media]!
    
    @IBOutlet var releaseButton: RoundedButton! { didSet {
        releaseButton.updateTitle(Title: "發佈")
    }}
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostDetailTableViewCell", for: indexPath) as! PostDetailTableViewCell
            cell.titleLabel?.text = ""
            return cell
            
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostDetailTableViewTextCell", for: indexPath) as! PostDetailTableViewTextCell
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
        
    @IBAction func releaseButtonTapped() {
        Task  {
           // await PostManager.shared.uploadPostTask(post_content: "喜歡", media: MediaStorage, user_id: 3, restaurant_name: PostAddress, restaurant_address: nil)
        }
        self.tabBarController?.selectedIndex = 1
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributedString = NSAttributedString(string: "發佈", attributes: [
            .font : UIFont.systemFont(ofSize: 18, weight: .bold)
        ])
        releaseButton.configuration?.attributedTitle =  AttributedString(attributedString)
    }
    
  
    

}
