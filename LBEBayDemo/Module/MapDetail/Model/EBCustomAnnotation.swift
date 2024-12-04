//
//  EBCustomAnnotation.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import Foundation
import MapKit

/// 自定义大头针模型
class EBCustomAnnotation:NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
