//
//  MappingsResponse.swift
//  WiremockClient
//
//  Created by Ted Rothrock on 2/15/21.
//

import Foundation

struct MappingsResponse: Decodable {

    var isServerRunning: Bool {
        return metaData != nil
    }
    
    init(total: Int) {
        metaData = MetaData(total: total)
    }
    
    private var metaData: MetaData?
    
    private enum CodingKeys : String, CodingKey {
        case metaData = "meta"
    }
    
    private struct MetaData: Decodable {
        var total: Int
    }
}
