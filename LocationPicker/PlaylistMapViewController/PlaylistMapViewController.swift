import UIKit
import MapKit

class PlaylistMapViewController: UIViewController {

    var playlists : [Int]! = []
    
    @IBOutlet var bottomBarView : UIView!
    
    @IBOutlet var mapView : MKMapView!
    
    var settingButton : DarkBlurButton! = DarkBlurButton(frame: .zero, Title: "", backgroundColor: .clear, tintColor:  .label, font: .weightSystemSizeFont(systemFontStyle: .body, weight: .medium  ), cornerRadius: 12)
    
    var playlistLabel : UILabel! = UILabel()
    
    @IBOutlet var playlistCollectionView : UICollectionView! { didSet {
        playlistCollectionView.delegate = self
        playlistCollectionView.dataSource = self
        playlistCollectionView.backgroundColor = .clear
        playlistCollectionView.showsHorizontalScrollIndicator = false
    }}

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setPlaylistCollectionViewLayout()
    }
    
    func layout() {

        settingButton.configuration?.image = UIImage(systemName: "gearshape")
        self.view.addSubview(settingButton)
        playlistLabel.text = "PlayList"
        playlistLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .title1, weight: .bold)
        playlistLabel.textColor = .label
        self.view.addSubview(playlistLabel)
        self.view.subviews.forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            settingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            settingButton.bottomAnchor.constraint(equalTo: self.playlistCollectionView.topAnchor, constant: -8),
            playlistLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            playlistLabel.bottomAnchor.constraint(equalTo: self.playlistCollectionView.topAnchor, constant: -8),
        ])
    }
    
    func setPlaylistCollectionViewLayout() {
        let width = self.playlistCollectionView.frame.size.width / 3.8
        let heightScale = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        NSLayoutConstraint.activate([
            playlistCollectionView.heightAnchor.constraint(equalToConstant:  width * heightScale)
        ])
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: width, height: width * heightScale)
        flow.minimumLineSpacing = 8
        flow.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        flow.scrollDirection = .horizontal
        self.playlistCollectionView.collectionViewLayout = flow
    }

}

extension PlaylistMapViewController:  UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.playlistCollectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistImageCollectionCell", for: indexPath) as! PlaylistImageCollectionCell
        return cell
    }
}
