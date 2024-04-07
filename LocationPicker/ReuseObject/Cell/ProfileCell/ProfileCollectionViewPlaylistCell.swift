import UIKit

class ProfileCollectionViewPlaylistCell: CollectionViewInCollectionCell {
    
    var playlists : [Playlist]! = Playlist.examples
    
    func configureData(playlists : [Playlist]) {
        self.playlists = playlists
    }
    
    override func setPlaylistCollectionViewLayout() {
        let width = self.collectionView.frame.size.width / 3.8
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: width, height: width * 1.2)
        flow.minimumLineSpacing = 8
        flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        flow.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flow
    }
    
    override func registerCells() {
        super.registerCells()
        self.collectionView.register(PlaylistCollectionCell.self, forCellWithReuseIdentifier: "PlaylistCell")
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        setPlaylistCollectionViewLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
        setPlaylistCollectionViewLayout()
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCollectionCell
        let playlist = self.playlists[indexPath.row]
        cell.configureData(playlist: playlist)
        return cell
    }
    
}



class PlaylistCollectionCell : UICollectionViewCell {
    
    let cornerRadius: CGFloat = 16
    
    @IBOutlet var imageView : UIImageView! = UIImageView() { didSet {

    }}
    @IBOutlet var titleLabel : UILabel! = UILabel()
    
    func configureData(playlist : Playlist) {
        if let image = playlist.image {
            self.imageView.image = image
        } else {
            Task {
                let image = try await playlist.imageURL?.getImageFromURL()
                playlist.image = image
                self.imageView.image = image
            }
        }
        self.titleLabel.text = playlist.title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .secondaryBackgroundColor
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
            
        ])
    }
}



