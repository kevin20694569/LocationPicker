import UIKit
class UploadMediaDetailTableCell : UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, MediaDelegate {

    func playCurrentMedia() {
        playVisibleCellsPlayer()
    }
    
    func playVisibleCellsPlayer() {
        self.collectionView.visibleCells.forEach { cell in
            if let playerLayerCell = cell as? UploadMediaDetailPlayerLayerCollectionCell {
                playerLayerCell.play()
            }
        }
    }
    
    func pauseCurrentMedia() {
        self.medias.forEach() { media in
            media.player?.pause()
        }
    }

    func registerCells() {
        self.collectionView.register(UploadMediaDetailPlayerLayerCollectionCell.self, forCellWithReuseIdentifier: "UploadMediaDetailPlayerLayerCollectionCell")
        self.collectionView.register(UploadMediaDetailImageViewCollectionCell.self, forCellWithReuseIdentifier: "UploadMediaDetailImageViewCollectionCell")
    }
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var medias : [Media]! = []
    
    let mediaHeightScale = 0.75
    
    lazy var singleTextFieldWidth : CGFloat! = {
        let cell = self.collectionView.visibleCells.first as! UploadMediaTextFieldProtocol
        return cell.textField.editingRect(forBounds: cell.textField.bounds).width
    }()
    
    
    var textFieldDelegate : UITextFieldDelegate!
    
    var activeTextField : UITextField?
    
    var collectionViewDelegate : UICollectionViewDelegate!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.activeTextField?.resignFirstResponder()
    }
    


    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.medias[indexPath.row]
        if media.urlIsImage() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaDetailImageViewCollectionCell", for: indexPath) as! UploadMediaDetailImageViewCollectionCell
            cell.textFieldDelegate = self.textFieldDelegate
            cell.mediaHeightScale = mediaHeightScale
            cell.textField.tag = indexPath.row
            cell.layoutImageView(media: media)

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaDetailPlayerLayerCollectionCell", for: indexPath) as! UploadMediaDetailPlayerLayerCollectionCell
            cell.textFieldDelegate = self.textFieldDelegate
            cell.mediaHeightScale = mediaHeightScale
            cell.textField.tag = indexPath.row
            cell.layoutPlayerlayer(media: media)

            return cell
        }
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
       
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionViewFlowSet()
    }

    
    func collectionViewFlowSet() {
        let flow = UICollectionViewFlowLayout()
        let height = bounds.height
        flow.itemSize = CGSize(width: height * mediaHeightScale , height: height )
        flow.minimumLineSpacing = 12
        flow.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flow
    }

    
    
    func configure(medias : [Media]) {
        self.medias = medias
        collectionView.delegate = collectionViewDelegate
        self.layoutIfNeeded()
    }
    
}



class UploadMediaDetailImageViewCollectionCell  : ImageViewCollectionCell, UploadMediaTextFieldProtocol {
    var textField : RoundedTextField!
    
    override var cornerRadiusfloat: CGFloat! {
        return 16
    }
    
    var textFieldDelegate : UITextFieldDelegate!
    
    var contentModeToggleTapGesture : UITapGestureRecognizer!
    
    var mediaHeightScale : Double!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.backgroundColor = .secondaryBackgroundColor
        contentModeToggleTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentModeToggle))
        self.imageView.addGestureRecognizer(contentModeToggleTapGesture)
        self.imageView.isUserInteractionEnabled = true
        textField = RoundedTextField()
        textField.backgroundColor = .secondaryBackgroundColor
        textField.layer.cornerRadius = 8
        self.contentView.addSubview(textField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        DispatchQueue.main.async {

            let bounds = self.contentView.bounds
            self.imageView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width , height: bounds.height * self.mediaHeightScale)

        }
    }
    
    override func layoutImageView(media: Media) {
        super.layoutImageView(media: media)
        self.textField.text = media.title
        textField.delegate = self.textFieldDelegate
        self.layoutTextField()
    }
    
    
    
    
    @objc func contentModeToggle() {
        if self.imageView.contentMode == .scaleAspectFill {
            self.imageView.contentMode = .scaleAspectFit
        } else {
            self.imageView.contentMode = .scaleAspectFill
        }
    }

    
    func layoutTextField() {
        let heightScale = 0.15
        let offsetYScale = (1 - mediaHeightScale - heightScale) / 2 + mediaHeightScale
        let widthScale = 0.9
        let offsetXScale = (1 - widthScale) / 2
        let bounds = contentView.bounds
        let frame = CGRect(x: bounds.width * offsetXScale, y: bounds.height * offsetYScale, width: bounds.width * widthScale, height: bounds.height * heightScale )
        textField.frame = frame
    }
}

class UploadMediaDetailPlayerLayerCollectionCell : PlayerLayerCollectionCell, UploadMediaTextFieldProtocol {
    var textField : RoundedTextField!
    var contentModeToggleTapGesture : UITapGestureRecognizer!
    var BehindPlayerLayerView : UIView!
    
    var textFieldDelegate : UITextFieldDelegate!
        
    var mediaHeightScale : Double!
    
    override var cornerRadiusfloat: CGFloat! {
        return 16
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        BehindPlayerLayerView = UIView()
        self.contentView.addSubview(BehindPlayerLayerView)

        textField = RoundedTextField()
        self.contentView.addSubview(textField)
        setGesture()
    }
    
    func setGesture() {
        contentModeToggleTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentModeToggle))
        BehindPlayerLayerView.addGestureRecognizer(contentModeToggleTapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func contentModeToggle() {
        if self.playerLayer.videoGravity == .resizeAspectFill {
            self.playerLayer.videoGravity = .resizeAspect
        } else {
            self.playerLayer.videoGravity = .resizeAspectFill
        }
    }
    
    
    
    
    
    override func layoutSoundImageView() {
        super.layoutSoundImageView()
        self.soundViewIncludeBlur.forEach() {
            $0.isHidden = true
        }
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        DispatchQueue.main.async {
            let bounds = self.contentView.bounds
            let frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width , height: bounds.height * self.mediaHeightScale)
            self.BehindPlayerLayerView.frame = frame
            self.BehindPlayerLayerView.layer.addSublayer(self.playerLayer)
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            self.playerLayer.frame = frame
            CATransaction.commit()
            self.playerLayer.layoutIfNeeded()
            print(frame)
            self.layoutTextField()
        }
        // }

    }

    
    override func layoutPlayerlayer(media: Media) {
        super.layoutPlayerlayer(media: media)
        playerLayer.backgroundColor = UIColor.secondaryBackgroundColor.cgColor
        self.playerLayer.player?.isMuted = true
        self.textField.text = media.title
        textField.delegate = self.textFieldDelegate
        
    }
    
    func layoutTextField() {
        textField.backgroundColor = .secondaryBackgroundColor
        textField.layer.cornerRadius = 8
        let heightScale = 0.15
        let offsetYScale = (1 - mediaHeightScale - heightScale) / 2 + mediaHeightScale
        let widthScale = 0.9
        let offsetXScale = (1 - widthScale) / 2
        let bounds = contentView.bounds
        let frame = CGRect(x: bounds.width * offsetXScale, y: bounds.height * offsetYScale, width: bounds.width * widthScale, height: bounds.height * heightScale )
        textField.frame = frame
    }
    
}

