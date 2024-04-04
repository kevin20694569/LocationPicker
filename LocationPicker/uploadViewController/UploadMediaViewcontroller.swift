
import UIKit
import PhotosUI

class UploadMediaViewcontroller: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, MediaCollectionViewAnimatorDelegate, MediaTableCellDelegate, PanWholePageViewControllerDelegate {
    func changeCurrentEmoji(emojiTag: Int?) {
        return
    }
    
    func gestureStatusToggle(isTopViewController: Bool) {
        
    }
    
    
    @IBOutlet var bottomBarView : UIView!
    
    func playCurrentMedia() {
        if let cell = self.collectionView.cellForItem(at: self.currentMediaIndexPath) as? PlayerLayerCollectionCell {
            cell.play()
        }
    }
    func pauseCurrentMedia() {
        if let cell = self.collectionView.cellForItem(at: self.currentMediaIndexPath) as? PlayerLayerCollectionCell {
            cell.pause()
        }
    }
    
    func segueToProFile(user_id: Int, user_name: String, user_image: UIImage?) {
        return
    }
    @IBOutlet var PageControll : UIPageControl! { didSet {
        PageControll.hidesForSinglePage = true
    }}
    
    @IBOutlet var nextTapButton : RoundedButton!
    
    @IBOutlet var addMediaButton : ZoomAnimatedButton!
    
    @objc func presentPHPPicker() {
        selectPHPickerImage()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PostDetailViewcontroller {
            controller.MediaStorage = self.MediaStorage
        }
    }
    
    var currentCollectionCell: UICollectionViewCell? {
        return collectionView.cellForItem(at: currentMediaIndexPath)
    }
    
    
    var temporaryPost : Post! = Post()
    
    var enterCollectionIndexPath : IndexPath! =  IndexPath(row: 0, section: 0)
    
    func getFadeInSubviews() -> [UIView?] {
        if let cell = currentCollectionCell as? NewPostCellDelegate {
        }
        return []
        
        
    }
    
    func getFadedSubviews() -> [UIView]! {
        var array = self.view.subviews.filter { view in
            return true
        }
        array.append(self.view)
        return array
    }
    
    
    var MediaStorage : [Media]! = [] { didSet {
        if MediaStorage.isEmpty {
            addMediaImageView?.isHidden = false
        } else {
            addMediaImageView?.isHidden = true
            addMediaImageView = nil
        }
    }}
    
    var addMediaImageView : AddMediaImageView?
    
    func changeMediaTitle(title : String) {
        MediaStorage[currentMediaIndexPath.row].title = title
    }
    
    var currentMediaIndexPath : IndexPath! = .init(row: 0, section: 0)
    
   
    
    var longTapGesture : UILongPressGestureRecognizer!
    
    var MuteTapgesture : UITapGestureRecognizer!
    
    
    var EmptyMediaView : UIImageView! { didSet {
        EmptyMediaView.clipsToBounds = true
    }}
    
    @IBOutlet var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        layoutAddMediaView()
        setGesture()
        layoutButton()
        colletionViewLayoutFlow()
        viewStyleSet()
    }
    
    

    
    func layoutButton() {
        nextTapButton.updateTitle(Title: "下一步", backgroundColor: .secondaryBackgroundColor, tintColor: .black, font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
        nextTapButton.isEnabled = false
     //   nextTapButton.scaleTargets = nextTapButton
        let image = UIImage(systemName:"plus.circle", withConfiguration: UIImage.SymbolConfiguration.init(font: UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)) )
        addMediaButton.imageView?.image = image
        addMediaButton.addTarget(self, action: #selector(presentPHPPicker), for: .touchUpInside)
        addMediaButton.alpha = 0
        addMediaButton.isEnabled = false
      //  addMediaButton.scaleTargets = addMediaButton
    }

    func viewStyleSet() {
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        PageControll.numberOfPages = MediaStorage.count
    }
    
    
}


extension UploadMediaViewcontroller :  PHPickerViewControllerDelegate, UICollectionViewDelegate, PhotoPostViewControllerDelegate, UICollectionViewDataSource {
    
    func layoutAddMediaView() {
        let height = collectionView.bounds.height
        let spacing = self.collectionView.bounds.width - height
        var origin = collectionView.frame.origin
        origin.x += spacing / 2
        let frame = CGRect(origin: origin, size: CGSize(width: height  , height: height ))
        addMediaImageView = AddMediaImageView(frame: frame )
        addMediaImageView?.PhotpPostViewControllerDelegate = self
        addMediaImageView?.layoutImageView(frame: frame)
        self.view.addSubview(addMediaImageView!)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentPHPPicker))
        gesture.cancelsTouchesInView = false
        addMediaImageView?.addGestureRecognizer(gesture)
        let button = ZoomAnimatedButton(frame: addMediaImageView!.bounds)
        button.scaleX = 0.90
        button.scaleY = 0.90
        button.scaleTargets?.append(addMediaImageView!)
        button.tappedDuration = 0.15
        button.recoverDutation = 0.15
        addMediaImageView?.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultNavStyleSet()
        updateVisibleCellsMuteStatus()
        MediaStorage.forEach() {
            $0.player?.isMuted = UniqueVariable.IsMuted
            if $0 == self.MediaStorage[currentMediaIndexPath.row] {
                return
            }
            $0.player?.pause()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playCurrentMedia(indexPath: currentMediaIndexPath)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = false
    }
    
    func defaultNavStyleSet() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithOpaqueBackground()

        self.navigationItem.backButtonTitle = ""
    }

    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {


        picker.dismiss(animated: true, completion: nil)
        if results.isEmpty {
            return
        }
        if collectionView.visibleCells.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
        Task {
            self.MediaStorage.forEach() {
                $0.player?.pause()
            }
            self.MediaStorage.removeAll()
            self.MediaStorage = await withTaskGroup(of: (index: Int, media : Media).self, returning: [Media].self) { group in
                
                for (i, result) in results.enumerated() {
                    group.addTask() {
                        do {
                            return try await withCheckedThrowingContinuation { continuation in
                                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                                    result.itemProvider.loadObject(ofClass: UIImage.self)   { (data, error) in
                                        if let error = error {
                                            print("image失敗 \(error.localizedDescription)" )
                                        }
                                        
                                        if var image = data as? UIImage {
                                            if let fixedImage = image.fixImageOrientation(inputImage: image) {
                                                image =  fixedImage
                                            } else {
                                                continuation.resume(throwing: CompressError.compressImageFail)
                                            }
                                            let media = Media(title: nil, DownloadURL: URL(string: String(image.hashValue))!, image: image)
                                            continuation.resume(returning: (i, media))
                                        }
                                    }
                                } else {
                                    if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) {(url, error) in
                                            if let error = error {
                                                print("playerlayer失敗 \(error.localizedDescription)")
                                                return
                                            }
                                            
                                            guard let url = url else { return }
                                            let uuid = UUID().uuidString
                                            let fileName = "\(Int(Date().timeIntervalSince1970))_\(uuid).\(url.pathExtension)"
                                            let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                                            try? FileManager.default.copyItem(at: url, to: newUrl)
                                            let media = Media(title: nil, DownloadURL: newUrl, isImage: false)
                                            continuation.resume(returning: (i, media))
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("error", error)
                        }
                        return (i, Media())
                    }
                }
                var mediaarray = Array(repeating: Media.init(), count: results.count)
                
                for await result in group {
                    mediaarray[result.index] = result.media
                }
                return mediaarray
            }
            if MediaStorage.count > 0 {
                nextTapButton.isEnabled = true
                nextTapButton.updateTitle(Title: "下ㄧ步", backgroundColor: .tintColor, tintColor: .white, font: UIFont.weightSystemSizeFont(systemFontStyle: .title3, weight: .bold))
                self.addMediaButton.isEnabled = true
                UIView.animate(withDuration: 0.25, animations: {
                    self.addMediaButton.alpha = 1
                }) { bool in
                    self.addMediaButton.isEnabled = true
                }
            }
            self.temporaryPost = Post(restaurant: nil, Media: MediaStorage, user: User.example)
            reloadCollectionView()
        }
    }
    
    
    func reloadCollectionView() {
        let indexPath =  IndexPath(row: 0, section: 0)
        self.PageControll.currentPage = 0
        self.PageControll.numberOfPages = MediaStorage.count
        collectionView.performBatchUpdates ({
            self.collectionView.reloadSections([0])
        }) { bool in
            self.updateCellPageControll(currentCollectionIndexPath: indexPath)
            self.playCurrentMedia(indexPath: self.currentMediaIndexPath)
        }
    }
    
    func colletionViewLayoutFlow() {
        collectionView.showsHorizontalScrollIndicator = false
        let flow = UICollectionViewFlowLayout()
        let height = collectionView.bounds.height
        let spacing = self.collectionView.bounds.width - height
        flow.itemSize = CGSize(width: height  , height: height )
        flow.minimumLineSpacing = spacing
        flow.minimumInteritemSpacing = 0
        flow.scrollDirection = .horizontal
        flow.sectionInset = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
        collectionView.collectionViewLayout = flow
    }
    
    @objc func selectPHPickerImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = nil
        configuration.selectionLimit = 5
        configuration.preferredAssetRepresentationMode = .current
        let phppicker = PHPickerViewController(configuration: configuration)
        phppicker.delegate = self
        phppicker.transitioningDelegate = self
        present(phppicker, animated: true)
    }
    
    func registerCells() {
        self.collectionView.register(StaticImageViewCollectionCell.self, forCellWithReuseIdentifier: "StaticImageViewCollectionCell")
        self.collectionView.register(StaticPlayerLayerCollectionCell.self, forCellWithReuseIdentifier: "StaticPlayerLayerCollectionCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.MediaStorage[indexPath.row]
        if media.isImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaticImageViewCollectionCell", for: indexPath) as! StaticImageViewCollectionCell
            cell.mediaCellDelegate = self
            cell.layoutImageView(media: media)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaticPlayerLayerCollectionCell", for: indexPath) as! StaticPlayerLayerCollectionCell
            cell.mediaCellDelegate = self
            cell.layoutPlayerlayer(media: media)
            return cell
        }
    }
    
    func presentWholePageMediaViewController(post : Post?) {
        let controller = NewPostWholePageMediaViewController(presentForTabBarLessView: false, post: temporaryPost)
        let navController = SwipeEnableNavViewController(rootViewController: controller)
        controller.mediaAnimatorDelegate = self
        controller.panWholePageViewControllerwDelegate = self
        navController.modalPresentationStyle = .overFullScreen
        navController.transitioningDelegate = self
        navController.delegate = self
        self.present(navController, animated: true)
    }
    
    func animationController(forPresented presented: UIViewController, presenting presening: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        
        self.enterCollectionIndexPath = currentMediaIndexPath
        if let nav = presented as? UINavigationController {
            if let toViewController = nav.viewControllers.first as? WholePageMediaViewController {
                let animator = PresentWholePageMediaViewControllerAnimator(transitionToIndexPath: self.currentMediaIndexPath, toViewController:  toViewController , fromViewController: self)
                return animator
            } else {
                pauseCurrentMedia(indexPath: self.currentMediaIndexPath)
            }
        }
        if let toViewController = presented as? GridPostCollectionViewAnimatorDelegate {
            toViewController.reloadCollectionCell(backCollectionIndexPath: toViewController.enterCollectionIndexPath)
        }
        if let toViewController = presented as? MediaCollectionViewAnimatorDelegate {
            toViewController.reloadCollectionCell(backCollectionIndexPath: toViewController.enterCollectionIndexPath)
        }
        
        return nil
    }
    
    func reloadCollectionCell(backCollectionIndexPath: IndexPath) {
        guard self.MediaStorage.count > backCollectionIndexPath.row else {
            return
        }
        let enterMedia = self.MediaStorage[enterCollectionIndexPath.row]
        
        if let cell = self.collectionView.cellForItem(at: self.enterCollectionIndexPath) as? StaticImageViewCollectionCell {
            cell.reload(media: enterMedia)
        } else if let cell  = self.collectionView.cellForItem(at: self.enterCollectionIndexPath) as? StaticPlayerLayerCollectionCell {
            cell.reload(media: enterMedia)
        }
        let backMedia =  self.MediaStorage[backCollectionIndexPath.row]
        if let cell = self.collectionView.cellForItem(at: backCollectionIndexPath) as? StaticImageViewCollectionCell {
            cell.reload(media: backMedia)
        } else if let cell  = self.collectionView.cellForItem(at: backCollectionIndexPath) as? StaticPlayerLayerCollectionCell {
            cell.reload(media: backMedia)
        }
    }
    
    func updateCellPageControll(currentCollectionIndexPath: IndexPath) {
        self.currentMediaIndexPath = currentCollectionIndexPath
       
        PageControll.currentPage = currentCollectionIndexPath.row
        PageControll.numberOfPages = MediaStorage.count
        if MediaStorage[currentCollectionIndexPath.row].isImage {
            self.MuteTapgesture.isEnabled = false
        } else {
            self.MuteTapgesture.isEnabled = true
        }
        temporaryPost.CurrentIndex = currentCollectionIndexPath.row
        self.updateVisibleCellsMuteStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.MediaStorage.count
    }
    
}

extension UploadMediaViewcontroller {
    func playCurrentMedia(indexPath : IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath ) as? PlayerLayerCollectionCell {
            cell.play()
        }
    }
    
    func pauseCurrentMedia(indexPath : IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PlayerLayerCollectionCell {
            cell.pause()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index =  Int ( round( scrollView.contentOffset.x / scrollView.bounds.width) )
        if currentMediaIndexPath.row != index {
            pauseCurrentMedia(indexPath: self.currentMediaIndexPath)
            updateCellPageControll(currentCollectionIndexPath: IndexPath(row: index, section: currentMediaIndexPath.section))
            playCurrentMedia(indexPath: currentMediaIndexPath)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
       /* let index = Int(round(targetContentOffset.pointee.x / scrollView.bounds.width))
        if currentMediaIndexPath.row != index {
            pauseMedia(indexPath: currentMediaIndexPath)
            currentMediaIndexPath.row = index
            self.temporaryPost.CurrentIndex = index
            updateCellPageControll(currentCollectionIndexPath: IndexPath(row: index, section: 0 ))
            updateVisibleCellsMuteStatus()
        }*/
        
    }
    
    
    
    @objc func MutedToggle(_ gesture: UITapGestureRecognizer? = nil) {
        UniqueVariable.IsMuted.toggle()
        updateVisibleCellsMuteStatus()
    }
    
    func updateVisibleCellsMuteStatus() {
        for cell in collectionView.visibleCells {
            if let playerLayerCell = cell as? PlayerLayerCollectionCell {
                playerLayerCell.updateMuteStatus()
            }
        }

    }
    
    func setGesture() {
        
        MuteTapgesture = UITapGestureRecognizer(target: self, action: #selector(MutedToggle( _ : )))
        collectionView.addGestureRecognizer(MuteTapgesture)
        
    }
}


extension UploadMediaViewcontroller {
    
}

