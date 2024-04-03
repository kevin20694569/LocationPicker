import UIKit
import AVFoundation



class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UISearchBarDelegate ,UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    func updateAll(CurrentImage: UIImage, currentIndex: Int) {
        self.collectionCurrentIndex = currentIndex
    }
    
    var collectionCurrentIndex : Int = 0
    
    @IBOutlet var leftBarButtonItem : UIBarButtonItem!
    
    
    var chatRoomsHadBeenCompletedGet : Bool! = false

    func configureBarButton() {
        let style = UIFont.TextStyle.headline
        let backImage = UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: style, weight: .bold)))
        leftBarButtonItem.image = backImage
        leftBarButtonItem.target = self
        leftBarButtonItem.action = #selector( swipeToLeft)
    }
    
    @objc func swipeToLeft() {
        BasicViewController.shared.startSwipe(toPage: 1)
    }
    
    var cachedIndexPaths : [IndexPath] = [IndexPath]()
    
    var chatrooms : [ChatRoom]! = []
    
    var searchBarViewMinY : CGFloat!

    @IBOutlet var searchBar : UISearchBar! { didSet {
        searchBar.delegate = self
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "搜尋..."
        searchBar.returnKeyType = .search
        searchBar.backgroundColor = .clear
        searchBar.showsCancelButton = false
    }}
    var previousOffsetY :CGFloat = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
        previousOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if chatrooms.count < 10 {
            return
        }
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let tableViewHeight = scrollView.bounds.size.height
        if offsetY > contentHeight - tableViewHeight {
            return
        }
        let barMaxY = self.navigationController?.navigationBar.frame.maxY ?? 0
        let diffY = offsetY - previousOffsetY
        var newY: CGFloat = searchBar.frame.origin.y - diffY
        let persent : Float = Float( ( newY - barMaxY + searchBar.bounds.height) / 40 )
        if scrollView.contentOffset.y <= 0 {
            previousOffsetY = scrollView.contentOffset.y
            return
        }
        if diffY < 0 {
            newY = min(searchBarViewMinY, newY)
        } else {
            newY = max(barMaxY - searchBar.bounds.height, newY )
        }
        searchBar.layer.opacity = persent
        searchBar.frame.origin.y  = newY
        previousOffsetY = scrollView.contentOffset.y
    }
    
    func initRefreshControll() {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.backgroundColor = .clear
        self.tableView.refreshControl?.tintColor = .label
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshChatRoomsPreview), for: .valueChanged)
        
    }
    
    var isLoadingNewChatRooms : Bool = false
    
    @objc func refreshChatRoomsPreview() {
        guard !isLoadingNewChatRooms else {
            return
        }
        Task {
            defer {
                self.tableView.refreshControl?.endRefreshing()
            }
            isLoadingNewChatRooms = true

            ChatRoom.hasRecievedRoom_IDs.removeAll()
            let newChatRooms = try await ChatRoomsManager.shared.getChatroomsPreviewFromUserID(user_id: Constant.user_id, date: "")
            if newChatRooms.count > 0 {
                chatrooms.removeAll()
                self.chatrooms.insert(contentsOf: newChatRooms, at: self.chatrooms.count)
                tableView.reloadSections([0], with: .none)
                let room_ids = chatrooms.compactMap() {
                    ChatRoom.hasRecievedRoom_IDs[$0.room_id] = $0.room_id
                    return $0.room_id
                }
                
                SocketIOManager.shared.joinRooms(room_ids: room_ids)
            }
            isLoadingNewChatRooms = false
        }
    }
    
    func insertNewRooms(date : String) async  {
        do {
            guard !chatRoomsHadBeenCompletedGet else {
                return
            }
            isLoadingNewChatRooms = true
            defer {
                isLoadingNewChatRooms = false
            }
            let newChatRooms = try await ChatRoomsManager.shared.getChatroomsPreviewFromUserID(user_id: Constant.user_id, date: date)
            guard newChatRooms.count > 0 else {
                self.chatRoomsHadBeenCompletedGet = true
                return
            }
            let insertionIndexPaths = (self.chatrooms.count..<self.chatrooms.count + newChatRooms.count).map { IndexPath(row: $0, section: 0) }
            self.chatrooms.insert(contentsOf: newChatRooms, at: self.chatrooms.count)
            
            self.tableView.insertRows(at:insertionIndexPaths, with: .fade)
            let room_ids = chatrooms.compactMap() {
                ChatRoom.hasRecievedRoom_IDs[$0.room_id] = $0.room_id
                return $0.room_id
            }
            SocketIOManager.shared.joinRooms(room_ids: room_ids)
            
            
        } catch {
            print(error)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.shared.listening()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage(_:)), name: NSNotification.Name(rawValue: "ReceivedMessageNotification"), object: nil)
        initRefreshControll()
        viewStyleSet()
        refreshChatRoomsPreview()
        let bounds = UIScreen.main.bounds
        searchBarViewMinY = (self.navigationController?.navigationBar.frame.maxY)! + (self.navigationController?.navigationBar.frame.height)!
        self.searchBar.frame = CGRect(x: 0, y: searchBarViewMinY, width: bounds.width, height: searchBar.bounds.height)

        configureBarButton()
        
    }
    
    func viewStyleSet() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = true
        self.tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = self.view.bounds.height / 10
        searchBar.translatesAutoresizingMaskIntoConstraints = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func receiveMessage(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? Message {
            let destinationIndexPath = IndexPath(row: 0, section: 0)
            if ChatRoom.hasRecievedRoom_IDs[message.room_id] != nil {
                
                for (index, chatroom) in self.chatrooms.enumerated() {
                    if chatroom.room_id == message.room_id {
                        
                        let indexPath = IndexPath(row: index, section: 0)
                        if let roomCell = tableView.cellForRow(at: indexPath) as? ChatRoomTableCell {
                            roomCell.chatroomInstance.lastMessage =  message.message
                            roomCell.chatroomInstance.lastTimeStamp = message.created_time
                            roomCell.configure(chatroom: roomCell.chatroomInstance)
                            let itemToMove = self.chatrooms.remove(at: indexPath.row)
                            chatrooms.insert(itemToMove, at: 0)
                            tableView.beginUpdates()
                            tableView.moveRow(at: indexPath, to: destinationIndexPath)
                            tableView.endUpdates()
                        }
                        break
                    }
                }
                return
            }
            
            Task {
                let newChatRoom = try await ChatRoomsManager.shared.getSingleChatroomsPreviewFromUserID(room_id: message.room_id)
                ChatRoom.hasRecievedRoom_IDs[newChatRoom.room_id] = newChatRoom.room_id
                chatrooms.insert(newChatRoom, at: 0)
                self.tableView.insertRows(at: [destinationIndexPath], with: .top)
                tableView.beginUpdates()
                tableView.endUpdates()
                SocketIOManager.shared.joinRooms(room_ids: [newChatRoom.room_id])
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        guard !BasicViewController.shared.isSwiping else {
            return
        }
        let chatRoom = chatrooms[indexPath.row]
        let controller = MessageViewController(chatRoom: chatRoom)
        let cell = tableView.cellForRow(at: indexPath) as! ChatRoomTableCell
        let userImage = chatRoom.user?.image
        if let user_id = chatRoom.user?.user_id {
            controller.userImageDict[user_id] = userImage
        }
        self.show(controller, sender: nil)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chatcell", for: indexPath) as! ChatRoomTableCell
        let chatmodel = chatrooms[indexPath.row]
        cell.configure(chatroom: chatmodel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoadingNewChatRooms, chatrooms.count - indexPath.row == 2 else {
            return
        }
        let lastChatrooms = self.chatrooms.last
        guard let timeStamp = lastChatrooms?.lastTimeStamp else {
            return
        }
        Task {
            await self.insertNewRooms(date: timeStamp)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
}







