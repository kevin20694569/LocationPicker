import UIKit

class RestaurantDetailOpeningTimesCell : BlurCollectionCell, RestaurantProfileCollectionCell {
    
    @IBOutlet var openingTimeStackView : UIStackView!
    
    @IBOutlet var openingDayLabel : UILabel!
    
    @IBOutlet var openingSymbolView : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    
    
    func layoutOpeningSymbolView() {

        openingSymbolView.backgroundColor = .secondaryBackgroundColor
        openingSymbolView.clipsToBounds = true
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        openingSymbolView.layer.cornerRadius = openingSymbolView.bounds.height / 2
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutOpeningSymbolView()
        openingTimeStackView.alignment = .center
        openingTimeStackView.distribution = .fillEqually
        openingTimeStackView.spacing = 0
        self.blurView.isHidden = true
    }
    func configure(restaurant : Restaurant) {
        
        self.openingTimeStackView.arrangedSubviews.forEach() { view in
            openingTimeStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayString = dateFormatter.string(from: date)
        openingDayLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline   , weight: .bold)
        let today =  WeekDay(rawValue: dayString)
        
        openingDayLabel.text = today?.dayString
        var openingDay : [OpeningHours]?
        if let openingDays = restaurant.openingDays {
            if let monFirst = openingDays.mon?.first {
                if monFirst.open == "0000" && monFirst.close == nil {
                    configureOpeningLable(openingDay: openingDays.mon, today: true)
                    return
                }
            }

            switch today {
            case .mon :
                openingDay = openingDays.mon
            case .tues :
                openingDay = openingDays.tues
            case .wed :
                openingDay = openingDays.wed
            case .thur :
                openingDay = openingDays.thur
            case .fri :
                openingDay = openingDays.fri
            case .sat :
                openingDay = openingDays.sat
            case .sun :
                openingDay = openingDays.sun
            case .none :
                return
            }
        } else {
            
        }
        configureOpeningLable(openingDay: openingDay, today: false)
        
    }
    func configureOpeningLable(openingDay : [OpeningHours]?, today : Bool) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayString = dateFormatter.string(from: date)
        openingDayLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline   , weight: .bold)
        let today =  WeekDay(rawValue: dayString)
        if let openingDay = openingDay {
            if openingDay.isEmpty {
                let label = UILabel()
                label.contentMode = .center
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                label.adjustsFontForContentSizeCategory = true
                label.text = "休息"
                label.textColor = .label
                self.openingTimeStackView.addArrangedSubview(label)
                self.openingSymbolView.backgroundColor = .systemRed
                return
            }
            var opening : Bool = false
            for hour in openingDay {
                if let open = hour.open {
                    let label = UILabel()
                    label.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline  , weight: .bold)
                    label.contentMode = .center
                    label.textAlignment = .center
                    label.adjustsFontSizeToFitWidth = true
                    label.adjustsFontForContentSizeCategory = true
                    if open == "0000" && hour.close == "0000" {
                        label.text = "24小時營業"
                        if Date.isCurrentTimeInRange(startTime: open, endTime: "0000") {
                            label.textColor = .label
                            opening = true
                        }
                    } else if let close = hour.close {
                        label.text = "\(open.prefix(2)):\(open.suffix(2))" + " - " + "\(close.prefix(2)):\(close.suffix(2))"
                        
                        if Date.isCurrentTimeInRange(startTime: open, endTime: close) {
                            label.textColor = .label
                            opening = true
                        } else {
                            label.textColor = .secondaryLabelColor
                        }
                    }
                    self.openingTimeStackView.addArrangedSubview(label)
                }
            }
            if opening {
                self.openingSymbolView.backgroundColor = .systemGreen
            } else {
                self.openingSymbolView.backgroundColor = .systemRed
            }
        } else {
            let label = UILabel()
            label.font = UIFont.weightSystemSizeFont(systemFontStyle: .headline  , weight: .bold)
            label.contentMode = .center
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabelColor
            label.text = "暫無營業時間"
            self.openingTimeStackView.addArrangedSubview(label)

            return
        }

        
    }
}

