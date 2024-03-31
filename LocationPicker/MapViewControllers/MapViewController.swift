import UIKit
import MapKit
import CoreLocation
import AVFoundation

enum PreViewSection {
    case main
}

enum MapCardViewStatus : Double {
    case safeAreaFullScreen
    case standard
    case minium
}

class MapViewController: UIViewController, MKLocalSearchCompleterDelegate, UIViewControllerTransitioningDelegate, MapGridPostDelegate, UINavigationControllerDelegate {
    
    var collectionView: UICollectionView! {
        return self.MapCardViewController.collectionView
    }
    var enterCollectionCell: UICollectionViewCell? {
        return self.collectionView.cellForItem(at: enterCollectionIndexPath)
    }
    
    var mapIsMoving : Bool = false

    var cardViewStatus : MapCardViewStatus! = .standard
    
    var enterCollectionIndexPath : IndexPath! = IndexPath(row: 0, section: 0)
    
    var Restaurant : Restaurant!
    
    var MapCardViewController : MapGridPostViewController!
    
    var lastRestaurantID : String! = ""
    
    let bounds = UIScreen.main.bounds
    
    var locatinoCoordinate : CLLocationCoordinate2D!
    
    var polylineMapRect : MKMapRect!
    
    var isPolylinePresented : Bool = false
    
    var panGestureRecognizer : UIPanGestureRecognizer!
    
    var cardViewminY : CGFloat {
        switch self.cardViewStatus {
        case .safeAreaFullScreen:
            return safeAreaFullScreenMinY
        case .standard:
            return standardMinY
        case .minium:
            return minimunMinY
        case .none:
            return standardMinY
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapIsMoving = !animated
    }

    
    
    
    @IBOutlet var searchOnGoogleMapsButton : ZoomAnimatedButton!
    
    @objc func openGoogleMapsForSearch() {
        if let url = URL(string: "comgooglemaps://?q=\(self.Restaurant.name)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                openGoogleMapsInBrowser(query: self.Restaurant.name)
            }
        }
    }
    
    func openGoogleMapsInBrowser(query: String) {
        if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBOutlet var mapFunctionStackView : UIStackView!
    
    @IBOutlet var backToLocationAndEraseRouteButton : UIButton!
    
    var currentPlacemark : CLPlacemark!
    let locationManager = CLLocationManager()
    var safeAreaFullScreenMinY : CGFloat!
    var standardMinY : CGFloat!
    var minimunMinY : CGFloat!
    var stackViewBottomAnchorContant : CGFloat! = -4
    @IBAction func swiperight(_ sender: Any) {
        BasicViewController.shared.startSwipe(toPage: 1)
    }
    
    @IBOutlet weak var MapView : MKMapView! { didSet {
        MapView.delegate = self
        MapView.showsCompass = true
    }}
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            MapView.showsUserLocation = true
        }
        MapView.translatesAutoresizingMaskIntoConstraints = false
        locationManager.delegate = self
        MapView.delegate = self
        MapCardViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapGridPostViewController") as? MapGridPostViewController
        MapCardViewController.modalPresentationStyle = .custom
        MapCardViewController.transitioningDelegate = self
        MapCardViewController.mapGridPostDelegate = self
        self.addChild(MapCardViewController)
        MapCardViewController.didMove(toParent: self)
        
        layoutSearchOnGooleMapButton()

    }
    
    
    
    func defaultInit() {
        let frame =  self.MapCardViewController.view.frame
        self.MapView.alpha = 1
        self.MapCardViewController.view.frame = CGRect(x: frame.minX, y: standardMinY, width: frame.width, height: frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        standardMinY = self.view.bounds.height - MapCardViewController.collectionView.frame.minY

        cardViewinit()
        let restaurantNameSuperView = MapCardViewController.view.viewWithTag(5)
        let restaurantNameSuperViewFrame = MapCardViewController.view.convert(restaurantNameSuperView!.bounds , to: nil)
        minimunMinY = bounds.height - restaurantNameSuperViewFrame.height - MapCardViewController.openToggleView.bounds.height - 10
        layoutNavbarStyle()
    }
    
    func layoutSearchOnGooleMapButton() {
        self.view.addSubview(MapCardViewController.view)
        searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchOnGoogleMapsButton.bottomAnchor.constraint(equalTo: MapCardViewController.view.topAnchor, constant: stackViewBottomAnchorContant),
            mapFunctionStackView.bottomAnchor.constraint(equalTo: MapCardViewController.view.topAnchor, constant: stackViewBottomAnchorContant),
            mapFunctionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            searchOnGoogleMapsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        mapFunctionStackView.arrangedSubviews.forEach { view in
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            blurView.layer.cornerRadius = 10
            blurView.clipsToBounds = true
            blurView.isUserInteractionEnabled = false
            view.addSubview(blurView)
            view.backgroundColor = .clear
            view.tintColor = .clear
        }
        searchOnGoogleMapsButton.addTarget(self, action: #selector(openGoogleMapsForSearch), for: .touchUpInside)
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = searchOnGoogleMapsButton.bounds
        blurView.layer.cornerRadius = 10
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        searchOnGoogleMapsButton.addSubview(blurView)
        searchOnGoogleMapsButton.backgroundColor = .clear
        searchOnGoogleMapsButton.tintColor = .clear
    }
    
    func layoutNavbarStyle() {
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        self.navigationController?.navigationBar.isTranslucent  = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = false
        BasicViewController.shared.swipeDatasourceToggle(navViewController: self.navigationController)
        let height = UIScreen.main.bounds.height - Constant.safeAreaInsets.top - self.mapFunctionStackView.frame.height
        MapCardViewController.view.frame = CGRect(x: MapCardViewController.view.frame.minX, y: MapCardViewController.view.frame.minY, width: MapCardViewController.view.frame.width, height: height)
    }
}
extension MapViewController: MKMapViewDelegate {
    func configure(restaurantName: String, address: String, restaurantID : String) async {
        guard lastRestaurantID != restaurantID else {
            return
        }
        removeRoute()
        lastRestaurantID = restaurantID
        let geoCoder = CLGeocoder()
        
        MapCardViewController.distanceLabel.text = ""
        startToStandardAnimation()
        await MapCardViewController.search(restaurantname: restaurantName , restautrantaddress:address ,restaurantID: restaurantID)
        Task {
            do {
                let placemarks = try await geoCoder.geocodeAddressString(address)
                self.currentPlacemark = placemarks[0]
                let annotation = MKPointAnnotation()
                if let location = placemarks[0].location {
                    if let currentLocation = self.MapView.userLocation.location {
                        
                        let distance = location.distance(from: currentLocation)
                        MapCardViewController.distanceLabel.text = String(format : "%.1f公里" ,distance / 1000)
                    }
                    locatinoCoordinate = location.coordinate
                    annotation.coordinate = location.coordinate
                    annotation.title = restaurantName
                    self.MapView.addAnnotation(annotation)
                    
                    showCoordinateOnMap(coordinate: annotation.coordinate,visibleOffsetY: bounds.height - standardMinY)
                }
            } catch {
                throw error
            }
        }
    }
    
    func removeRoute() {
        if let overlay = MapView.overlays.first {
            self.MapView.removeOverlay(overlay)
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
        annotationView?.markerTintColor = .tintColor
        return annotationView
    }
    
}



extension MapViewController : CLLocationManagerDelegate {
    

    @IBAction func BackToUserLocation(_ sender : UIButton) {
        let location = self.MapView.userLocation
        showCoordinateOnMap(coordinate: location.coordinate, visibleOffsetY : self.bounds.height - self.cardViewminY)
    }
    
    @IBAction func showDirection(sender: UIButton) {
        guard let currentPlacemark = self.currentPlacemark else {
            return
        }
        
        let directionRequest = MKDirections.Request()
        let coordinate =  self.MapView.userLocation.coordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        directionRequest.source = MKMapItem(placemark: placemark)
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [self] (routeResponse, routeError) -> Void in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                return
            }
            let route = routeResponse.routes[0]
            if MapView.overlays.isEmpty {
                self.MapView.addOverlay(route.polyline, level: .aboveRoads)
            }
            self.polylineMapRect = route.polyline.boundingMapRect
            showMapRect(rect: route.polyline.boundingMapRect, visibleOffsetY: self.bounds.height - cardViewminY)
            backToLocationAndEraseRouteButton.setImage(UIImage(systemName: "eraser.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    @IBAction func eraseRouteAndBackToLocation(_ sender : UIButton) {
        if let overlay = MapView.overlays.first {
            self.MapView.removeOverlay(overlay)
        }
        if let coordinate = currentPlacemark?.location?.coordinate {
            showCoordinateOnMap(coordinate: coordinate, visibleOffsetY: self.bounds.height - cardViewminY)
            backToLocationAndEraseRouteButton.setImage(UIImage(systemName: "mappin.and.ellipse")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3
        renderer.lineCap = .round
        renderer.lineJoin = .round
        renderer.lineDashPattern = [2, 5]
        return renderer
    }
    func showMapRect(rect : MKMapRect, visibleOffsetY : CGFloat) {
        let scale = rect.height / self.MapView.bounds.height
        let mapRect = MKMapRect(x: rect.minX - rect.width * 0.3, y: rect.minY + (visibleOffsetY * scale) - rect.height * 0.4 , width: rect.width * 1.6, height: rect.height * 2)
        self.MapView.setVisibleMapRect(mapRect, animated: true)
        isPolylinePresented = true
    }
    
    func showCoordinateOnMap(coordinate: CLLocationCoordinate2D, visibleOffsetY : CGFloat) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) //
        let region = MKCoordinateRegion(center: coordinate, span: span)
        

        let topLeftCoordinate = CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta / 2, longitude: region.center.longitude - region.span.longitudeDelta / 2)
        let bottomRightCoordinate = CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta / 2, longitude: region.center.longitude + region.span.longitudeDelta / 2)
        
        let topLeft = MKMapPoint(topLeftCoordinate)
        let bottomRight = MKMapPoint(bottomRightCoordinate)
        let height = abs(topLeft.y - bottomRight.y)
        let scale = height / self.MapView.bounds.height
        let mapRect = MKMapRect(x: min(topLeft.x, bottomRight.x), y: min(topLeft.y, bottomRight.y) + visibleOffsetY * scale, width: abs(topLeft.x - bottomRight.x), height: height)
        

        self.MapView.setVisibleMapRect(mapRect, animated: true)
        isPolylinePresented = false
    }
    
}


extension MapViewController : UIGestureRecognizerDelegate {
    func cardViewinit() {
        MapCardViewController.view.frame = CGRect(x: 0, y: standardMinY, width: self.view.bounds.width, height: self.view.bounds.height - self.view.safeAreaInsets.top  )
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.allowedScrollTypesMask = .all
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self
        MapCardViewController.openToggleView.addGestureRecognizer(panGestureRecognizer)
        if let annotationCoordinate = currentPlacemark?.location?.coordinate {
            let annotationPoint = MKMapPoint(annotationCoordinate)
            let pointRect = MKMapRect(Rectwidth: 1500, Rectheight: 1500, mappoint: annotationPoint, moveditance:
                                        standardMinY)
            MapView.setVisibleMapRect(pointRect, animated: true)
        }
        
    }

    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: MapCardViewController.view)

        switch gestureRecognizer.state {
        case .changed:

            if MapCardViewController.view.frame.origin.y <= standardMinY {
                MapCardViewController.view.frame.origin.y = max(self.view.safeAreaInsets.top , MapCardViewController.view.frame.origin.y + translation.y)
                
            } else {
                MapCardViewController.view.frame.origin.y = min(minimunMinY, MapCardViewController.view.frame.origin.y + translation.y)
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: MapCardViewController.view)
            
        case .ended :
            if MapCardViewController.view.frame.origin.y < standardMinY {
                if gestureRecognizer.velocity(in:  MapCardViewController.view).y < 0 {
                    startToSafeAreaFullScreenAnimation()
                } else {
                    startToStandardAnimation()
                    
                }
                return
            }
         
            if gestureRecognizer.velocity(in:  MapCardViewController.view).y < 0 {
                startToStandardAnimation()
            } else {
                if gestureRecognizer.velocity(in:  MapCardViewController.view).y > 0 {
                    startToMininumAnimation()
                }
            }

            
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) { [weak self] in
                guard let self = self else {
                    return
                }
                
                MapView.layer.opacity = Float(max(0.2 , MapCardViewController.view.frame.origin.y + translation.y) / standardMinY + 0.4)
            }
            
        default:
            break
        }
    }
    
}

extension MapViewController {
    func startToStandardAnimation() {
        mapFunctionStackView.translatesAutoresizingMaskIntoConstraints = true
        searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = true
        
        let animator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.8) { [self] in
            MapCardViewController.view.frame.origin.y = standardMinY
            mapFunctionStackView.frame.origin.y = standardMinY + stackViewBottomAnchorContant - mapFunctionStackView.bounds.height
            searchOnGoogleMapsButton.frame.origin.y = standardMinY + stackViewBottomAnchorContant - mapFunctionStackView.bounds.height
            MapView.layer.opacity = 1
        }

        animator.addCompletion { [self] UIViewAnimatingPosition in
            self.mapFunctionStackView.translatesAutoresizingMaskIntoConstraints = false
            searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = false
            cardViewStatus = .standard
            if  !mapIsMoving {
                if isPolylinePresented {
                    showMapRect(rect: self.polylineMapRect, visibleOffsetY: self.bounds.height - cardViewminY)
                } else {
                    if let coordinate = currentPlacemark?.location?.coordinate {
                        showCoordinateOnMap(coordinate: coordinate,visibleOffsetY: bounds.height - cardViewminY)
                    }
                }
            }
        }
        animator.startAnimation()
        
    }
    func startToSafeAreaFullScreenAnimation() {
        mapFunctionStackView.translatesAutoresizingMaskIntoConstraints = true
        searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = true
        safeAreaFullScreenMinY = self.view.safeAreaInsets.top
        
        let animator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.8) { [self] in
            mapFunctionStackView.frame.origin.y = safeAreaFullScreenMinY + stackViewBottomAnchorContant - mapFunctionStackView.bounds.height
            searchOnGoogleMapsButton.frame.origin.y = safeAreaFullScreenMinY + stackViewBottomAnchorContant - mapFunctionStackView.bounds.height
            MapCardViewController.view.frame.origin.y = safeAreaFullScreenMinY
        }
        
        animator.addCompletion { [self] UIViewAnimatingPosition in
            self.mapFunctionStackView.translatesAutoresizingMaskIntoConstraints = false
            searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = false
            cardViewStatus = .safeAreaFullScreen
        }
        animator.startAnimation()
    }
    
    func startToMininumAnimation() {
        mapFunctionStackView.translatesAutoresizingMaskIntoConstraints = true
        searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = true
        
        let animator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.8) { [self] in
            MapCardViewController.view.frame.origin.y = minimunMinY
            searchOnGoogleMapsButton.frame.origin.y = minimunMinY + stackViewBottomAnchorContant - mapFunctionStackView.bounds.height
            mapFunctionStackView.frame.origin.y = minimunMinY + stackViewBottomAnchorContant - mapFunctionStackView.bounds.height
        }

        animator.addCompletion { [self] UIViewAnimatingPosition in
            self.mapFunctionStackView.translatesAutoresizingMaskIntoConstraints = false
            searchOnGoogleMapsButton.translatesAutoresizingMaskIntoConstraints = false
            cardViewStatus = .minium
            if  !mapIsMoving {
                if isPolylinePresented {
                    showMapRect(rect: self.polylineMapRect, visibleOffsetY: self.bounds.height - cardViewminY)
                } else {
                    if let coordinate = currentPlacemark?.location?.coordinate {
                        showCoordinateOnMap(coordinate: coordinate,visibleOffsetY: bounds.height - cardViewminY)
                    }
                }
            }
        }
        animator.startAnimation()
    }
}

