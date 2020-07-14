//
//  DatabaseEventListener.swift
//  couchbase_lite
//
//  Created by Kin Mak on 8/7/2020.
//

import Foundation
import CouchbaseLiteSwift

class DatabaseEventListener: FlutterStreamHandler {
    var mEventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        mEventSink = events
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        
        
        return nil
    }
}
