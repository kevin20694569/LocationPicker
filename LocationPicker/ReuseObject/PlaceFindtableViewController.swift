

import UIKit

struct placemodel {
    var name : String!
    var address : String!
    
    static var examples = [ placemodel(name: "圖書館", address: "ˇ3e4932ru239ru3djkfnwek"), placemodel(name: "圖書館", address: "ˇ3e4932ru239ru3djkfnwek")]
}

class PlaceFindtableViewController: UITableViewController {

    var currentName : String?
    let model = placemodel.examples
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 65
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceFindCell", for: indexPath) as! PlaceFindCell
        let model = model[indexPath.row]
        cell.Name.text = model.name
        cell.Address.text = model.address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentName = model[indexPath.row].name
        performSegue(withIdentifier: "unwindToStoryUpload", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     /*   if segue.identifier == "unwindToStoryUpload" {
            if let Controller = segue.destination as? StoryUploadViewController {
                Controller.WhereFromLabel.text = currentName
            }
        }*/
    }
 
    
    
    
}
