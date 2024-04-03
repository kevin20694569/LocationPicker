import UIKit
import AVFoundation

class PlayerLayerCollectionCell: UICollectionViewCell, MediaCollectionCell {
    
    
    
    var cornerRadiusfloat : CGFloat!  {
        return Constant.standardCornerRadius
    }
    weak var currentMedia : Media!

    var playerLayer : AVPlayerLayer!
    
    
    @objc func playerRestart() {
        playerLayer.player?.seek(to: CMTime.zero)
        playerLayer.player?.play()
    }
    
    func updateMuteStatus() {
        playerLayer.player?.isMuted = UniqueVariable.IsMuted
        let image = UniqueVariable.IsMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.wave.2.fill")
        let config = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout  , weight: .regular))
        soundImageview.image = image?.withTintColor(.white).withRenderingMode(.alwaysOriginal).withConfiguration(config)
    }
    
    var soundImageBackgroundBlurView : UIVisualEffectView!
    
    var soundViewIncludeBlur : [UIView] {
        [soundImageview, soundImageBackgroundBlurView]
    }
    
    
    var soundImageview : UIImageView!
    
    func reload(media : Media?) {
        self.contentView.alpha = 1
        playerLayer.cornerRadius = Constant.standardCornerRadius
        if let media = media {

            layoutPlayerlayer(media: media)
            
        }
        UIView.performWithoutAnimation {
            self.contentView.isHidden = false
            self.isHidden = false
            
            self.soundImageview.isHidden = false
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer = AVPlayerLayer()
        playerLayer.masksToBounds = true
        playerLayer.cornerRadius = self.cornerRadiusfloat
        contentView.layer.insertSublayer(playerLayer, at: 0)
        layoutSoundImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    func layoutPlayerlayer(media : Media) {
        self.currentMedia = media
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true



        self.updateMuteStatus()
        UIView.performWithoutAnimation {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            self.contentView.layer.insertSublayer(self.playerLayer, at: 0)
            playerLayer.isHidden = false
            playerLayer.player = media.player
            self.playerLayer.frame = self.bounds
            playerLayer.videoGravity = .resizeAspectFill
            CATransaction.commit()
        }
        
      //  CATransaction.begin()
      //  CATransaction.setAnimationDuration(0)
      //  self.playerLayer.frame = self.bounds
      //  CATransaction.commit()
        
      //  DispatchQueue.main.async {
            //CATransaction.begin()
           // CATransaction.setAnimationDuration(0)
            
           // self.contentView.layer.insertSublayer(self.playerLayer, at: 0)
            
          //
           // CATransaction.commit()
          //     self.layoutIfNeeded()
            
      //  }
    }
    
    func layoutSoundImageView() {
        let image = UniqueVariable.IsMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.wave.2.fill")
        let config = UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .callout  , weight: .regular))
        soundImageview = UIImageView(image: image?.withTintColor(.white).withRenderingMode(.alwaysOriginal).withConfiguration(config))
        soundImageBackgroundBlurView = UIVisualEffectView(frame: soundImageview.frame, style: .systemUltraThinMaterialDark)
        
        soundImageBackgroundBlurView.clipsToBounds = true

        soundImageview.contentMode = .center
        soundImageview.translatesAutoresizingMaskIntoConstraints = false
        soundImageBackgroundBlurView.translatesAutoresizingMaskIntoConstraints = false

        
        let frame = self.playerLayer.superlayer!.convert(self.playerLayer.frame, to: self.contentView.layer)
        
        DispatchQueue.main.async { [self] in

            self.contentView.addSubview(soundImageBackgroundBlurView)
            self.contentView.addSubview(soundImageview)
            NSLayoutConstraint.activate([
                
                soundImageview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -bounds.height * 0.06),
                soundImageview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -bounds.height * 0.08),
                soundImageBackgroundBlurView.centerXAnchor.constraint(equalTo: soundImageview.centerXAnchor),
                soundImageBackgroundBlurView.centerYAnchor.constraint(equalTo: soundImageview.centerYAnchor),
                soundImageBackgroundBlurView.heightAnchor.constraint(equalTo: soundImageview.heightAnchor, multiplier: 1.7),
                soundImageBackgroundBlurView.widthAnchor.constraint(equalTo: soundImageview.heightAnchor, multiplier: 1.7)
            ])
            soundImageBackgroundBlurView.layoutIfNeeded()
            if soundImageBackgroundBlurView != nil {
                soundImageBackgroundBlurView.layer.cornerRadius = soundImageBackgroundBlurView.bounds.height / 2
            }
        }

    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer.player?.seek(to: CMTime.zero)
    }
    
    
    
    
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        self.playerLayer.frame = self.bounds
        CATransaction.commit()
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

class StandardPlayerLayerCollectionCell:  PlayerLayerCollectionCell {
    override var cornerRadiusfloat: CGFloat {
        return 0
    }
    override func layoutPlayerlayer(media: Media) {
        super.layoutPlayerlayer(media: media)
        self.playerLayer.cornerRadius = cornerRadiusfloat
      //  layoutIfNeeded()
    }

}



