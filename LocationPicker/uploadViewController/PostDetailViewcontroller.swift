import UIKit
import AVFoundation
import MultiProgressView

class PostDetailViewcontroller: UIViewController, UITextViewDelegate, UITextFieldDelegate, PlaceFindDelegate, UploadDelegate, MultiProgressViewDataSource, UICollectionViewDelegate, MediaDelegate  {
    func playCurrentMedia() {
        if let mediaTableCell = self.tableView.cellForRow(at: self.mediaCollectionCellIndexPath) as? UploadMediaDetailTableCell {
            mediaTableCell.playCurrentMedia()
        }
    }
    
    func pauseCurrentMedia() {
        if let mediaTableCell = self.tableView.cellForRow(at: self.mediaCollectionCellIndexPath) as? UploadMediaDetailTableCell {
            mediaTableCell.pauseCurrentMedia()
        }
    }
    
    var titleTextOverrange : Bool! = false { didSet {
        self.updateReleaseButtonStatus()
    }}
    
    var locationIsEmpty : Bool! = true { didSet {
        self.updateReleaseButtonStatus()
        if !locationIsEmpty {
            self.previewButton.updateTitle(Title: "預覽", backgroundColor: .tintOrange, tintColor: .white, font: UIFont.weightSystemSizeFont(systemFontStyle: .subheadline, weight: .medium))
        } else {
            self.previewButton.updateTitle(Title: "預覽", backgroundColor: .secondaryBackgroundColor, tintColor: .secondaryLabelColor, font: UIFont.weightSystemSizeFont(systemFontStyle: .subheadline, weight: .medium))
        }
    }}
    
    let progressViewCornerRadius : CGFloat = 10
    
    @IBOutlet weak var progressView : MultiProgressView! {
        didSet {
            progressView.dataSource = self
        }
    }
    
    @IBOutlet weak var uploadView : UIView! {  didSet {
        uploadView.layer.cornerRadius = 20
        uploadView.clipsToBounds = true
    }}
    
    @IBOutlet var bottomBarView : UIView!
    
    let tableViewStyles : [(logoImage :UIImage, labelText : String)]! = [
        ( UIImage(systemName: "mappin.and.ellipse", withConfiguration: Constant.symbolConfig)!, "搜尋地點")
    ]
    
    var previewButton : RoundedButton!
    
    var placeModel : Restaurant?
    
    @IBOutlet var buttonViewOnTableView : UIView!
    
    @IBOutlet var tableView : UITableView!
    
    let array : [Int]! =
    {
        var array : [Int] = []
        for i in 1...46 {
            array.append(i)
        }
        return array
    }()
    
    var MediaStorage: [Media]!
    
    var activeTextField: UITextField?
    
    var activeTextView: UITextView?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    
    let mediaCollectionCellIndexPath = IndexPath(row: 0, section: 0)
    
    var mediaCollectionCell : UploadMediaDetailTableCell! {
        return self.tableView.cellForRow(at: mediaCollectionCellIndexPath) as! UploadMediaDetailTableCell
    }
    
    let titleCellIndexPath = IndexPath(row: 0, section: 1)
    
    var titleCell : UploadPostDetailTitleCell! {
        return self.tableView.cellForRow(at: titleCellIndexPath) as! UploadPostDetailTitleCell
    }
    
    let contentCellIndexPath = IndexPath(row: 1, section: 1)
    
    var contentCell : UploadPostDetailContentCell! {
        return self.tableView.cellForRow(at: contentCellIndexPath) as! UploadPostDetailContentCell
    }
    
    let gradeCellIndexPath = IndexPath(row: 0, section: 2)
    
    var gradeCell : UploadPostDetailGradeCell! {
        return self.tableView.cellForRow(at: gradeCellIndexPath) as! UploadPostDetailGradeCell
    }
    
    @objc func previewTableViewController(_ sender : UIBarButtonItem) {
        guard let restaurant = self.placeModel else {
            return
        }
        let controller = PreviewPostTableViewController()
        let titleCell = tableView.cellForRow(at: titleCellIndexPath) as! UploadPostDetailTitleCell
        let titleString = titleCell.textView.text
        let contentCell = tableView.cellForRow(at: contentCellIndexPath) as! UploadPostDetailContentCell
        let contentString = contentCell.textView.text
        let gradeCell = tableView.cellForRow(at: gradeCellIndexPath) as! UploadPostDetailGradeCell
        let grade = gradeCell.currentGrade

        let post = Post(restaurant: restaurant, Media: MediaStorage, user: User.example, postTitle: titleString, postContent: contentString, grade: grade)
        controller.posts.append(post)
        self.show(controller, sender: nil)
    }
    
    
    @IBOutlet var releaseButton: RoundedButton!
    
    @IBOutlet weak var cancelUploadButton : RoundedButton!
    
    @IBAction func releaseButtonTapped() {
        guard let mediaCollectionCell = mediaCollectionCell,
              mediaCollectionCell.validUploadStatus,
              let titleCell = self.tableView.cellForRow(at: titleCellIndexPath) as? UploadPostDetailTitleCell,
              let contentCell = self.tableView.cellForRow(at: contentCellIndexPath) as? UploadPostDetailContentCell,
              let gradeCell = self.tableView.cellForRow(at: gradeCellIndexPath) as? UploadPostDetailGradeCell,
              let location = self.placeModel else {
            return
        }
        

        startUploadViewSwipeToLeftAnimate()
        self.pauseCurrentMedia()
        var title : String?
        var content : String?
        if !titleCell.textView.text.isEmpty {
            title = titleCell.textView.text
        }
        if contentCell.textView.text != "" && self.contentCell.forbiddenView.isHidden {
            content = contentCell.textView.text
        }
        Task(priority: .background) {
            do {
                try await PostManager.shared.uploadPostTask(post_title: title, post_content: content, medias: MediaStorage, user_id: Constant.user_id, placemodel: location, grade: gradeCell.currentGrade)
            } catch {
                
                print(error)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        viewStyleSet()
        layoutStandardButton()
        SocketIOManager.shared.progressDelegate = self
        layoutBottomBarView()
        layoutProgressView()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.MediaStorage.forEach { media in
            media.player?.isMuted = true
            media.player?.play()
        }
        layoutNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tableCell = tableView.cellForRow(at: self.mediaCollectionCellIndexPath) as! UploadMediaDetailTableCell
        tableCell.collectionView.visibleCells.forEach { cell in
            if let collectionCell = cell as? UploadMediaDetailPlayerLayerCollectionCell {
                collectionCell.play()
            }
        }
        TapGestureHelper.shared.shouldAddTapGestureInWindow(window: self.view.window!)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = false
        
    }
    
    
    func layoutBottomBarView() {
        NSLayoutConstraint.activate([
            bottomBarView.heightAnchor.constraint(equalToConstant: Constant.bottomBarViewHeight)
        ])
    }
    
    
    func changePlaceModel(model : Restaurant) {
        if let cell = self.tableView.cellForRow(at: .init(row: 0, section: self.tableView.numberOfSections - 1)) as? UploadPostDetailExtraTableCell {
            cell.configure(image: tableViewStyles[0].logoImage, text: model.name, address: model.Address)
            self.placeModel = model
            self.locationIsEmpty = false
        }
    }
    
    func updateReleaseButtonStatus() {
        let isEnable = !titleTextOverrange && !locationIsEmpty
        self.releaseButton.isEnabled = isEnable
        releaseButton.animatedEnable = isEnable
        if isEnable {
            self.releaseButton.updateTitle(Title: "發佈", backgroundColor: .tintColor, tintColor: .white, font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
        } else {
            releaseButton.updateTitle(Title: "發佈", backgroundColor: .secondaryBackgroundColor, tintColor: .secondaryLabelColor, font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
        }
        
    }
    
    func layoutProgressView() {
        let offsetY : CGFloat = 8
        let spaceTotalHeight : CGFloat = 100
        
        tableView.contentInset = .init(top: 8, left: 0, bottom: spaceTotalHeight + offsetY, right: 0)
        
        let width : CGFloat = view.bounds.width * 0.95
        NSLayoutConstraint.activate([
            buttonViewOnTableView.heightAnchor.constraint(equalToConstant: spaceTotalHeight)
        ])
        var style : UIBlurEffect.Style = .dark
        if UITraitCollection.current.userInterfaceStyle == .light {
            style = .light
        }
        
        let blurView : UIVisualEffectView = UIVisualEffectView(frame: buttonViewOnTableView.bounds, style: style)
        
        buttonViewOnTableView.insertSubview(blurView, at: 0)
        buttonViewOnTableView.addSubview(uploadView)
        uploadView.frame = CGRect(x: (buttonViewOnTableView.bounds.width - width) / 2 + view.bounds.width, y: offsetY, width: width, height: spaceTotalHeight - (offsetY * 2))
        progressView.clipsToBounds = true
        progressView.trackBackgroundColor = .secondaryBackgroundColor
        progressView.cornerRadius = progressViewCornerRadius
        progressView.lineCap = .round
        progressView.setProgress(section: 0, to: 0.2)
    }
    func receiveUploadProgress(progress: Double) {
        progressView.setProgress(section: 0, to: Float(progress))
    }
    
    func receiveUploadFinished(success: Bool) {
        if success {
            self.MediaStorage.removeAll()
            self.cancelUploadButton.updateTitle(Title: "完成", backgroundColor: .systemGreen, tintColor: .white, font: .weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){ [weak self]  in
                self?.startUploadViewSwipeToRightAnimate(popToRoot: true)
            }
        } else {
            self.cancelUploadButton.updateTitle(Title: "失敗", backgroundColor: .systemRed, tintColor: .white, font: .weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
        }
    }
    
    func startUploadViewSwipeToLeftAnimate() {
        self.releaseButton.translatesAutoresizingMaskIntoConstraints = true
        self.progressView.setProgress(section: 0, to: 0)
        cancelUploadButton.updateTitle(Title: "取消", backgroundColor: .tintColor, tintColor: .white, font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
        cancelUploadButton.isEnabled = true
        cancelUploadButton.animatedEnable = true
        cancelUploadButton.target(forAction: #selector(startUploadViewSwipeToRightAnimate), withSender: nil)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, animations: { [self] in
            uploadView.frame.origin.x -= view.bounds.width
            self.releaseButton.frame.origin.x -= view.bounds.width
        }) { bool in
            
        }
    }
    
    @IBAction func startUploadViewSwipeToRightAnimate(popToRoot : Bool) {
        self.releaseButton.translatesAutoresizingMaskIntoConstraints = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, animations: { [self] in
            uploadView.frame.origin.x += view.bounds.width
            self.releaseButton.frame.origin.x += view.bounds.width
        }) { bool in
            if popToRoot {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let sectionView = ProgressViewSection()
        sectionView.clipsToBounds = true
        sectionView.layer.cornerRadius = progressViewCornerRadius
        sectionView.backgroundColor = .tintColor
        return sectionView
    }
    
    func numberOfSections(in progressView: MultiProgressView) -> Int {
        1
    }
    
    func layoutStandardButton() {
        self.updateReleaseButtonStatus()
        releaseButton.target(forAction: #selector(startUploadViewSwipeToRightAnimate), withSender: nil)
    }
    
    func layoutNavBar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithOpaqueBackground()
        if placeModel == nil {
            let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            previewButton = RoundedButton(frame: frame, Title: "預覽", backgroundColor: .secondaryBackgroundColor, tintColor: .secondaryLabelColor, font: UIFont.weightSystemSizeFont(systemFontStyle: .subheadline, weight: .medium), contentInsets: .init(top: 8, leading: 14, bottom: 8, trailing: 14), cornerRadius: 12  )
            previewButton.addTarget(self, action:  #selector(previewTableViewController( _  : )), for: .touchUpInside)
            previewButton.animatedEnable = false
            previewButton.isEnabled = false
            navigationItem.rightBarButtonItem?.customView = previewButton
        }
    }
    
    func viewStyleSet() {
        self.view.clipsToBounds = true
        tableView.isScrollEnabled = true
        tableView.separatorInset = Constant.standardTableViewInset
        tableView.separatorColor = .secondaryBackgroundColor
        self.navigationItem.title = "貼文資訊"
        self.navigationItem.backButtonTitle = ""
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func keyboardShown(notification: Notification) {
        let info: NSDictionary = notification.userInfo! as NSDictionary
        //取得鍵盤尺寸
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        //鍵盤頂部 Y軸的位置
        let keyboardY = self.view.frame.height - keyboardSize.height
        //編輯框底部 Y軸的位置
        let offsetY: CGFloat = 20
        
        if let activeTextField = activeTextField {
            let editingTextFieldY = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
            let targetY = editingTextFieldY - keyboardY
            if self.view.frame.minY >= 0 {
                if targetY > 0 {
                    let offsetY = -targetY - offsetY
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y += offsetY
                    })
                }
            }
        }
        if let activeTextView = activeTextView {
            let editingTextViewY = activeTextView.convert(activeTextView.bounds, to: self.view).maxY
            let targetY = editingTextViewY - keyboardY
            if self.view.frame.minY >= 0 {
                let offsetY = -targetY - offsetY
                if targetY > 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y += offsetY
                    })
                }
            }
        }
    }
    @objc func keyboardHidden(notification: Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        })
    }
    
    
}

extension PostDetailViewcontroller: UITableViewDelegate, UITableViewDataSource {
    
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
            titleTextOverrange   = textView.numberOfLines() > 2
            titleCell.limitViews.forEach {
                $0.isHidden = !titleTextOverrange
            }
            if textView == self.titleCell.textView {
                contentCell.textView.isEditable = !textView.text.isEmpty
                contentCell.forbiddenView.isHidden = !textView.text.isEmpty
            }
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text.trimTrailingWhitespace()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.text?.trimTrailingWhitespace()
        var string = textField.text
        if textField.text == "" {
            string = nil
        }
        self.MediaStorage[textField.tag].title = string
    }
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let tableCell = self.tableView.cellForRow(at: mediaCollectionCellIndexPath) as? UploadMediaDetailTableCell {
            for cell in tableCell.collectionView.visibleCells {
                if let cell = cell as? UploadMediaTextFieldProtocol {
                    if cell.textField == textField {
                        let finalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                        let valid = cell.updateTextFieldValidStatus(text: finalString)
                        let media = self.MediaStorage[textField.tag]
                        media.title = finalString
                        tableCell.updateValidStatus()
                        break
                    }
                }
            }
        }

        return true
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 2
        }
        if section == 2 {
            return 1
        }
        return tableViewStyles.count
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let width = self.view.bounds.width
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UploadMediaDetailTableCell", for: indexPath) as! UploadMediaDetailTableCell
                cell.collectionViewDelegate = self
                cell.textFieldDelegate = self
                cell.configure(medias : MediaStorage)
                cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
                cell.selectionStyle = .none
                return cell
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPostDetailTitleCell", for: indexPath) as! UploadPostDetailTitleCell
                cell.textViewDelegate = self
                cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPostDetailContentCell", for: indexPath) as! UploadPostDetailContentCell
                cell.textViewDelegate = self
                cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
                cell.selectionStyle = .none
                return cell
            }
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadPostDetailGradeCell", for: indexPath) as! UploadPostDetailGradeCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
            cell.selectionStyle = .none
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostDetailViewControllerCell", for: indexPath) as! UploadPostDetailExtraTableCell
        let style = tableViewStyles[indexPath.row]
        cell.configure(image: style.logoImage, text: style.labelText, address: nil)
        cell.separatorInset = UIEdgeInsets(top: 0, left: width / 2, bottom: 0, right: width / 2)
        return cell
    }
    
    func  tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let titleCell = self.tableView.cellForRow(at: self.titleCellIndexPath) as? UploadPostDetailTitleCell  {
            if titleCell.textView.text.allSatisfy({
                $0.isWhitespace
            }) && titleCell.textView.text.isEmpty {
                contentCell.forbiddenView.isHidden = false
            } else {
                contentCell.forbiddenView.isHidden = true
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.activeTextView?.resignFirstResponder()
        self.activeTextField?.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let mediaTableCell = tableView.cellForRow(at: self.mediaCollectionCellIndexPath) as? UploadMediaDetailTableCell,
           collectionView == mediaTableCell.collectionView {
            if let cell = cell as? UploadMediaDetailPlayerLayerCollectionCell {
                cell.play()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 8
        }
        
        return 0
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 3 else {
            return
        }
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "ReuseViewController", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PlaceFindtableViewController") as! PlaceFindtableViewController
            controller.sourceController = self
            
            self.present(controller, animated: true)
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}
