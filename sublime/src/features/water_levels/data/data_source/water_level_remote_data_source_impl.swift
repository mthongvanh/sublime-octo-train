//
//  water_level_remote_data_source_impl.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation
import SwiftSoup

struct WaterLevelRemoteDataSourceImpl: WaterLevelRemoteDataSource {
    func getWaterLevels() async throws -> [WaterLevelReportModel] {
        return try await getRecentLevels()
    }
    
    func getHistoricalData(stationCode: String, span: ObservationSpan) async throws -> [HistoricalDataPointModel] {
        
        var days: Int
        switch span {
        case .sevenDays:
            days = 7
        case .thirtyDays:
            days = 30
        default:
            days = 1
        }
        
        let (data, _) = try await httpClient.data(
            from: waterLevelAPI.span(
                stationCode: stationCode,
                days: days
            )
        )
        
        var dataPoints = [HistoricalDataPointModel]()
        
        let parser = ARSOWaterLevelParser()
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw(Exception.Error(type: .IOException, Message: "Error converting ARSO html strin"))
        }
        
        let items = try parser.parse(html: htmlString)
        
        for (text, _) in items {
            let waterData = text.components(separatedBy: .whitespaces)
            if (waterData.count == 5 && waterData[0].range(of: ".2024") != nil) {
                dataPoints.append(
                    HistoricalDataPointModel(
                        stationCode: stationCode,
                        recordDate: "\(waterData[0]) \(waterData[1])",
                        depth: Int(waterData[2]) ?? 0,
                        speed: Double(waterData[3]) ?? 0.0,
                        temperature: Double(waterData[4]) ?? 0.0
                    )
                )
            }
        }
        
        return dataPoints
    }
    
    
    fileprivate let httpClient = URLSession(configuration: URLSessionConfiguration.default)
    var waterLevelAPI: WaterLevelAPI
    
    init(waterLevelAPI: WaterLevelAPI) {
        self.waterLevelAPI = waterLevelAPI
    }
    
    private func getRecentLevels() async throws -> [WaterLevelReportModel] {
        let (data, _) = try await httpClient.data(from: waterLevelAPI.latest)
        let xmlParser = XMLParser(data: data)
        let parserDelegate = WaterLevelXMLParser()
        xmlParser.delegate = parserDelegate
        xmlParser.parse()
        guard parserDelegate.error == nil else {
            throw URLError(URLError.badServerResponse)
        }
        
        do {
            let arsoReports = try parserDelegate.reports.map<WaterLevelReport>({ json in
                WaterLevelReportARSO.fromJSON(json: json).toModel()
            })
            return arsoReports
        } catch {
            print(error)
            throw error
        }
        
    }
}

class WaterLevelXMLParser: NSObject, XMLParserDelegate {
    var finished = false
    var currentText = ""
    var currentReport = [String: Any]()
    var currenAttributes = [String: String]()
    public var reports = [[String: Any]]()
    public var error: Error?
    
    //    func parserDidStartDocument(_ parser: XMLParser) {
    //        print("Start of the document")
    //        print("Line number: \(parser.lineNumber)")
    //    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //        debugPrint("didStartElement: \(elementName) - attributes \(attributeDict) - qualifiedName \(qName ?? "none")")
        currentText = ""
        if (!attributeDict.values.isEmpty) {
            currenAttributes = attributeDict
            currentReport["ge_sirina"] = attributeDict["ge_sirina"]
            currentReport["ge_dolzina"] = attributeDict["ge_dolzina"]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            //            print(string)
            currentText.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "postaja") {
            reports.append(currentReport)
            currentReport = [String:AnyObject]()
        } else {
            currentReport[elementName] = currentText as AnyObject
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        error = parseError
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: any Error) {
        error = validationError
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        //        debugPrint("End of the document")
        //        debugPrint("Line number: \(parser.lineNumber)")
        finished = true
    }
}

class ARSOWaterLevelParser {
    
    typealias Item = (text: String, html: String)
    
    // current document
    var document: Document = Document.init("")
    
    
    //Parse CSS selector
    func parse(html: String) throws -> [Item] {
        do {
            // parse it into a Document
            document = try SwiftSoup.parse(html)
            // parse css query
            let css = "tr"
            
            //empty old items
            var items = [Item]()
            // firn css selector
            let elements: Elements = try document.select(css)
            
            let date = Calendar.current.dateComponents([.year], from: Date.now)
            
            for element in elements {
                let text = try element.text()
                let matchString = ".\(date.year ?? 1999) "
                let match = text.range(of: matchString)
                if (match != nil) {
                    let html = try element.outerHtml()
                    items.append(Item(text: text, html: html))
                } else {
                    debugPrint("not found \(text)")
                }
            }

            return items
        } catch let error {
            throw error
        }
    }
}
