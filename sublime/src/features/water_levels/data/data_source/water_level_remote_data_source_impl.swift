//
//  water_level_remote_data_source_impl.swift
//  sublime
//
//  Created by Michael Thongvanh on 4/23/24.
//

import Foundation

struct WaterLevelRemoteDataSourceImpl: WaterLevelRemoteDataSource {
    
    fileprivate let httpClient = URLSession(configuration: URLSessionConfiguration.default)
    var waterLevelAPI: WaterLevelAPI
    
    init(waterLevelAPI: WaterLevelAPI) {
        self.waterLevelAPI = waterLevelAPI
    }
    
    func getWaterLevels() async throws -> [WaterLevelReportModel] {
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
