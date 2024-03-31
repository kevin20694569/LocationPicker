import UIKit

class OpeningTimeView : UIView, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    var tableView : UITableView! = UITableView()
    
    var blurView : UIVisualEffectView! = UIVisualEffectView(frame: .zero, style: .userInterfaceStyle)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var openDay : [OpeningHours]?
        let weekDay = WeekDay.indexTranslate(index: indexPath.row)!
        switch indexPath.row {
        case 0:
            openDay = openingDays.mon
        case 1:
            openDay = openingDays.tues
        case 2:
            openDay = openingDays.wed
        case 3:
            openDay = openingDays.thur
        case 4:
            openDay = openingDays.fri
        case 5:
            openDay = openingDays.sat
        case 6:
            openDay = openingDays.sun
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningDayTableCell", for: indexPath) as! OpeningDayTableCell
        cell.configure(day: weekDay, openingHours: openDay )
        cell.separatorInset = Constant.standardTableViewInset
        return cell
    }
    
    
    var openingDays : OpeningDays! = OpeningDays()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        registerCells()
        layout()
        styleSet()
        layoutIfNeeded()
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registerCells() {
        self.tableView.register(OpeningDayTableCell.self, forCellReuseIdentifier: "OpeningDayTableCell")
    }
    
    func styleSet() {
        tableView.backgroundColor = .clear
        self.tableView.rowHeight = UITableView.automaticDimension
        self.translatesAutoresizingMaskIntoConstraints = true
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.tableView.allowsSelection = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func layout() {
        self.addSubview(blurView)
        self.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
        ])
    }
    
    func configure(openingDays : OpeningDays?) {
        if let openingDays = openingDays {
            self.openingDays = openingDays
            self.tableView.reloadSections([0], with: .none)
        }
    }
    
    
    
}

class OpeningDayTableCell : UITableViewCell {
    
    var dayLabel : UILabel! = UILabel()
    
    var timeStackView : UIStackView! = UIStackView()
    
    var isToday : Bool! = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    
    
    func configure(day : WeekDay , openingHours : [OpeningHours]?) {
        dayLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .bold)
        self.dayLabel.text = day.dayString
        self.isToday = day.isToday
        configureOpeningLabel(openingHours: openingHours)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeStackView = UIStackView()
        layout()
    }
    
    
    
    func layout() {
        timeStackView.axis = .vertical
        timeStackView.spacing = 8
        timeStackView.distribution = .equalSpacing
        self.backgroundColor = .clear
        self.contentView.addSubview(dayLabel)
        self.contentView.addSubview(timeStackView)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeStackView.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 8),
            timeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            timeStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
        
    }
    func configureOpeningLabel(openingHours : [OpeningHours]?) {
        timeStackView.arrangedSubviews.forEach() {
            $0.removeFromSuperview()
        }
        timeStackView = UIStackView()
        layout()
        
        
        
        if let openingHours = openingHours {
            if openingHours.isEmpty {
                let label = UILabel()
                
                label.contentMode = .center
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                label.adjustsFontForContentSizeCategory = true
                label.text = "休息"
                if isToday {
                    label.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote  , weight: .bold)
                    label.textColor = .label
                } else {
                    label.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote  , weight: .regular)
                    label.textColor = .secondaryLabelColor
                }
                self.timeStackView.addArrangedSubview(label)
                return
            }
            
            var opening : Bool = false
            for hour in openingHours {
                if let open = hour.open {
                    let label = UILabel()
                    label.contentMode = .center
                    label.textAlignment = .center
                    label.adjustsFontSizeToFitWidth = true
                    label.adjustsFontForContentSizeCategory = true
                    if open == "0000" {
                        label.text = "24小時營業"
                        if isToday {
                            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .body  , weight: .bold)
                            label.textColor = .label
                            opening = true
                        } else {
                            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .body  , weight: .regular)
                            label.textColor = .secondaryLabelColor
                        }

                    } else if let close = hour.close {
                        label.text = "\(open.prefix(2)):\(open.suffix(2))" + " - " + "\(close.prefix(2)):\(close.suffix(2))"
                        
                        if Date.isCurrentTimeInRange(startTime: open, endTime: close) && isToday {
                            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote  , weight: .bold)
                            label.textColor = .label
                            opening = true
                        } else {
                            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote  , weight: .regular)
                            label.textColor = .secondaryLabelColor
                        }
                    } else {
                        
                        
                    }
                    self.timeStackView.addArrangedSubview(label)
                }
            }
            if opening {
                //  self.openingSymbolView.backgroundColor = .systemGreen
            } else {
                //  self.openingSymbolView.backgroundColor = .systemRed
                
            }
        } else {
            let label = UILabel()
            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .footnote  , weight: .bold)
            label.contentMode = .center
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabelColor
            label.text = "暫無營業時間"
            self.timeStackView.addArrangedSubview(label)
            
            return
        }
        
    }
    
}
