import Flutter
import UIKit

public class SwiftCouchbaseLitePlugin: NSObject, FlutterPlugin, CBManagerDelegate {
    weak var mRegistrar: FlutterPluginRegistrar?
    let mQueryEventListener = QueryEventListener();
    let mReplicatorEventListener = ReplicatorEventListener();
    let databaseDispatchQueue = DispatchQueue(label: "DatabaseDispatchQueue", qos: .background)
    
    #if DEBUG
    lazy var mCBManager = CBManager(delegate: self, enableLogging: true)
    #else
    lazy var mCBManager = CBManager(delegate: self, enableLogging: false)
    #endif
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftCouchbaseLitePlugin(registrar: registrar)
        
        let databaseChannel = FlutterMethodChannel(name: "com.saltechsystems.couchbase_lite/database", binaryMessenger: registrar.messenger())
        databaseChannel.setMethodCallHandler(instance.handleDatabase(_:result:))
        
        let replicatorChannel = FlutterMethodChannel(name: "com.saltechsystems.couchbase_lite/replicator", binaryMessenger: registrar.messenger())
        replicatorChannel.setMethodCallHandler(instance.handleReplicator(_:result:))
        
        let jsonMethodChannel = FlutterMethodChannel(name: "com.saltechsystems.couchbase_lite/json", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        jsonMethodChannel.setMethodCallHandler(instance.handleJson(_:result:))
        
        let replicatorEventChannel = FlutterEventChannel(name: "com.saltechsystems.couchbase_lite/replicationEventChannel", binaryMessenger: registrar.messenger())
        replicatorEventChannel.setStreamHandler(instance.mReplicatorEventListener as? FlutterStreamHandler & NSObjectProtocol)
        
        let queryEventChannel = FlutterEventChannel(name: "com.saltechsystems.couchbase_lite/queryEventChannel", binaryMessenger: registrar.messenger(), codec: FlutterJSONMethodCodec.sharedInstance())
        queryEventChannel.setStreamHandler(instance.mQueryEventListener as? FlutterStreamHandler & NSObjectProtocol)
    }
    
    init(registrar: FlutterPluginRegistrar) {
        super.init()
        
        mRegistrar = registrar
    }
    
    func lookupKey(forAsset assetKey: String) -> String? {
        return mRegistrar?.lookupKey(forAsset: assetKey)
    }
    
    public func handleDatabase(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String:Any], let dbname = arguments["database"] as? String else {
            result(FlutterError(code: "errArgs", message: "Error: Missing database", details: call.arguments.debugDescription))
            return
        }
        
        switch (call.method) {
        case "initDatabaseWithName":
            do {
                let database = try mCBManager.initDatabaseWithName(name: dbname)
                result(database.name)
            } catch {
                result(FlutterError.init(code: "errInit", message: "Error initializing database with name \(dbname)", details: error.localizedDescription))
            }
        case "closeDatabaseWithName":
            do {
                try mCBManager.closeDatabaseWithName(name: dbname)
                result(nil)
            } catch {
                result(FlutterError.init(code: "errClose", message: "Error closing database with name \(dbname)", details: error.localizedDescription))
            }
        case "deleteDatabaseWithName":
            do {
                try mCBManager.deleteDatabaseWithName(name: dbname)
                result(nil)
            } catch {
                result(FlutterError.init(code: "errDelete", message: "Error deleting database with name \(dbname)", details: error.localizedDescription))
            }
        case "delete":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            do {
                try database.delete();
                result(nil)
            } catch {
                result(FlutterError.init(code: "errDelete", message: "Error deleting database with name \(dbname)", details: error.localizedDescription))
            }
        case "saveDocument":
            guard let document = DataConverter.convertSETDictionary(arguments["map"] as? [String:Any]) else {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: nil))
                return
            }
            
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            do {
                let returnedId = try mCBManager.saveDocument(database: database,map: document)
                result(returnedId!)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: error.localizedDescription))
            }
        case "saveDocumentWithId":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let id = arguments["id"] as? String, let map = DataConverter.convertSETDictionary(arguments["map"] as? [String:Any]) else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            do {
                let returnedId = try mCBManager.saveDocumentWithId(database: database, id: id, map: map)
                result(returnedId)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document with id \(id)", details: error.localizedDescription))
            }
        case "deleteDocumentWithId":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let id = arguments["id"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            do {
                try mCBManager.deleteDocumentWithId(database: database, id: id)
                result(nil)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document with id \(id)", details: error.localizedDescription))
            }
        case "getDocumentWithId":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let id = arguments["id"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            if let returnMap = mCBManager.getDocumentWithId(database: database, id: id) {
                result(NSDictionary(dictionary: returnMap))
            } else {
                result(nil)
            }
        case "getDocumentCount":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            result(database.count)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func handleReplicator(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String:Any], let replicatorId = arguments["replicatorId"] as? String else {
            result(FlutterError(code: "errArgs", message: "Error: Missing replicator", details: call.arguments.debugDescription))
            return
        }
        
        guard let replicator = mCBManager.getReplicator(replicationId: replicatorId) else {
            result(FlutterError(code: "errReplicator", message: "Error: Replicator already disposed", details: nil))
            return
        }
        
        switch (call.method) {
        case "start":
            replicator.start()
            result(nil)
        case "stop":
            replicator.stop()
            result(nil)
        case "resetCheckpoint":
            replicator.resetCheckpoint()
            result(nil)
        case "dispose":
            let _ = mCBManager.removeReplicator(replicationId: replicatorId)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func handleJson(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        /* call.arguments:
         * Supported messages are acyclic values of these forms: null, bools, nums,
         * Strings, Lists of supported values, Maps from strings to supported values
         **/
        
        switch (call.method) {
        case "executeQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            let query = mCBManager.getQuery(queryId: queryId) ?? QueryJson(json: options, manager: mCBManager).toCouchbaseQuery()
            
            databaseDispatchQueue.async {
                do {
                    if let results = try query?.execute() {
                        let json = QueryJson.resultSetToJson(results: results)
                        result(json)
                    } else {
                        result(FlutterError(code: "errQuery", message: "Error executing query", details: "Something went wrong with the query"))
                    }
                } catch {
                    result(FlutterError(code: "errQuery", message: "Error executing query", details: error.localizedDescription))
                }
            }
        case "storeQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            if let _ = mCBManager.getQuery(queryId: queryId) {
                // DO NOTHING QUERY IS ALREADY STORED
                result(true)
            } else if let query = QueryJson(json: options, manager: mCBManager).toCouchbaseQuery() {
                // Store Query for later use
                let token = query.addChangeListener(withQueue: databaseDispatchQueue) { [weak self] change in
                    var json = Dictionary<String,Any?>()
                    json["query"] = queryId
                    
                    if let results = change.results {
                        json["results"] = QueryJson.resultSetToJson(results: results)
                    }
                    
                    if let error = change.error {
                        json["error"] = error.localizedDescription
                    }
                    
                    // Will only send events when there is something listening
                    self?.mQueryEventListener.mEventSink?(NSDictionary(dictionary: json as [AnyHashable : Any]))
                }
                
                mCBManager.addQuery(queryId: queryId, query: query, listenerToken: token)
                result(true)
            } else {
                result(false)
            }
        case "removeQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            let _ = mCBManager.removeQuery(queryId: queryId)
            result(true)
        case "storeReplicator":
            guard let json = call.arguments as? [String:Any], let replicatorId = json["replicatorId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Replicator Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            do {
                let replicator = try mCBManager.inflateReplicator(json: json)
                let token = replicator.addChangeListener { [weak self] change in
                    var map = ["replicator":replicatorId]
                    if let error = change.status.error {
                        map["error"] = error.localizedDescription
                    }
                    
                    switch (change.status.activity) {
                    case .busy:
                        map["activity"] = "BUSY"
                    case .idle:
                        map["activity"] = "IDLE"
                    case .offline:
                        map["activity"] = "OFFLINE"
                    case .stopped:
                        map["activity"] = "STOPPED"
                    case .connecting:
                        map["activity"] = "CONNECTING"
                    }
                    
                    self?.mReplicatorEventListener.mEventSink?(map)
                }
                
                mCBManager.addReplicator(replicationId: replicatorId, replicator: replicator, listenerToken: token)
                result(nil)
            } catch {
                result(FlutterError(code: "errReplicator", message: "Replicator Error: Invalid Arguments", details: error.localizedDescription))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
