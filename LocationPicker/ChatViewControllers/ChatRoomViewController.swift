import UIKit
import AVFoundation



class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UISearchBarDelegate ,UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    func updateAll(CurrentImage: UIImage, currentIndex: Int) {
        self.collectionCurrentIndex = currentIndex
    }
    
    var hasBeenFirstAppear : Bool = false
    
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
    
    var chatRoomPreviews : [ChatRoomPreview]! = []
    
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
        if chatRoomPreviews.count < 10 {
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
            do {
                defer {
                    isLoadingNewChatRooms = false
                    self.tableView.refreshControl?.endRefreshing()
                }
                isLoadingNewChatRooms = true
                
                ChatRoomPreview.hasRecievedRoom_IDs.removeAll()
                chatRoomPreviews.removeAll()
                let newChatRoomPreviews = try await ChatRoomPreviewManager.shared.getChatroomPreviewsByLastMessageOrderFromUserID(user_id: Constant.user_id, date: "")
                
                if newChatRoomPreviews.count > 0 {
                    self.chatRoomPreviews.insert(contentsOf: newChatRoomPreviews, at: self.chatRoomPreviews.count)
                    newChatRoomPreviews.forEach() {
                        ChatRoomPreview.hasRecievedRoom_IDs[$0.chatRoom.room_id] = $0.chatRoom.room_id
                    }
                    
                }
                tableView.reloadSections([0], with: .fade)
                chatRoomsHadBeenCompletedGet = false
                
            }   catch {
                print(error)
            }
            
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
            let newChatRoomPreviews = try await ChatRoomPreviewManager.shared.getChatroomPreviewsByLastMessageOrderFromUserID(user_id: Constant.user_id, date: date)

            guard newChatRoomPreviews.count > 0 else {
                self.chatRoomsHadBeenCompletedGet = true
                return
            }
           
            let insertionIndexPaths = (self.chatRoomPreviews.count..<self.chatRoomPreviews.count + newChatRoomPreviews.count).map { IndexPath(row: $0, section: 0) }
            self.chatRoomPreviews.insert(contentsOf: newChatRoomPreviews, at: self.chatRoomPreviews.count)
            
            self.tableView.insertRows(at:insertionIndexPaths, with: .automatic)
            
            
        } catch {
            print(error)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage( _ :)), name: NSNotification.Name(rawValue: "ReceivedMessageNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveChatRoomIsRead( _ :)), name: NSNotification.Name(rawValue: "ReceivedMessageIsReadNotification"), object: nil)
        initRefreshControll()
        viewStyleSet()
        let bounds = UIScreen.main.bounds
        searchBarViewMinY = (self.navigationController?.navigationBar.frame.maxY)! + UIApplication.shared.statusBarFrame.height
        self.searchBar.frame = CGRect(x: 0, y: searchBarViewMinY, width: bounds.width, height: searchBar.bounds.height)
        configureBarButton()
        SocketIOManager.shared.chatRoomViewController = self
        
    }
    
    func viewStyleSet() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.delaysContentTouches = false
        self.tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = self.view.bounds.height / 10
        searchBar.translatesAutoresizingMaskIntoConstraints = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func receiveChatRoomIsRead( _ notification : Notification) {
        guard let room_id = notification.userInfo?["room_id"] as? String  else {
            return
        }
        guard ChatRoomPreview.hasRecievedRoom_IDs[room_id] != nil else {
            return
        }
        for (index, chatroom) in self.chatRoomPreviews.enumerated() {
            if chatroom.room_id == room_id {
                chatroom.lastMessage.isRead = true
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = tableView.cellForRow(at: indexPath) as? ChatRoomTableCell {
                    cell.configure(chatroom: chatroom)
                }
                break
            }
        }
    }
    
    @objc func receiveMessage(_ notification: Notification) {
        guard let message = notification.userInfo?["message"] as? Message  else {
            return
        }
        let destinationIndexPath = IndexPath(row: 0, section: 0)
        if ChatRoomPreview.hasRecievedRoom_IDs[message.room_id] != nil || self.chatRoomPreviews.contains(where: {
            $0.room_id == message.room_id
        }) {
            
            for (index, chatroom) in self.chatRoomPreviews.enumerated() {
                if chatroom.room_id == message.room_id {
                    chatroom.lastMessage = message
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = tableView.cellForRow(at: indexPath) as? ChatRoomTableCell {
                        cell.configure(chatroom: chatroom)
                    }
                    let itemToMove = self.chatRoomPreviews.remove(at: indexPath.row)
                    chatRoomPreviews.insert(itemToMove, at: 0)
                    tableView.beginUpdates()
                    tableView.moveRow(at: indexPath, to: destinationIndexPath)
                    tableView.endUpdates()
                    
                    
                    break
                }
            }
            return
        }
        
        Task {
            let newChatRoomPreview = try await ChatRoomPreviewManager.shared.getSingleChatroomPreviewFromRoom_ID(room_id: message.room_id)
            ChatRoomPreview.hasRecievedRoom_IDs[newChatRoomPreview.chatRoom.room_id] = newChatRoomPreview.chatRoom?.room_id
            chatRoomPreviews.insert(newChatRoomPreview, at: 0)
            tableView.beginUpdates()
            self.tableView.insertRows(at: [destinationIndexPath], with: .top)
            tableView.endUpdates()
            
            SocketIOManager.shared.joinRooms(room_ids: [newChatRoomPreview.chatRoom.room_id])
        }
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatRoomPreviews.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        guard !BasicViewController.shared.isSwiping else {
            return
        }
        let chatRoomPreview = chatRoomPreviews[indexPath.row]
        let controller = MessageViewController(room_users: [], chatRoom: chatRoomPreview.chatRoom, navBarTitle: chatRoomPreview.user?.name)
       
        let userImage = chatRoomPreview.user?.image
        if let user_id = chatRoomPreview.user?.id {
            controller.userImageDict[user_id] = userImage
        }
        self.show(controller, sender: nil)
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chatcell", for: indexPath) as! ChatRoomTableCell
        let chatmodel = chatRoomPreviews[indexPath.row]
        cell.configure(chatroom: chatmodel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isLoadingNewChatRooms, chatRoomPreviews.count - indexPath.row == 2 else {
            return
        }
        let lastChatrooms = self.chatRoomPreviews.last
        guard let timeStamp = lastChatrooms?.lastMessage.created_time else {
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







