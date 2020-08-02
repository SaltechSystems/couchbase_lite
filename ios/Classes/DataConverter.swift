//
//  DataConverter.swift
//
//  Created by Saltech Systems on 5/10/19.
//

import Foundation
import CouchbaseLiteSwift
import Flutter

class DataConverter {
    static func convertSETValue(_ value: Any?, origin: Any? = nil) -> Any? {
        switch value {
        case let dict as Dictionary<String, Any>:
            let result = convertSETDictionary(dict, origin: nil)
            
            guard let type = result?["@type"] as? String, type == "blob" else {
                return result
            }
            
            guard let contentType = result?["content_type"] as? String, let data = result?["data"] as? Data else {
                // Preserve the original value
                return origin
            }
            
            if let blob = origin as? Blob, let digest = result?["digest"] as? String, digest == blob.digest {
                // Prevent blob from updating when it doesn't change
                return blob
            }
            
            return Blob(contentType: contentType, data: data)
        case let array as Array<Any>:
            return convertSETArray(array)
        case let bool as NSNumber:
            if (bool === kCFBooleanTrue || bool === kCFBooleanFalse) {
                return bool === kCFBooleanTrue
            } else {
                return value
            }
        case let flutterData as FlutterStandardTypedData:
            return flutterData.data
        default:
            return value
        }
    }
    
    static func convertSETDictionary(_ dictionary: [String: Any]?, origin: [String: Any]? = nil) -> [String: Any]? {
        guard let dict = dictionary else {
            return nil
        }
        
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = DataConverter.convertSETValue(value, origin: origin?[key])
        }
        
        return result
    }
    
    static func convertSETArray(_ array: [Any]?, origin: [Any]? = nil) -> [Any]? {
        guard let a = array else {
            return nil
        }
        
        var result: [Any] = [];
        for v in a {
            result.append(DataConverter.convertSETValue(v)!)
        }
        return result
    }
}
