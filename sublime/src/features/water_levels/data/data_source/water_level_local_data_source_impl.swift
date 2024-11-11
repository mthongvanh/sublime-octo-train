//
//  water_level_local_data_source_impl.swift
//  sublime
//
//  Created by Michael Thongvanh on 5/4/24.
//

import Foundation

struct WaterLevelLocalDataSourceImpl: WaterLevelLocalDataSource {
    
    var favorites: NSSet?
    
    init() {
        do {
            if let favorites = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSSet.self, NSString.self], from: try Data.init(
                contentsOf: archivePath()
            )) {
                self.favorites = favorites as? NSSet
                print(favorites)
            } else {
                print("no favorites loaded")
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func archivePath() throws -> URL {
        do {
            let url = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appending(
                component: "favorites.archive"
            )
            
            return url
        } catch let error {
            debugPrint(error)
            throw error
        }
    }
    
    mutating func toggleStationFavorite(stationCode: String) async throws -> Bool {
        do {
            let bridgedCode = NSString(string: stationCode)
            let isFavorite = favorites?.contains(where: { favorite in
                favorite as! NSString == bridgedCode
            }) ?? false
            
            let mutableSet: NSMutableSet = favorites?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
            if (isFavorite) {
                mutableSet.remove(bridgedCode)
            } else {
                mutableSet.add(bridgedCode)
            }
            favorites = mutableSet.copy() as? NSSet
            
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: favorites ?? {},
                requiringSecureCoding: false
            )
            
            let archivePath = try archivePath()
            try data.write(to: archivePath)
            
            return !isFavorite
        } catch {
            debugPrint(error)
            throw error
        }
    }
    
    func getFavoriteStatus(stationCode: String) -> Bool {
        return favorites?.contains(stationCode) ?? false
    }
    
    func getFavorites() -> [String] {
        return favorites?.allObjects as! [String]
    }
}
