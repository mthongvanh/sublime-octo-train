//
//  historical_data_point_mapper.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/29/24.
//

import Foundation
import cleanboot_swift

private class HistoricalDataPointMapper: Mapper {

    typealias Model = HistoricalDataPointModel
    
    typealias Entity = HistoricalDataPoint
    
    func fromEntity(entity: HistoricalDataPoint) -> HistoricalDataPointModel {
        return HistoricalDataPointModel(
            stationCode: entity.stationCode,
            recordDate: entity.recordDate,
            depth: entity.depth,
            speed: entity.speed,
            temperature: entity.temperature
        )
    }
    
    func toEntity(model: HistoricalDataPointModel) -> HistoricalDataPoint {
        return HistoricalDataPoint(
            stationCode: model.stationCode,
            recordDate: model.recordDate,
            depth: model.depth,
            speed: model.speed,
            temperature: model.temperature
        )
    }
}

extension HistoricalDataPoint {
    func toModel() -> HistoricalDataPointModel {
        HistoricalDataPointMapper().fromEntity(entity: self)
    }
}

extension HistoricalDataPointModel {
    func toEntity() -> HistoricalDataPoint {
        HistoricalDataPointMapper().toEntity(model: self)
    }
}
/*
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
*/
