//
//  water_level_report_mapper.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation
import cleanboot_swift

private class WaterLevelReportMapper: Mapper {

    typealias Model = WaterLevelReportModel
    
    typealias Entity = WaterLevelReport
    
    func fromEntity(entity: WaterLevelReport) -> WaterLevelReportModel {
        return WaterLevelReportModel(
            waterbody: entity.waterbody,
            waterType: entity.waterType,
            station: entity.station,
            latitude: entity.latitude,
            longitude: entity.longitude,
            dateString: entity.dateString,
            speed: entity.speed,
            depth: entity.depth,
            flow: entity.flow
        )
    }
    
    func toEntity(model: WaterLevelReportModel) -> WaterLevelReport {
        return WaterLevelReport(
            waterbody: model.waterbody,
            waterType: model.waterType,
            station: model.station,
            latitude: model.latitude,
            longitude: model.longitude,
            dateString: model.dateString,
            speed: model.speed,
            depth: model.depth,
            flow: model.flow
        )
    }
    
    func fromARSOToModel(arso: WaterLevelReportARSO) -> WaterLevelReportModel {
        return WaterLevelReportModel(
            waterbody: arso.river,
            waterType: arso.river.isEmpty ? "Other" : "River",
            station: arso.station, 
            latitude: arso.stationLatitude,
            longitude: arso.stationLongitude,
            dateString: arso.date,
            speed: arso.speed,
            depth: arso.depth,
            flow: arso.flow
        )
    }
}

extension WaterLevelReport {
    func toModel() -> WaterLevelReportModel {
        WaterLevelReportMapper().fromEntity(entity: self)
    }
}

extension WaterLevelReportModel {
    func toEntity() -> WaterLevelReport {
        WaterLevelReportMapper().toEntity(model: self)
    }
}

extension WaterLevelReportARSO {
    func toModel() -> WaterLevelReportModel {
        WaterLevelReportMapper().fromARSOToModel(arso: self)
    }
    
    static func fromJSON(json: [String: Any]) -> WaterLevelReportARSO {
        
        let station = valueOrEmptyType(json: json, key: "merilno_mesto", type: String.self)
        let date = valueOrEmptyType(json: json, key: "datum", type: String.self)
        let river = valueOrEmptyType(json: json, key: "reka", type: String.self)
        let stationShortName = valueOrEmptyType(json: json, key: "ime_kratko", type: String.self)
        let flow = valueOrEmptyType(json: json, key: "pretok_znacilni", type: String.self)
        let prviVvPretok = valueOrEmptyType(json: json, key: "prvi_vv_pretok", type: Double.self)
        let drugiVvPretok = valueOrEmptyType(json: json, key: "drugi_vv_pretok", type: Double.self)
        let tretjiVvPretok = valueOrEmptyType(json: json, key: "tretji_vv_pretok", type: Double.self)
        let temperature = valueOrEmptyType(json: json, key: "temp_vode", type: Double.self)
        let depth = valueOrEmptyType(json: json, key: "vodostaj", type: Double.self)
        let speed = valueOrEmptyType(json: json, key: "pretok", type: Double.self)
        let latitude = valueOrEmptyType(json: json, key: "ge_sirina", type: Double.self)
        let longitude = valueOrEmptyType(json: json, key: "ge_dolzina", type: Double.self)
        
        return WaterLevelReportARSO(
            station: station,
            stationShortName: stationShortName,
            stationLatitude: latitude,
            stationLongitude: longitude,
            prviVvPretok: prviVvPretok,
            drugiVvPretok: drugiVvPretok,
            tretjiVvPretok: tretjiVvPretok,
            temperature: temperature,
            date: date,
            river: river,
            depth: depth,
            speed: speed,
            flow: flow
        )
        
    }
    
    fileprivate static func valueOrEmptyType<T>(json: [String:Any], key: String, type: T.Type) -> T {
        if let value = json[key] {
            if (value is T) {
                return value as! T
            } else {
                return cast(value, type: T.self)
            }
        } else {
            return valueDefaultForType(type: T.self)
        }
        
    }
    
    fileprivate static func valueDefaultForType<T>(type: T.Type) -> T {
         if (type == Double.self) {
            return 0.0 as! T
        } else {
            return "" as! T
        }
    }
    
    fileprivate static func cast<T>(_ value: Any, type: T.Type) -> T {
        if value.self as? any Any.Type != type {
            if (type == Double.self && value is String) {
                if (value as! String == "") {
                    // framework is unable to parse an empty string when instantiating a Double from a String
                    return 0.0 as! T
                } else {
                    return Double(value as! String) as! T
                }
            } else {
                return "" as! T
            }
        } else {
            return value as! T
        }
    }
}
