import UIKit
class AddCollectTableViewCell : UITableViewCell {
    
    var playlist : Playlist!
    var playlistImageView : UIImageView = UIImageView()
    var titleLabel : UILabel! = UILabel()

    var checkMarkImageView : UIImageView! = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .title2, weight: .bold)))!)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        beSelected(selected: false)
    }
    
    func beSelected(selected : Bool) {
        self.checkMarkImageView?.isHidden = !selected
    }
    
    func layout() {
      
        self.accessoryView = UIImageView(image: UIImage(systemName: "square", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .title2, weight: .medium)))?.withTintColor(.secondaryLabelColor, renderingMode: .alwaysOriginal))
        self.contentView.addSubview(checkMarkImageView)
        checkMarkImageView.contentMode = .scaleAspectFit
        let accessoryView = self.accessoryView!
        
        checkMarkImageView.center = accessoryView.center
        accessoryView.addSubview(checkMarkImageView)

        self.beSelected(selected: false)
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addSubview(playlistImageView)
        playlistImageView.layer.cornerRadius = 8
        playlistImageView.clipsToBounds = true
        playlistImageView.contentMode = .scaleAspectFit
        playlistImageView.backgroundColor = .clear
        titleLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .medium)
        titleLabel.textColor = .label
        NSLayoutConstraint.activate([
            playlistImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            playlistImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: playlistImageView.centerYAnchor),
            playlistImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            playlistImageView.widthAnchor.constraint(equalTo: playlistImageView.heightAnchor, multiplier: 1),

            titleLabel.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 16),
        ])
        
    }
    
    func configure(playlist : Playlist) {
        self.playlist = playlist
        self.titleLabel.text = playlist.title
        self.playlistImageView.image = playlist.image
    }
    
    
}
