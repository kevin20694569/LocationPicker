import UIKit
import GoogleMaps

enum PlaceFindSection {
    case main
}

class PlaceFindtableViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var searchBar : UISearchBar!
    var sourceController : PlaceFindDelegate!
    @IBOutlet var tableView : UITableView!
    var currentName : String?
    var locationModel : [Restaurant]! = []
    var nextToken : String?
    var lastSearchText : String?
    lazy var dataSource = configureDatasource()
    
    func configureDatasource() -> UITableViewDiffableDataSource<PlaceFindSection, Restaurant> {
        let datasource = UITableViewDiffableDataSource<PlaceFindSection, Restaurant>(tableView: tableView) {[self] tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceFindCell", for: indexPath) as! PlaceFindCell
            let model = locationModel[indexPath.row]
            cell.configure(Location: model)
            return cell
        }
        return datasource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.refreshControl = UIRefreshControl()
        dataSource.defaultRowAnimation = .fade
        tableView.rowHeight = 65
        tableView.separatorStyle = .singleLine
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = self.locationModel[indexPath.row]
        guard location.ID != String(0) else {
            return
        }
        sourceController.changePlaceModel(model: location)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if locationModel.count - indexPath.row == 5 {
            guard let nextToken = nextToken else {
                return
            }
            Task {
                await self.fetchLocationByToken(token: nextToken)
                self.applysnashot()
            }
        }
    }
    
}


extension PlaceFindtableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else {
            return
        }
        if lastSearchText == query {
            return
        }
        Task {
            self.tableView.refreshControl?.beginRefreshing()
            self.locationModel.removeAll()
            await fetchLocationByQuery(query : query)
            applysnashot()
        }
        searchBar.resignFirstResponder()
    }
    
    func fetchLocationByToken(token : String) async {
        do {
            guard let nextToken = nextToken else {
                return
            }
            let (results, token) = try await GoogleMapApiManager.shared.fetchGoogleMapLocationNearbyToken(token: nextToken)
            let filtedResults = filterSearchResults(results: results)
            if filtedResults.count > 0 {
                self.nextToken = token
                self.locationModel.insert(contentsOf: filtedResults, at: self.locationModel.count)
            } else {
                self.nextToken = nil
            }
            
        } catch {
            print("error", error.localizedDescription)
        }
    }
    
    
    
    func fetchLocationByQuery(query : String) async {
        do {
            lastSearchText = query
            let (results, token) = try await GoogleMapApiManager.shared.fetchGoogleMapLocation(query: query)
            let filtedResults = filterSearchResults(results: results)
            if filtedResults.count > 0 {
                self.nextToken = token
                self.locationModel.insert(contentsOf: filtedResults, at: self.locationModel.count)
            } else {
                self.nextToken = nil
                self.locationModel.append(.init(name: "沒有餐廳", Address: "搜尋失敗", restaurantID: "0", image: nil))
            }
        } catch {
            print("error", error.localizedDescription)
        }
    }
    
    func applysnashot() {
        var snapshot = NSDiffableDataSourceSnapshot<PlaceFindSection, Restaurant>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.locationModel, toSection: .main)
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func filterSearchResults(results : [Restaurant]) -> [Restaurant] {

        let streetPattern = ".*[街].*號.*"
        let roadPattern = ".*[路].*號.*"
        return results.filter { location in
            let streetPredicate = NSPredicate(format:"SELF MATCHES %@", streetPattern)
            let roadPredicate = NSPredicate(format:"SELF MATCHES %@", roadPattern)
            if location.Address.count < 11 {
                return false
            }
            return streetPredicate.evaluate(with: location.Address) || roadPredicate.evaluate(with: location.Address)
        }
    }
}





