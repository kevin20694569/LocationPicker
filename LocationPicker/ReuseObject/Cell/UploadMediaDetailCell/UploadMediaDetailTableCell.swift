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
    
    var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    var validUploadStatus : Bool = true
    
    var medias : [Media]! = []
    
    let mediaHeightScale = 0.75
    
    
    weak var textFieldDelegate : UITextFieldDelegate?
    
    var activeTextField : UITextField?
    
    weak var collectionViewDelegate : UICollectionViewDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initLayout()
        registerCells()
        collectionViewSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionViewSetup() {
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        

    }
    
    func initLayout() {
        self.contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.activeTextField?.resignFirstResponder()
    }
    
    func updateValidStatus() -> Bool {
        for media in medias {
            if !media.titleCountValid {
                self.validUploadStatus = false
                return false
            }

        }
        self.validUploadStatus = true
        return true

    }
    


    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let media = self.medias[indexPath.row]
        if media.isImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaDetailImageViewCollectionCell", for: indexPath) as! UploadMediaDetailImageViewCollectionCell
            cell.textFieldDelegate = textFieldDelegate
            cell.mediaHeightScale = mediaHeightScale
            cell.textField.tag = indexPath.row
            cell.configure(media: media)

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaDetailPlayerLayerCollectionCell", for: indexPath) as! UploadMediaDetailPlayerLayerCollectionCell
            cell.textFieldDelegate = textFieldDelegate
            cell.mediaHeightScale = mediaHeightScale
            cell.textField.tag = indexPath.row
            cell.configure(media: media)

            return cell
        }
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
       
        
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
        
    }
    
}







