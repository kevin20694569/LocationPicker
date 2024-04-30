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
    
    var validUploadStatus : Bool = true
    
    var medias : [Media]! = []
    
    let mediaHeightScale = 0.75
    
    lazy var singleTextFieldWidth : CGFloat! = {
        let cell = self.collectionView.visibleCells.first as! UploadMediaTextFieldProtocol
        return cell.textField.editingRect(forBounds: cell.textField.bounds).width
    }()
    
    
    weak var textFieldDelegate : UITextFieldDelegate?
    
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
    
    func updateValidStatus() {
        for media in medias {
            if !media.titleCountValid {
                self.validUploadStatus = false
                return
            }

        }
        self.validUploadStatus = true

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







