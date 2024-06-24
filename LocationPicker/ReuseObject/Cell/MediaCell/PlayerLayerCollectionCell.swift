import UIKit
import AVFoundation

class PlayerLayerCollectionCell: UICollectionViewCell, MediaCollectionCell {
    
    var mediaCornerRadius : CGFloat!  {
        return Constant.standardCornerRadius
    }
    weak var currentMedia : Media!
    
    var playerLayer : AVPlayerLayer! = AVPlayerLayer()
    
    var soundImageview : UIImageView! = UIImageView()
    
    weak var mediaCellDelegate : MediaCellDelegate?
    
    
    @objc func playerRestart() {
        playerLayer.player?.seek(to: CMTime.zero)
        playerLayer.player?.play()
    }
    
    @objc func updateMuteStatus() {
        
        playerLayer.player?.isMuted = UniqueVariable.IsMuted
        let image = UniqueVariable.IsMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.wave.2.fill")
        let config = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout  , weight: .regular))
        soundImageview.image = image?.withTintColor(.white).withRenderingMode(.alwaysOriginal).withConfiguration(config)

        
    }
    
    var soundImageBackgroundBlurView : UIVisualEffectView! = UIVisualEffectView(frame: .zero, style: .systemUltraThinMaterialDark)
    var soundViewIncludeBlur : [UIView] {
        [soundImageview, soundImageBackgroundBlurView]
    }
    
    

    
    func reload(media : Media?) {
        contentView.layer.insertSublayer(playerLayer, at: 0)
        playerLayer.cornerRadius = mediaCornerRadius
        if let media = media {
            configure(media: media)
        }
        self.contentView.isHidden = false
        self.soundImageview.isHidden = false
        self.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayerSetup()
        soundImageViewSetup()
        contentViewSetup()
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func playerLayerSetup() {
        playerLayer.masksToBounds = true
        playerLayer.cornerRadius = self.mediaCornerRadius
        self.playerLayer.videoGravity = .resizeAspectFill
        contentView.layer.insertSublayer(playerLayer, at: 0)

    }
    
    func contentViewSetup() {
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
    }
    
    
    
    func configure(media : Media) {
        self.currentMedia = media
        playerLayer.player = media.player
        self.updateMuteStatus()
    }
    
    @objc func soundImageTapped(_ sender : Any) {
        mediaCellDelegate?.updateVisibleCellsMuteStatus()
        updateMuteStatus()
    }
    
    func soundImageViewSetup() {
        let image = UniqueVariable.IsMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.wave.2.fill")
        let config = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout  , weight: .regular))
        soundImageview.image = image?.withTintColor(.white).withRenderingMode(.alwaysOriginal).withConfiguration(config)
        soundImageview.contentMode = .center
        soundImageview.translatesAutoresizingMaskIntoConstraints = false
        
        soundImageview.isUserInteractionEnabled = true
        
        let soundImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(soundImageTapped( _ :)))
        soundImageViewGesture.cancelsTouchesInView = false
        soundImageBackgroundBlurView.addGestureRecognizer(soundImageViewGesture)
        soundImageBackgroundBlurView.clipsToBounds = true
        soundImageBackgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(soundImageBackgroundBlurView)
        self.contentView.addSubview(soundImageview)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            NSLayoutConstraint.activate([
                
                soundImageview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bounds.height * 0.06),
                soundImageview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bounds.height * 0.08),
                soundImageBackgroundBlurView.centerXAnchor.constraint(equalTo: soundImageview.centerXAnchor),
                soundImageBackgroundBlurView.centerYAnchor.constraint(equalTo: soundImageview.centerYAnchor),
                soundImageBackgroundBlurView.heightAnchor.constraint(equalTo: soundImageview.heightAnchor, multiplier: 1.7),
                soundImageBackgroundBlurView.widthAnchor.constraint(equalTo: soundImageview.heightAnchor, multiplier: 1.7)
            ])
        }
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer.player?.seek(to: CMTime.zero)
        self.playerLayer.player = nil
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        
        self.playerLayer.isHidden = false
        self.playerLayer.frame = self.bounds
        CATransaction.commit()
        soundImageBackgroundBlurView.layer.cornerRadius = soundImageBackgroundBlurView.bounds.height / 2
    }

    func play() {

        if let player = playerLayer.player {
            player.play()
            addPlayerRestartObserverToken()
        }
    }
    
    func pause() {
        if let player = playerLayer.player {
            player.pause()
            removePlayerRestartObserverToken()
        }
    }
    
    func addPlayerRestartObserverToken() {
        let media = currentMedia
        
        if media?.playerRestartObserverToken == nil {
            media?.playerRestartObserverToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem, queue: .main) {  [weak self] Notification in
                self?.playerRestart()
            }
        }
    }
    

    func removePlayerRestartObserverToken() {
        let media = currentMedia
        if let token = media?.playerRestartObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
        media?.playerRestartObserverToken = nil
    }


    
}





