//
//  water_level_local_data_source_impl.swift
//  sublime
//
//  Created by Michael Thongvanh on 5/4/24.
//

import Foundation
import SwiftUI

struct WaterLevelLocalDataSourceImpl: WaterLevelLocalDataSource {
    
    
    var favorites: NSMutableSet?
    
    init() {
        do {
            if let favorites = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSMutableSet.self, NSString.self], from: try Data.init(
                contentsOf: archivePath()
            )) {
                self.favorites = favorites as? NSMutableSet
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
            favorites = mutableSet
            
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
    
    func getFavorites() -> Binding<[String]> {
        return Binding {
            favorites?.allObjects as? [String] ?? [String]()
        } set: { stationCode in
            let favorites = favorites?.allObjects as? [String] ?? [String]()
            for code in favorites {
                if let index = favorites.firstIndex(where: { $0 == code }) {
                    self.favorites?.remove(favorites[index])
                    self.favorites?.add(code)
                }
            }
        }
    }
}
