import UIKit


class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, MessageTableCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    var room_user_ids : [String]! = []
    
    var notReadMessageIndexPaths : [IndexPath] = []
    
    var allMessagesRead : Bool = false
    
    var lastTableViewContentYOffset : CGFloat! = 0
    
    init(room_users : [String]!, chatRoom : ChatRoom?, navBarTitle : String?) {
        super.init(nibName: nil, bundle: nil)
        if let chatRoom = chatRoom {
            self.chatRoom = chatRoom
        }
        self.layoutNavBar(title: navBarTitle)
        self.room_user_ids = room_users
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        switch message.sender_id {
        case Constant.user_id :
            if message.messageType == .PostShare {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RhsMessageSharedPostCell", for : indexPath) as! RhsMessageSharedPostCell
                cell.messageTableCellDelegate = self
                cell.configure(message: message)
                return cell
            }
            if message.messageType == .UserShare {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RhsMessageSharedUserCell", for : indexPath) as! RhsMessageSharedUserCell
                cell.messageTableCellDelegate = self
                cell.configure(message: message)
                return cell
            }
            if message.messageType == .RestaurantShare {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RhsShareRestaurantCell", for : indexPath) as! RhsShareRestaurantCell
                cell.messageTableCellDelegate = self
                cell.configure(message: message)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RhsTextLabelMessageTableViewCell", for : indexPath) as! RhsTextViewMessageTableViewCell
            cell.messageTableCellDelegate = self
            cell.configure(message: message)
            return cell
        default :
            if let image = userImageDict[String(message.sender_id)] {
                message.userImage = image
            }
            var hideSenderUserImageView : Bool = false
            if indexPath.row - 1 > 0 {
                let lastMessage = messages[indexPath.row - 1]
                if lastMessage.sender_id == message.sender_id {
                    hideSenderUserImageView = true
                }
            }
            
            
            if message.messageType == .PostShare   {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LhsMessageSharedPostCell", for : indexPath) as! LhsMessageSharedPostCell
                
                cell.messageTableCellDelegate = self
                
                cell.configure(message: message)
                cell.hiddenSenderUserImageView(hideSenderUserImageView)
                return cell
            }
            if message.messageType == .UserShare {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LhsMessageSharedUserCell", for : indexPath) as! LhsMessageSharedUserCell
                cell.messageTableCellDelegate = self
                
                cell.configure(message: message)
                cell.hiddenSenderUserImageView(hideSenderUserImageView)
                return cell
            }
            
            if message.messageType == .RestaurantShare {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LhsShareRestaurantCell", for : indexPath) as! LhsShareRestaurantCell
                cell.messageTableCellDelegate = self
                cell.configure(message: message)
                cell.hiddenSenderUserImageView(hideSenderUserImageView)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LhsTextLabelMessageTableViewCell", for: indexPath) as! LhsTextViewMessageTableViewCell
            cell.messageTableCellDelegate = self
            
            cell.configure(message: message)
            cell.hiddenSenderUserImageView(hideSenderUserImageView)
            return cell
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalText = textView.text + text
        if totalText.allSatisfy({
            $0.isWhitespace
        }) {
            return false
        }
        return true
    }
    
    
    
    var presentForTabBarLessView : Bool! = true
    
    var chatRoom : ChatRoom!
    
    
    var tableView : UITableView! = UITableView()
    
    var messages : [Message]! = []
    
    var shouldTriggerLoad : Bool! =  false
    
    var returnButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    
    func setReturnButton() {
        returnButton.addTarget(self, action: #selector(sendMessage (_ : )), for: .touchUpInside)
    }
    
    @objc func sendMessage( _ button : UIButton) {
        guard !messageInputTextView.text.isEmpty,
              let chatRoom = chatRoom else {
            return
        }
        let to_user_id = chatRoom.user_ids.filter { string in
            if string == Constant.user_id {
                return false
            }
            return true
        }
        SocketIOManager.shared.sendMessageByToUserIDs(to_user_ids: to_user_id, sender_id: Constant.user_id, message:  messageInputTextView.text)
        self.messageInputTextView.text.removeAll()
        fitMessageInputTextView(textView: messageInputTextView)
    }
    
    var userImageDict : [String : UIImage]! = [ : ]
    
    var inputMainView : UIView! = UIView()
    
    var messageInputTextView : UITextView! = UITextView() { didSet {
        messageInputTextView.backgroundColor = .secondaryBackgroundColor
        messageInputTextView.layer.cornerRadius = 10
        messageInputTextView.layer.masksToBounds = true
    }}
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationItem.backButtonTitle = ""
        setGesture()
        setReturnButton()
        layout()
        registerCells()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessage(_:)), name: NSNotification.Name(rawValue: "ReceivedMessageNotification"), object: nil)
        viewStyleSet()
        Task {
            do {
                var newMessages : [Message] = []
                if chatRoom == nil {
                    let chatRoom = try await ChatRoomManager.shared.getSingleChatRoom(user_ids: self.room_user_ids)
                    self.chatRoom = chatRoom
                    
                }
                
                newMessages = try await loadMessagesByChatRoomID(date: "")
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.insertRows(newMessages: newMessages, animated: false)
                if self.messages.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    })

                    
                }
                if let sender_id = self.messages.last?.sender_id {
                    if sender_id != Constant.user_id,
                       let room_id = messages.last?.room_id {
                        SocketIOManager.shared.markAsRead(room_id: room_id, sender_id: Constant.user_id)
                        allMessagesRead = true
                    }
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    
    @objc func dismissKeyBoard() {
        self.activeTextView?.resignFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     //   layoutNavBar(title: self.chatRoom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyBoard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    var activeTextView : UITextView?
    
    var inputTextViewBottomAnchorConstraint : NSLayoutConstraint!
    
    var hasBeenShowedTheKeyBoard : Bool! = false
    
    @objc func keyboardShown(notification: Notification) {
        if let activeTextView = activeTextView {
            
            guard !hasBeenShowedTheKeyBoard  else {
                return
            }
            hasBeenShowedTheKeyBoard = true
            let info: NSDictionary = notification.userInfo! as NSDictionary
            
            let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            
            let keyboardY = self.view.frame.height - keyboardSize.height
            
            let offsetY: CGFloat = 20
            let editingTextViewY = activeTextView.convert(activeTextView.bounds, to: self.view).maxY
            let targetY = editingTextViewY - keyboardY
            if self.view.frame.minY >= 0 {
                moveHeight = -targetY - offsetY
                if targetY > 0 {
                    UIView.animate(withDuration: 0.25, animations: { [self] in
                        inputTextViewBottomAnchorConstraint.constant += moveHeight!
                        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y -  moveHeight!)
                        self.view.layoutIfNeeded()
                    }) { bool in
                        
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func layoutNavBar(title : String?) {
        self.navigationController?.navigationBar.isTranslucent = true
        if let title = title {
            self.navigationItem.title = title
        }
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func showUserProfile(user_id: String, user: User?) {
        let controller = MainUserProfileViewController(presentForTabBarLessView: self.presentForTabBarLessView, user: user, user_id: user_id)
        controller.navigationItem.title = user?.name
        self.view.endEditing(true)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    var moveHeight : CGFloat?
    
    @objc func keyboardHidden(notification: Notification?) {
        if let moveHeight = moveHeight {
            guard hasBeenShowedTheKeyBoard else {
                return
            }
            UIView.animate(withDuration: 0.25, animations: { [self] in
                self.inputTextViewBottomAnchorConstraint.constant -= moveHeight
                tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y +  moveHeight)
                self.view.layoutIfNeeded()
            }) { bool in
                self.hasBeenShowedTheKeyBoard = false
            }
        }
    }
    
    func registerCells() {
        tableView.register(RhsTextViewMessageTableViewCell.self, forCellReuseIdentifier: "RhsTextLabelMessageTableViewCell")
        tableView.register(LhsTextViewMessageTableViewCell.self, forCellReuseIdentifier: "LhsTextLabelMessageTableViewCell")
        tableView.register(RhsMessageSharedPostCell.self, forCellReuseIdentifier: "RhsMessageSharedPostCell")
        tableView.register(LhsMessageSharedPostCell.self, forCellReuseIdentifier: "LhsMessageSharedPostCell")
        tableView.register(RhsMessageSharedUserCell.self, forCellReuseIdentifier: "RhsMessageSharedUserCell")
        tableView.register(LhsMessageSharedUserCell.self, forCellReuseIdentifier: "LhsMessageSharedUserCell")
        tableView.register(RhsShareRestaurantCell.self, forCellReuseIdentifier: "RhsShareRestaurantCell")
        tableView.register(LhsShareRestaurantCell.self, forCellReuseIdentifier: "LhsShareRestaurantCell")
        tableView.register(EmptyStartMessageCell.self, forCellReuseIdentifier: "EmptyStartMessageCell")
    }
    
    var messageInputTextViewHeightAnchor : NSLayoutConstraint!
    
    func layout() {
        inputMainView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        
        tableView.scrollsToTop = false
        self.view.addSubview(tableView)
        self.view.addSubview(inputMainView)
        self.view.addSubview(messageInputTextView)
        self.view.addSubview(returnButton)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        messageInputTextView.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputTextView.layer.cornerRadius = 16
        messageInputTextView.clipsToBounds = true
        
        messageInputTextView.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .medium)
        
        messageInputTextView.backgroundColor = .secondaryBackgroundColor
        let returnButtonOffset : CGFloat = 4
        messageInputTextView.textContainerInset = UIEdgeInsets(top: returnButtonOffset * 2, left: returnButtonOffset * 2, bottom: returnButtonOffset * 2, right: returnButtonOffset)
        let frame = messageInputTextView.frame
        let constainSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        
        let size = messageInputTextView.sizeThatFits(constainSize)
        messageInputTextViewHeightAnchor = messageInputTextView.heightAnchor.constraint(equalToConstant: size.height)
        maxHeight = size.height * 4
        
        var config = UIButton.Configuration.filled()
        
        config.image = UIImage(systemName: "arrowshape.turn.up.right.fill")!
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration.init(font: .weightSystemSizeFont(systemFontStyle: .callout, weight: .bold))
        config.imagePlacement  = .all
        config.baseBackgroundColor = .tintOrange
        config.contentInsets = .init(top: returnButtonOffset / 2, leading: returnButtonOffset
                                     * 2, bottom: returnButtonOffset / 2, trailing: returnButtonOffset * 2)
        
        returnButton.configuration = config
        returnButton.clipsToBounds = true
        returnButton.layer.cornerRadius = 12
        inputTextViewBottomAnchorConstraint = messageInputTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            messageInputTextViewHeightAnchor,
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: messageInputTextView.topAnchor),
            messageInputTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            messageInputTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            inputTextViewBottomAnchorConstraint
            
        ])
        
        NSLayoutConstraint.activate([
            returnButton.bottomAnchor.constraint(equalTo: messageInputTextView.bottomAnchor, constant: -returnButtonOffset),
            returnButton.trailingAnchor.constraint(equalTo: messageInputTextView.trailingAnchor, constant: -returnButtonOffset ),
            returnButton.heightAnchor.constraint(equalToConstant: size.height - returnButtonOffset * 2)
        ])
        returnButton.layoutIfNeeded()
        let textContainerRightInsetFromReturnButton : CGFloat = returnButtonOffset / 2
        messageInputTextView.textContainerInset = UIEdgeInsets(top: messageInputTextView.textContainerInset.top, left: messageInputTextView.textContainerInset.left, bottom: messageInputTextView.textContainerInset.bottom, right: returnButton.bounds.width + returnButtonOffset + textContainerRightInsetFromReturnButton )
    }
    
    var maxHeight : CGFloat! = UIScreen.main.bounds.height * 0.3
    
    func textViewDidChange(_ textView: UITextView) {
        fitMessageInputTextView(textView: textView)
    }
    
    func fitMessageInputTextView(textView : UITextView) {
        let frame = textView.frame
        
        let constainSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        
        var size = textView.sizeThatFits(constainSize)
        
        if size.height >= maxHeight {
            size.height = maxHeight
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
        }
        if size.height != textView.bounds.height {
            textView.translatesAutoresizingMaskIntoConstraints = false
            messageInputTextViewHeightAnchor.constant = size.height
            self.tableView.contentOffset.y += (size.height - textView.bounds.height)
            self.tableView.layoutIfNeeded()
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if activeTextView != messageInputTextView {
            activeTextView = textView
        }
    }
    
    
    
    func viewStyleSet() {

        messageInputTextView.delegate = self
        self.view.backgroundColor = .backgroundPrimary
        tableView.estimatedRowHeight = 95.0
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width / 2, bottom: 0, right: self.view.bounds.width / 2)
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    @objc func receiveMessage(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? Message {
            let bool = isTableViewScrolledToBottom()
            self.messages.append(message)
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .bottom)
            tableView.endUpdates()
            notReadMessageIndexPaths.append(indexPath)
            if bool {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    
    func setGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(gesture)
    }
    
    func loadMessagesByRoom_User_IDs(date : String) async throws  -> [Message] {
        do {
            var messages = try await  MessageManager.shared.getInitMessagesFromUser_ID(user_ids: self.room_user_ids)
            
            messages.reverse()
            guard messages.count > 0 else {
                self.chatRoom?.room_id = messages.first?.room_id
                shouldTriggerLoad = false
                return []
            }
            return messages
            
            
        } catch {
            throw error
        }
    }
    
    
    func loadMessagesByChatRoomID(date : String) async throws -> [Message] {
        guard let chatRoom = chatRoom else {
            return []
        }
        do {
            shouldTriggerLoad = false
            
            var messages = try await MessageManager.shared.getMessagesFromChatroomID(chatroom_id:  chatRoom.room_id, date: date)
            
            messages.reverse()
            guard messages.count > 0 else {
                
                shouldTriggerLoad = false
                return []
            }
            return messages
            
        } catch {
            throw error
        }
    }
    
    func insertRows(newMessages: [Message], animated : Bool) {
        let indexPaths = Array (0..<newMessages.count).map {
            IndexPath(row: $0, section: 0)
        }
        self.messages.insert(contentsOf: newMessages, at: 0)

        if animated {
            tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: .bottom)
            tableView.endUpdates()
            self.shouldTriggerLoad = true
            self.allMessagesRead = false
        } else {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .none)
                tableView.endUpdates()
                self.shouldTriggerLoad = true
                self.allMessagesRead = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.shouldTriggerLoad else {
            return
        }
        if self.messages.count - indexPath.row == 20 - 4 {
            shouldTriggerLoad = false

            Task {
                do {
                    let newMessages = try await loadMessagesByChatRoomID(date: (messages.first?.created_time)!)
                    self.insertRows(newMessages: newMessages, animated : true)
                } catch {
                    print(error)
                }
            }
        }

    }
    
    func isTableViewScrolledToBottom() -> Bool {
        let offset = tableView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let boundsHeight = tableView.bounds.height
        let isAtBottom = offset > 0 && contentHeight > boundsHeight && offset >= (contentHeight - boundsHeight) - 60
        return isAtBottom
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastTableViewContentYOffset = scrollView.contentOffset.y
        if let firstNotReadMessageIndexPath = notReadMessageIndexPaths.first,
           let lastNotReadMessageIndexPath = notReadMessageIndexPaths.last  {
            if let visibleIndexPaths = tableView.indexPathsForVisibleRows, visibleIndexPaths.contains(firstNotReadMessageIndexPath) || visibleIndexPaths.contains(lastNotReadMessageIndexPath) {
                allMessagesRead = true
                if let room_id = self.chatRoom?.room_id {
                    SocketIOManager.shared.markAsRead(room_id: room_id , sender_id: Constant.user_id)
                    self.notReadMessageIndexPaths.removeAll()
                }
            }
        }
        


    }
    
}

extension MessageViewController {
    func showWholePageMediaViewController(cell : UITableViewCell) {
        if let cell = cell as? MessageSharedPostCell,
           let indexPath = tableView.indexPath(for: cell) {
            let message = self.messages[indexPath.row]
            if let post_id = message.postJson?.id {
                let controller = EmptyWholePageMediaViewController(presentForTabBarLessView: true, post_id: post_id)
                self.show(controller, sender: nil)
                BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
            }
        }
    }
}
