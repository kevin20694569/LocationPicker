import UIKit

protocol RefreshPostDelegate : UIViewController {
    
}

class EditPostViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UploadPostDetailGradeCellDelegate {
    
    var dict : [Int:  String] = [0 : "標題", 1 : "內容"]
    
    var post : Post  = Post()
    
    lazy var keyBoardController : KeyBoardController! = KeyBoardController(mainView: self.view)
    
    
    
    init(post : Post) {
        super.init(nibName: nil, bundle: nil)
        self.post = post
        self.initTitleText = post.postTitle
        self.initContentText = post.postContent
        self.initGrade = post.grade
        self.initMediaTitleArray = post.media.map() { media in
            return media.title
        }
    }
    
    var activeTextView : UITextView?
    
    var activeTextField : UITextField?
    
    var saveButtonItem : UIBarButtonItem! = UIBarButtonItem()
    
    weak var refreshPostDelegate : StandardPostCellDelegate?
    
    var initTitleText : String?
    
    var initContentText : String?
    
    var initGrade : Double?
    
    var initMediaTitleArray : [String?] = []
    
    var mediaTextFieldsValid : Bool! = true { didSet {
        self.updateReleaseButtonStatus()
    }}
    
    var titleTextOverrange : Bool! = false { didSet {
        self.updateReleaseButtonStatus()
    }}
    
    var mediaCollectionViewCell : UploadMediaDetailTableCell! {
        return tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UploadMediaDetailTableCell
    }
    
    var titleCell : UploadPostDetailTitleCell! {
        return tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? UploadPostDetailTitleCell
    }
    
    var contentCell : UploadPostDetailContentCell! {
        return tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? UploadPostDetailContentCell
    }
    
    var gradeCell : UploadPostDetailGradeCell! {
        return tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? UploadPostDetailGradeCell
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let width = self.view.bounds.width
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadMediaDetailTableCell", for: indexPath) as! UploadMediaDetailTableCell
            cell.collectionViewDelegate = self
            cell.textFieldDelegate = self
            cell.configure(medias: post.media)
            cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
            cell.selectionStyle = .none
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPostDetailGradeCell", for: indexPath) as! UploadPostDetailGradeCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
            cell.selectionStyle = .none
            cell.uploadPostDetailGradeCellDelegate = self
            if post.grade == nil {
                cell.commentStatus = false
            } else {
                cell.commentStatus = true
            }

            cell.fillStar(grade: post.grade)
            cell.lastGrade = post.grade
            return cell
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPostDetailTitleCell", for: indexPath) as! UploadPostDetailTitleCell
            cell.textView.text = post.postTitle
            cell.textViewDelegate = self
            cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPostDetailContentCell", for: indexPath) as! UploadPostDetailContentCell
            cell.textView.text = post.postContent
            cell.textViewDelegate = self
            if let title = post.postTitle {
                cell.textViewEnableEdit(bool: true)
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func buttonItemSetup() {
        self.navigationItem.rightBarButtonItem = saveButtonItem
        saveButtonItem.isEnabled = false
        saveButtonItem.target = self
        saveButtonItem.action = #selector(saveButtonTapped)
        saveButtonItem.tintColor = .tintOrange
        saveButtonItem.title = "儲存"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2 {
            return 1
        }
        return dict.count
    }
    
    var tableView : UITableView! = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        buttonItemSetup()
        initLayout()
        registerCell()
        tableViewSetup()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.standardAppearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithOpaqueBackground()
    }
    
    
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
        self.view.isUserInteractionEnabled = true
        self.tableView.isUserInteractionEnabled = true
        TapGestureHelper.shared.shouldAddTapGestureInWindow(view: self.view)
    }
    
    
    func initLayout() {
        view.addSubview(tableView)
        view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        self.view.backgroundColor = .backgroundPrimary
    }
    
    func registerCell() {
        
        tableView.register(UploadPostDetailTitleCell.self, forCellReuseIdentifier: "UploadPostDetailTitleCell")
        
        tableView.register(UploadPostDetailContentCell.self, forCellReuseIdentifier: "UploadPostDetailContentCell")
        tableView.register(UploadPostDetailGradeCell.self, forCellReuseIdentifier: "UploadPostDetailGradeCell")
        tableView.register(UploadMediaDetailTableCell.self, forCellReuseIdentifier: "UploadMediaDetailTableCell")
        
    }
    
    func tableViewSetup() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let bounds = self.view.bounds
        if indexPath.section == 0 {
            let height = bounds.height * 0.3
            return height
        }
        
        
        if indexPath.section == 1 {
            
            return UITableView.automaticDimension
        }
        
        let height = bounds.height * 0.08
        return height
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }

    
    @objc func saveButtonTapped() {
        Task {
            await savePost()
            await refreshPostDelegate?.reloadPostCell(post: post)
        }
    }
    
    func savePost() async {
        do {
            
            var title = titleCell.textView.text
            var content = contentCell.textView.text
            let grade = gradeCell.currentGrade
            if title == "" {
                title = nil
            }
            if content == "" {
                content = nil
            }
            if title == nil {
                content = nil
            }

            try await PostManager.shared.updatePostDetail(post_id: post.id, title: title, content: content, grade: grade, medias: self.post.media)
            navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
    
}

extension EditPostViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalText = textView.text + text
        
        if totalText.allSatisfy({
            $0.isWhitespace
        }) {
            return false
        }
        
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.titleCell.textView {
            titleTextOverrange = textView.numberOfLines() > 2
            titleCell.warningStackView.isHidden = !titleTextOverrange
            if textView == self.titleCell.textView {
                contentCell.textViewEnableEdit(bool: !textView.text.isEmpty)
            }
            
        }
        if textView == self.contentCell.textView {
            updateReleaseButtonStatus()
        }
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.activeTextView?.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text.trimTrailingWhitespace()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.text?.trimTrailingWhitespace()
        var string = textField.text
        if textField.text == "" {
            string = nil
        }
        self.post.media[textField.tag].title = string
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        for cell in mediaCollectionViewCell.collectionView.visibleCells {
            if let cell = cell as? UploadMediaTextFieldProtocol {
                if cell.textField == textField {
                    let finalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                    cell.updateTextFieldValidStatus(text: finalString)
                    let media = self.post.media[textField.tag]
                    media.title = finalString
                    let valid = mediaCollectionViewCell.updateValidStatus()
                    self.mediaTextFieldsValid = valid
                    break
                }
            }
        }
        

        return true
    }
    
    func updateReleaseButtonStatus() {
        let isValid = !titleTextOverrange && mediaTextFieldsValid
        let mediaIsChanged : Bool = {
            for (i,initTitle) in self.initMediaTitleArray.enumerated() {
                var mediaTitle = self.post.media[i].title
                if self.post.media[i].title == "" {
                    mediaTitle = nil
                }
                 
                if initTitle != mediaTitle {
                    return true
                }
            }
            return false
        }()
        var contentText : String? = contentCell.textView.text
        var titleText : String? = titleCell.textView.text
        if contentCell.textView.text == "" {
            contentText = nil
        }
        if titleCell.textView.text == "" {
            titleText = nil
        }
        let titleTextChanged = initTitleText != titleText
        let contentTextChanged = initContentText != contentText
        let gradeChanged = gradeCell.currentGrade != self.initGrade
        
        self.saveButtonItem.isEnabled = ( titleTextChanged || contentTextChanged || mediaIsChanged || gradeChanged  ) && isValid
        

    }
}

extension EditPostViewController {

    
    @objc func keyboardShown(notification: Notification) {
        self.keyBoardController.keyboardShown(notification: notification, activeTextField: self.activeTextField, activeTextView: self.activeTextView)
    }
    @objc func keyboardHidden(notification: Notification) {
        self.keyBoardController.keyboardHidden(notification: notification, activeTextField: self.activeTextField, activeTextView: self.activeTextView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}
