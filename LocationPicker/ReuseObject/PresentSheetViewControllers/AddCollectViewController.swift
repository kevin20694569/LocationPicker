import UIKit

class AddCollectViewController : PresentedSheetViewController, UITableViewDelegate, UITableViewDataSource, LimitSelfFramePresentedView {

    
    
    var playlists : [Playlist]! = Playlist.examples
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    var selectedPlaylistDict : [IndexPath : Playlist] = [:] { didSet {
        canTouchOutsideToDismiss = selectedPlaylistDict.count == 0
    }}
    
    var titleView : UIView! = UIView()
    
    var titleLabel : UILabel! = UILabel()
    
    var addNewPlaylistButton : ZoomAnimatedButton! = ZoomAnimatedButton()
    
    
    var canTouchOutsideToDismiss : Bool! = true
    
    lazy var saveButton : ZoomAnimatedButton = {
        let button = ZoomAnimatedButton()
        var config = UIButton.Configuration.filled()
        let attr = AttributedString("儲存",attributes: AttributeContainer(
            [ .font :  UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)]
        ))
        config.attributedTitle = attr
        config.baseBackgroundColor = .secondaryLabelColor
        config.baseForegroundColor = .systemBackground
        button.configuration =  config
        button.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
        ])
        button.addTarget(self, action: #selector(save ( _ :)), for: .touchUpInside)
        return button
    }()
    
    @objc func save( _ button : UIButton) {
        self.dismiss(animated: true)
    }
    
    lazy var cacelAllSelectedButton : ZoomAnimatedButton = {
        let button = ZoomAnimatedButton()
        var config = UIButton.Configuration.filled()
        let attr = AttributedString("取消選取",attributes: AttributeContainer(
            [ .font :  UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)]
        ))
        config.attributedTitle = attr
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white
        button.configuration =  config
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(cancelAllSelected(_ : ) ), for: .touchUpInside)
        self.titleView.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            button.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
        return button
    }()
    
    @objc func cancelAllSelected(_ button : UIButton) {
        self.tableView.visibleCells.forEach(){
            let cell = $0 as? AddCollectTableViewCell
            cell?.beSelected(selected: false)
        }
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsMultipleSelection = true
        selectedPlaylistDict.removeAll()

        self.startCloseSelectingAnimation()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let playlist = self.playlists[indexPath.row ]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCollectTableViewCell", for: indexPath) as! AddCollectTableViewCell
        cell.configure(playlist: playlist)
        return cell
    }
    
    
    var tableView : UITableView! = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        setGesture()
        registerCells()
        viewStyleSet()
    }
    
    func viewStyleSet() {

        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .secondaryLabelColor
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = self.view.bounds.height * 0.07
        tableView.allowsMultipleSelection = true
    
        self.view.backgroundColor = .backgroundPrimary

        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.delaysContentTouches = false
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func startSelectingAnimation() {
        saveButton.alpha = 0
        cacelAllSelectedButton.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.cacelAllSelectedButton.alpha = 1
            self.saveButton.alpha = 1
            self.saveButton.transform = .identity
            self.cacelAllSelectedButton.transform = .identity
            self.addNewPlaylistButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.addNewPlaylistButton.alpha = 0
        }) { bool in

        }

    }
    
    func startCloseSelectingAnimation() {
        addNewPlaylistButton.alpha = 0
        self.titleView.addSubview(addNewPlaylistButton)
        UIView.animate(withDuration: 0.2, animations: {
            
            self.saveButton.alpha = 0
            self.cacelAllSelectedButton.alpha = 0
            self.saveButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.cacelAllSelectedButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.addNewPlaylistButton.transform = .identity
            self.addNewPlaylistButton.alpha = 1
            
        }) { bool in
            
        }
        
        
    }
    
    
    override func layout() {
        super.layout()
        
        self.view.addSubview(titleView)
        self.view.addSubview(tableView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: titleSlideView.bottomAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.safeAreaInsets.left),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constant.safeAreaInsets.right),
            titleView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1),
            tableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.safeAreaInsets.left),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constant.safeAreaInsets.right),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        titleLabel.text = "加入收藏"
        titleLabel.textColor = .label
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)
        titleView.addSubview(titleLabel)
        titleView.addSubview(addNewPlaylistButton)
        addNewPlaylistButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        let attr = AttributedString("新增清單",attributes: AttributeContainer(
            [ .font :  UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .medium)]
        ))
        config.attributedTitle = attr
        config.imagePlacement = .leading
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 4
        
        config.baseBackgroundColor = .tintOrange
        addNewPlaylistButton.configuration =  config
        
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20) ,
            addNewPlaylistButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addNewPlaylistButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant:  -16),
        ])
        
        
    }
    
    override func setGesture() {
        super.setGesture()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture ( _ :) ))
        self.titleView.addGestureRecognizer(panGesture)
        self.titleView.isUserInteractionEnabled = true
    }

    
    
    func registerCells() {
        self.tableView.register(AddCollectTableViewCell.self, forCellReuseIdentifier: "AddCollectTableViewCell")
    }
    

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView.indexPathsForSelectedRows == nil || tableView.indexPathsForSelectedRows!.isEmpty {
            
            self.startSelectingAnimation()
            
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? AddCollectTableViewCell
        cell?.beSelected(selected: true)
        let playlist = self.playlists[indexPath.row]
        selectedPlaylistDict[indexPath] = playlist
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.tableView.indexPathsForSelectedRows == nil {
            startCloseSelectingAnimation()
        }
        let cell = tableView.cellForRow(at: indexPath) as? AddCollectTableViewCell
        cell?.beSelected(selected: false)
        
        selectedPlaylistDict.removeValue(forKey: indexPath)
       
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if selectedPlaylistDict[indexPath] != nil {
            let cell = cell as? AddCollectTableViewCell
            cell?.beSelected(selected: true)
        }
    }

}




