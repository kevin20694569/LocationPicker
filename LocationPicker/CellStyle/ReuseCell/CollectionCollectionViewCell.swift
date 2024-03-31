import UIKit
class CollectionCollectionViewCell : UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView : UICollectionView! = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func layout() {
        collectionView.backgroundColor = .backgroundPrimary
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        self.collectionView.layoutIfNeeded()
      
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(collectionView)
        layout()
        setPlaylistCollectionViewLayout()
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.addSubview(collectionView)
        layout()
        setPlaylistCollectionViewLayout()
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
    }
    func setPlaylistCollectionViewLayout() {
        let width = self.collectionView.frame.size.width / 3.8
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: width, height: width * 1.2)
        flow.minimumLineSpacing = 8
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        flow.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flow
    }
    
    func registerCells() {
        self.collectionView.register(CollectionViewButtonCell.self, forCellWithReuseIdentifier: "CollectionViewButtonCell")
    }
    

    
}
