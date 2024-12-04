//
//  EBEarthPositionMapDetailController.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import UIKit
import MapKit

class EBEarthPositionMapDetailController: UIViewController {
    
    var defaultTitle = "地震预警位置"
    var lat: CLLocationDegrees = 0.0
    var lon: CLLocationDegrees = 0.0
    
    private lazy var centerCoor = CLLocationCoordinate2D.init(latitude: lat, longitude: lon)
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.centerCoordinate = centerCoor
        let span = MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
        let region = MKCoordinateRegion(center: centerCoor, span: span)
        mapView.region = region
        mapView.showsUserLocation = true
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = defaultTitle
        addMapView()
        addAnnotation()
    }
    
    private func addMapView()  {
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 添加大头针
    private func addAnnotation(){
        let annotation = EBCustomAnnotation.init(coordinate: centerCoor)
        annotation.title = defaultTitle
        mapView.addAnnotation(annotation)
    }
    

}
