import UIKit
import MapKit

class RestaurantProfileMapCell : UICollectionViewCell, RestaurantProfileCollectionCell, MKMapViewDelegate {
    var mapView : MKMapView!
    
    var restaurant : Restaurant!
    var currentPlacemark : CLPlacemark?
    
    var distanceLabel : UILabel!
    
    var blurView : UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 16
        mapView.frame = bounds
        self.contentView.addSubview(mapView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.mapView = MKMapView(frame: frame)
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 16
        mapView.frame = bounds
        mapView.delegate = self
        mapView.showsUserLocation = true
        self.contentView.addSubview(mapView)
        distanceLabel = UILabel()
        distanceLabel.font = UIFont.weightSystemSizeFont(systemFontStyle: .callout, weight: .bold)
        self.contentView.addSubview(distanceLabel)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        blurView = UIVisualEffectView(frame: distanceLabel.frame, style: .userInterfaceStyle)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 12
        

        self.contentView.insertSubview(blurView, aboveSubview: self.mapView)
        self.layoutIfNeeded()
        distanceLabel.alpha = 0
        blurView.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(restaurant: Restaurant) {
        self.restaurant = restaurant
        let geoCoder = CLGeocoder()
        Task(priority : .background) {
            do {
                let placemarks = try await geoCoder.geocodeAddressString(restaurant.Address)
                self.currentPlacemark = placemarks[0]
                let annotation = MKPointAnnotation()
                if let location = self.currentPlacemark?.location {
                    
                    if let currentLocation = self.mapView.userLocation.location {
                        
                        
                        let distance = location.distance(from: currentLocation)
                        self.distanceLabel.text = String(format : "%.1f公里" ,distance / 1000)
                        layoutIfNeeded()
                        UIView.animate(withDuration: 0.25, animations: {
                            self.blurView.alpha = 1
                                self.distanceLabel.alpha = 1
                        })
                    }
                    annotation.coordinate = location.coordinate
                    annotation.title = restaurant.name
                    self.mapView.addAnnotation(annotation)
                    
                    showCoordinateOnMap(coordinate: annotation.coordinate,visibleOffsetY: bounds.height )
                }
            } catch {
                print(error)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "LocationMarker"
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.glyphText = nil
        annotationView?.glyphTintColor = UIColor.white
        annotationView?.glyphImage = UIImage(systemName: "mappin", withConfiguration: UIImage.SymbolConfiguration(font: .weightSystemSizeFont(systemFontStyle: .body, weight: .bold)))
        annotationView?.contentMode = .scaleAspectFit
        annotationView?.animatesWhenAdded = true
        
        
        annotationView?.markerTintColor = .tintOrange
        return annotationView
    }
    
    
    func showCoordinateOnMap(coordinate: CLLocationCoordinate2D, visibleOffsetY : CGFloat) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // 调整这里的数值以控制显示范围
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        // 计算 MKMapRect
        let topLeftCoordinate = CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta / 2, longitude: region.center.longitude - region.span.longitudeDelta / 2)
        let bottomRightCoordinate = CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta / 2, longitude: region.center.longitude + region.span.longitudeDelta / 2)
        
        let topLeft = MKMapPoint(topLeftCoordinate)
        let bottomRight = MKMapPoint(bottomRightCoordinate)
        let height = abs(topLeft.y - bottomRight.y)
        let scale : CGFloat = 1
        let mapRect = MKMapRect(x: min(topLeft.x, bottomRight.x), y: min(topLeft.y, bottomRight.y) /*+ visibleOffsetY * scale*/, width: abs(topLeft.x - bottomRight.x), height: height)
        
        // 设置地图的可见区域
        self.mapView.setVisibleMapRect(mapRect, animated: true)
      //  isPolylinePresented = false
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.mapView.frame = self.bounds
        
        blurView.frame = CGRect(origin: .zero, size: CGSize(width: distanceLabel.frame.width * 1.4, height: distanceLabel.frame.height * 1.6))
        blurView.center = distanceLabel.center
    }
    
    
}

