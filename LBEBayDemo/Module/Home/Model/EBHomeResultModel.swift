//
//  HomeResultModel.swift
//  LBEBayDemo
//
//  Created by liu bin on 2024/12/4.
//

import Foundation
import HandyJSON

enum EBHomeFeatureType:String, HandyJSONEnum {
    case Feature = "Feature"
    case Point = "Point"
}

struct EBHomeResultModel: HandyJSON{
    var features = [EBHomeFeatureModel]()
}

struct EBHomeFeatureModel: HandyJSON {
    var type: EBHomeFeatureType = .Feature
    var properties = EBHomePropertyModel()
    var geometry = EBHomeGeometryModel()
    var id = ""
}

struct EBHomePropertyModel: HandyJSON {
    var mag = 0.0
    var cdi = 0.0
    var place = ""
    var time: TimeInterval = 0
    var url = ""
    var detail = ""
    var title = ""
    
    var magDes = ""
    var cdiDes = ""
    
    mutating func didFinishMapping() {
        magDes = "mag:\(mag)"
        cdiDes = "cdi:\(cdi)"
    }
}

struct EBHomeGeometryModel: HandyJSON {
    var type: EBHomeFeatureType = .Point
    var coordinates = [Double]()
}
