
import UIKit

class PostDetailSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExtendLabelHeightTableCellDelegate, LimitContainerViewHeightPresentedView {
    var maxWidth: CGFloat!
    
    var currentPost : Post!
    var maxHeight : CGFloat! = UIScreen.main.bounds.height * 0.1
    var handlePanGesture : UIPanGestureRecognizer!
    let cornerRadiusFloat  = Constant.standardCornerRadius
    
    @IBOutlet var itemtTitleLabel : UILabel! { didSet {
        itemtTitleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold)
    }}
    
    
    @IBOutlet var bottomReactionView : UIView!
    
    @IBOutlet var heartButton : UIButton! { didSet {
        heartButton.addTarget(self, action: #selector(LikeToggle ( _ : )), for: .touchUpInside)
    }}
    
    @objc func LikeToggle(_ button: UIButton) {
        self.currentPost.liked.toggle()
        setHeartImage()
    }
    
    func setHeartImage() {
        if currentPost.liked {
            heartButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            heartButton.setImage(UIImage(systemName: "heart")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
        postDetailSheetViewControllerDelegate?.updateHeartButtonStatus()
    }
    
    @IBOutlet var titleSlideView : UIView! { didSet {

    }}
    @IBOutlet var tableView : UITableView!
    
    weak var postDetailSheetViewControllerDelegate : PostDetailSheetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewStyleSet()
        initLayout()
        setHeartImage()
        layoutHeightAnchor()
        
    }
    
    deinit {
        postDetailSheetViewControllerDelegate?.recoverInteraction()

    }
    
    func layoutHeightAnchor() {
        let navBarHeight = Constant.navBarHeight
        let height = maxHeight - navBarHeight
        NSLayoutConstraint.activate([
            self.titleSlideView.heightAnchor.constraint(equalToConstant: navBarHeight),
            self.bottomReactionView.heightAnchor.constraint(equalToConstant: height * 0.2),
            bottomReactionView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
        ])
        self.titleSlideView.layoutIfNeeded()
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = titleSlideView.bounds
        titleSlideView.backgroundColor = .clear
        blurView.isUserInteractionEnabled = false
        titleSlideView.insertSubview(blurView , belowSubview: self.itemtTitleLabel)
    }
    
    func viewStyleSet() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.allowsSelection = false
        updateItemTitleLabelText(index: currentPost.CurrentIndex)
    }
    
    func updateItemTitleLabelText(index : Int) {
        let string = currentPost.media[index].title
        self.itemtTitleLabel.text = string
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableView.contentSize.height < maxHeight {
            tableView.isScrollEnabled = false
        }
    }
    
    func configure(post : Post) {
        currentPost = post

    }
    func cellRowHeightSizeFit() {
        tableView.beginUpdates()
        tableView.endUpdates()
        if let contentCellHeight = tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.frame.height {
            if contentCellHeight > maxHeight {
                tableView.isScrollEnabled = true
            }
        }
    }
    

    
}
extension PostDetailSheetViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 //+ (currentPost.postContent == nil || currentPost.postContent == ""  ? 0 : 1)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTitleCell", for: indexPath) as! PostTitleCell
            cell.configure(post: currentPost)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostContentCell", for: indexPath) as! PostContentCell
            cell.postContentCellDelegate = self
            cell.configure(post: currentPost)
            return cell
        }
        
    }
}

extension PostDetailSheetViewController {
    
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        postDetailSheetViewControllerDelegate?.recoverInteraction()
        super.dismiss(animated: flag, completion: completion)
    }
    func initLayout() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        self.view.backgroundColor = .clear
        blurView.isUserInteractionEnabled = false
        self.tableView.backgroundColor = .clear
        self.view.insertSubview(blurView , belowSubview: tableView)
        self.view.layer.cornerRadius = Constant.standardCornerRadius
        self.view.clipsToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        handlePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture( _ :  )))
        titleSlideView.addGestureRecognizer(handlePanGesture)

    }
    
    @objc func handlePanGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        let offset = gestureRecognizer.velocity(in: self.view)
        let screenBounds = UIScreen.main.bounds
        switch gestureRecognizer.state {
        case .changed :
            self.view.frame.origin.y  = max(0, self.view.frame.origin.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        case .ended  :
            if offset.y > 0 {
                self.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.1) { [self] in
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: maxHeight)
                }
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            break
        default:
            break
        }
    }
    
    
    
}
