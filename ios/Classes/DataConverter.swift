//
//  DataConverter.swift
//
//  Created by Saltech Systems on 5/10/19.
//

import Foundation
import CouchbaseLiteSwift
import Flutter

extension CBManager {
    static func convertGETValue(_ value: Any?) -> Any? {
        switch (value) {
        case let blob as Blob:
            if let digest = blob.digest {
                // Store the blob for retrieving the content
                setBlobWithDigest(digest, blob: blob)
            }
            
            // Don't return the data, JSONMessageCodec doesn't support it
            return [
                "content_type": blob.contentType as Any,
                "digest": blob.digest as Any,
                "length": blob.length,
                "@type": "blob"
            ]
        case let dict as DictionaryObject:
            return convertGETDictionary(dict)
        case let array as ArrayObject:
            return convertGETArray(array)
        default:
            return value
        }
    }
    
    static func convertGETDictionary(_ dict: DictionaryObject) -> [String: Any] {
        var rtnMap: [String: Any] = [:]
        for key in dict.keys {
            rtnMap[key] = convertGETValue(dict[key].value)
        }
        
        return rtnMap
    }
    
    static func convertGETArray(_ array: ArrayObject) -> [Any?] {
        var rtnList: [Any?] = [];
        for idx in 0..<array.count {
            rtnList.append(convertGETValue(array[idx].value))
        }
        return rtnList
    }
    
    static func convertSETValue(_ value: Any?) -> Any? {
        switch value {
        case let dict as Dictionary<String, Any>:
            let result = convertSETDictionary(dict)
            
            guard let type = result?["@type"] as? String, type == "blob" else {
                return result
            }
            
            if let _ = result?["digest"] as? String {
                // Preserve the map value
                return result
            }
            
            guard let contentType = result?["content_type"] as? String, let data = result?["data"] as? Data else {
                // Preserve the map value
                return result
            }
            
            // Create a new blob
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
    
    static func convertSETDictionary(_ dictionary: [String: Any]?) -> [String: Any]? {
        guard let dict = dictionary else {
            return nil
        }
        
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = convertSETValue(value)
        }
        
        return result
    }
    
    static func convertSETArray(_ array: [Any?]?) -> [Any?]? {
        guard let a = array else {
            return nil
        }
        
        var result: [Any?] = [];
        for v in a {
            result.append(convertSETValue(v))
        }
        return result
    }
}
