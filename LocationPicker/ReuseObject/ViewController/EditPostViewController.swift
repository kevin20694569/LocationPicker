import UIKit

class EditPostViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDelegate {
    
    var dict : [Int:  String] = [0 : "標題", 1 : "內容"]
    
    var post : Post  = Post()
    
    init(post : Post) {
        super.init(nibName: nil, bundle: nil)
        self.post = post
    }
    
    var activeTextView : UITextView?
    
    var activeTextField : UITextField?
    
    var saveButtonItem : UIBarButtonItem! = UIBarButtonItem()
    
    weak var refreshCellDelegate : StandardPostTableCellProtocol?
    
    var mediaTextFieldsValid : Bool! = true { didSet {
        self.updateReleaseButtonStatus()
    }
    }
    
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
            cell.fillStar(grade: post.grade)
            
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
                cell.forbiddenView.isHidden = title.isEmpty ?  false : true
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
        buttonItemSetup()
        initLayout()
        registerCell()
        tableViewSetup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
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
        //tableView.rowHeight = UITableView.automaticDimension
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
            await refreshCellDelegate?.refreshData()
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
            let font = UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold  )
            let attributes = [NSAttributedString.Key.font: font]
            titleTextOverrange = textView.numberOfLines() > 2
            titleCell.warningStackView.isHidden = !titleTextOverrange
            if textView == self.titleCell.textView {
                contentCell.textView.isEditable = !textView.text.isEmpty
                contentCell.forbiddenView.isHidden = !textView.text.isEmpty
            }
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
        let isEnable = !titleTextOverrange && mediaTextFieldsValid
        self.saveButtonItem.isEnabled = isEnable
    }
}
