import Flutter
import UIKit
import CouchbaseLiteSwift

public class SwiftCouchbaseLitePlugin: NSObject, FlutterPlugin, CBManagerDelegate {
    weak var mRegistrar: FlutterPluginRegistrar?
    let mDatabaseEventListener = DatabaseEventListener()
    let mQueryEventListener = QueryEventListener();
    let mReplicatorEventListener = ReplicatorEventListener();
    let databaseDispatchQueue = DispatchQueue(label: "DatabaseDispatchQueue", qos: .background)
    
    #if DEBUG
    lazy var mCBManager = CBManager(delegate: self, logLevel: .debug)
    #else
    lazy var mCBManager = CBManager(delegate: self, logLevel: .error)
    #endif
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftCouchbaseLitePlugin(registrar: registrar)
        
        let databaseChannel = FlutterMethodChannel(name: "com.saltechsystems.couchbase_lite/database", binaryMessenger: registrar.messenger())
        databaseChannel.setMethodCallHandler(instance.handleDatabase(_:result:))
        
        let databaseEventChannel = FlutterEventChannel(name: "com.saltechsystems.couchbase_lite/databaseEventChannel", binaryMessenger: registrar.messenger())
        databaseEventChannel.setStreamHandler(instance.mDatabaseEventListener as? FlutterStreamHandler & NSObjectProtocol)
        
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
    
    private func inflateValueIndex(items: [Dictionary<String, Any>] ) -> ValueIndex? {
        
        var indices: Array<ValueIndexItem> = [];
        for item in items {
            if let value = item["expression"], let array = value as? [Dictionary<String, Any>] {
                let expression = QueryJson.inflateExpressionFromArray(expressionParametersArray: array);
                indices.append(ValueIndexItem.expression(expression));
            } else if let value = item["property"], let name = value as? String {
                indices.append(ValueIndexItem.property(name))
            } else {
                return nil //Unsupported value index item
            }
        }
        
        return IndexBuilder.valueIndex(items: indices)
        
    }
    
    private func inflateFullTextIndex(items: [Dictionary<String, Any>] ) -> FullTextIndex? {
        
        var indices: Array<FullTextIndexItem> = [];
        var ignoreAccents: Bool?
        var language: String?
        for item in items {
            if let value = item["property"], let name = value as? String {
                indices.append(FullTextIndexItem.property(name))
            } else if let value = item["ignoreAccents"], let boolValue = value as? Bool {
                ignoreAccents = boolValue
            } else if let value = item["language"], let languageCode = value as? String {
                language = languageCode
            } else {
                return nil //Unsupported full-text index item
            }
        }
        
        var index = IndexBuilder.fullTextIndex(items: indices)
        if let ignoreAccents = ignoreAccents{
            index = index.ignoreAccents(ignoreAccents)
        }
        if let language = language {
            index = index.language(language)
        }
        
        
        return index
        
    }
    
    public func handleDatabase(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "setConsoleLogLevel":
            guard let arguments = call.arguments as? [String:Any], let level = arguments["level"] as? String else {
                result(FlutterError(code: "errArgs", message: "Error: Missing database", details: call.arguments.debugDescription))
                return
            }
            let logLevel: LogLevel
            switch (level) {
            case "none":
                logLevel = .none
            case "debug":
                logLevel = .debug
            case "info":
                logLevel = .info
            case "warning":
                logLevel = .warning
            case "error":
                logLevel = .error
            case "verbose":
                logLevel = .verbose
            default:
                logLevel = .none
            }
    
            mCBManager.setConsoleLogLevel(logLevel: logLevel)
            result(nil)
            return
        case "clearBlobCache":
            CBManager.clearBlobCache()
            result(nil)
            return
        case "getBlobContentWithDigest":
            guard let arguments = call.arguments as? [String:Any], let digest = arguments["digest"] as? String else {
                result(FlutterError(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            // Don't load the content if it isn't found
            if let blob = CBManager.getBlobWithDigest(digest), let data = blob.content {
                result(FlutterStandardTypedData(bytes: data))
            } else {
                result(nil)
            }
            return
        default:
            break
        }
        
        // All other methods are database dependent
        guard let arguments = call.arguments as? [String:Any], let dbname = arguments["database"] as? String else {
            result(FlutterError(code: "errArgs", message: "Error: Missing database", details: call.arguments.debugDescription))
            return
        }
        
        switch (call.method) {
        case "initDatabaseWithName":
            do {
                let database = try mCBManager.initDatabaseWithName(name: dbname)
                result(["name": database.name, "path": database.path])
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
        case "compactDatabaseWithName":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            do {
                try database.compact()
                result(nil)
            } catch {
                result(FlutterError.init(code: "errCompact", message: "Error compacting database with name \(dbname)", details: error.localizedDescription))
            }
        case "createIndex":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            guard let indexName = arguments["withName"] as? String, let index = arguments["index"] as? [Dictionary<String, Any>] else {
                result(FlutterError.init(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            guard let valueIndex = inflateValueIndex(items: index) else {
                result(FlutterError.init(code: "errIndex", message: "Error creating index \(indexName)", details: "Failed to inflate valueIndex"))
                return
            }
            
            databaseDispatchQueue.async {
                do {
                    try database.createIndex(valueIndex, withName: indexName);
                    DispatchQueue.main.async {
                        result(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError.init(code: "errIndex", message: "Error creating index \(indexName)", details: error.localizedDescription))
                    }
                }
            }
            
        case "createFullTextIndex":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            guard let indexName = arguments["withName"] as? String, let index = arguments["index"] as? [Dictionary<String, Any>] else {
                result(FlutterError.init(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            guard let fullTextIndex = inflateFullTextIndex(items: index) else {
                result(FlutterError.init(code: "errIndex", message: "Error creating index \(indexName)", details: "Failed to inflate fullTextIndex"))
                return
            }
            
            databaseDispatchQueue.async {
                do {
                    try database.createIndex(fullTextIndex, withName: indexName);
                    DispatchQueue.main.async {
                        result(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError.init(code: "errIndex", message: "Error creating index \(indexName)", details: error.localizedDescription))
                    }
                }
            }
            
            
        case "deleteIndex":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            guard let indexName = arguments["forName"] as? String else {
                result(FlutterError.init(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            databaseDispatchQueue.async {
                do {
                    try database.deleteIndex(forName: indexName);
                    DispatchQueue.main.async {
                        result(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError.init(code: "errIndex", message: "Error deleting index \(indexName)", details: error.localizedDescription))
                    }
                }
            }
            
            
        case "deleteDatabaseWithName":
            do {
                try mCBManager.deleteDatabaseWithName(name: dbname)
                result(nil)
            } catch {
                result(FlutterError.init(code: "errDelete", message: "Error deleting database with name \(dbname)", details: error.localizedDescription))
            }
        case "saveDocument":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let concurrencyControlArg = arguments["concurrencyControl"] as? String, let document = arguments["map"] as? [String:Any] else {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: nil))
                return
            }
            
            let concurrencyControl: ConcurrencyControl
            switch(concurrencyControlArg) {
            case "failOnConflict":
                concurrencyControl = ConcurrencyControl.failOnConflict
            default:
                concurrencyControl = ConcurrencyControl.lastWriteWins
            }
            
            do {
                let saveResult = try mCBManager.saveDocument(database: database,map: document,concurrencyControl: concurrencyControl)
                result(saveResult)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document", details: error.localizedDescription))
            }
        case "saveDocumentWithId":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let id = arguments["id"] as? String, let concurrencyControlArg = arguments["concurrencyControl"] as? String, let map = arguments["map"] as? [String:Any] else {
                result(FlutterError(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            let concurrencyControl: ConcurrencyControl
            switch(concurrencyControlArg) {
            case "failOnConflict":
                concurrencyControl = ConcurrencyControl.failOnConflict
            default:
                concurrencyControl = ConcurrencyControl.lastWriteWins
            }
            
            do {
                let sequenceValue: UInt64?
                switch(arguments["sequence"]) {
                case let value as NSNumber:
                    sequenceValue = value.uint64Value
                case let value as Int:
                    sequenceValue = UInt64(value)
                case let value as UInt64:
                    sequenceValue = value
                default:
                    sequenceValue = nil
                }
                
                let saveResult: NSMutableDictionary
                if let sequence = sequenceValue {
                    saveResult = try mCBManager.saveDocumentWithId(database: database, id: id, sequence: sequence, map: map, concurrencyControl: concurrencyControl)
                }else {
                    saveResult = try mCBManager.saveDocumentWithId(database: database, id: id, map: map, concurrencyControl: concurrencyControl)
                }
                
                result(saveResult)
            } catch {
                result(FlutterError.init(code: "errSave", message: "Error saving document with id \(id)", details: error.localizedDescription))
            }
        case "deleteDocumentWithId":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let id = arguments["id"] as? String else {
                result(FlutterError(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
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
                result(FlutterError(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            if let returnMap = mCBManager.getDocumentWithId(database: database, id: id) {
                result(NSDictionary(dictionary: returnMap))
            } else {
                result(nil)
            }
        case "getBlobContentWithDigest":
            guard let digest = arguments["digest"] as? String else {
                result(FlutterError(code: "errArgs", message: "Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            // Don't load the content if it isn't found
            if let blob = CBManager.getBlobWithDigest(digest), let data = blob.content {
                result(FlutterStandardTypedData(bytes: data))
            } else {
                result(nil)
            }
        case "getDocumentCount":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            result(database.count)
        case "getIndexes":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            result(database.indexes)
            
        case "addChangeListener":
            guard let database = mCBManager.getDatabase(name: dbname) else {
                result(FlutterError.init(code: "errDatabase", message: "Database with name \(dbname) not found", details: nil))
                return
            }
            
            guard let _ = mCBManager.getDatabaseListenerToken(dbname: dbname) else {
                let token = database.addChangeListener(withQueue: databaseDispatchQueue, listener: { [weak self] change in
                    var map = Dictionary<String,Any?>()
                    map["type"] = "DatabaseChange"
                    map["database"] = change.database.name
                    map["documentIDs"] = change.documentIDs
                    
                    DispatchQueue.main.async {
                        // Will only send events when there is something listening
                        self?.mDatabaseEventListener.mEventSink?(map)
                    }
                })
                
                mCBManager.addDatabaseListenerToken(dbname: dbname, token: token)
                result(true)
                return
            }
            
            
            result(true)
            
        case "removeChangeListener":
            
            do {
                try mCBManager.removeDatabaseListenerToken(dbname: dbname)
                result(nil)
            } catch {
                result(FlutterError(code: "errDatabase", message: "Error removing database listener token", details: nil))
            }
            
            
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
            
            guard let query = mCBManager.getQuery(queryId: queryId) ?? QueryJson(json: options, manager: mCBManager).toCouchbaseQuery() else {
                result(FlutterError(code: "errQuery", message: "Error generating query", details: nil))
                return
            }
            
            databaseDispatchQueue.async {
                do {
                    let json = QueryJson.resultSetToJson(results: try query.execute())
                    DispatchQueue.main.async {
                        result(json)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "errQuery", message: "Error executing query", details: error.localizedDescription))
                    }
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
                    
                    DispatchQueue.main.async {
                        // Will only send events when there is something listening
                        self?.mQueryEventListener.mEventSink?(NSDictionary(dictionary: json as [AnyHashable : Any]))
                    }
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
            
        case "explainQuery":
            guard let options = call.arguments as? [String:Any], let queryId = options["queryId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Query Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            guard let query = mCBManager.getQuery(queryId: queryId) ?? QueryJson(json: options, manager: mCBManager).toCouchbaseQuery() else {
                result(FlutterError(code: "errQuery", message: "Error generating query", details: nil))
                return
            }
            
            // This could be a time consuming task.
            databaseDispatchQueue.async {
                do {
                    let explanation = try query.explain()
                    DispatchQueue.main.async {
                        result(explanation)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "errQuery", message: "Error explaining query", details: error.localizedDescription))
                    }
                }
            }
            
            
        case "storeReplicator":
            guard let json = call.arguments as? [String:Any], let replicatorId = json["replicatorId"] as? String else {
                result(FlutterError(code: "errArgs", message: "Replicator Error: Invalid Arguments", details: call.arguments.debugDescription))
                return
            }
            
            do {
                let replicator = try mCBManager.inflateReplicator(json: json)
                let changeToken = replicator.addChangeListener { [weak self] change in
                    var map = ["replicator":replicatorId,"type":"ReplicatorChange"]
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
                
                let documentToken = replicator.addDocumentReplicationListener { [weak self] replication in
                    let map = NSMutableDictionary.init(dictionary: ["replicator":replicatorId,"type":"DocumentReplication"])
                    map["isPush"] = replication.isPush
                    
                    let documents = NSMutableArray()
                    replication.documents.forEach { (document) in
                        let documentReplication = NSMutableDictionary.init(dictionary: ["document":document.id])
                        if let error = document.error {
                            documentReplication["error"] = error.localizedDescription
                        }
                        documentReplication["flags"] = document.flags.rawValue
                        documents.add(documentReplication)
                    }
                    
                    map["documents"] = documents
                    
                    self?.mReplicatorEventListener.mEventSink?(map)
                }
                
                mCBManager.addReplicator(replicationId: replicatorId, replicator: replicator, listenerTokens: [changeToken,documentToken])
                result(nil)
            } catch {
                result(FlutterError(code: "errReplicator", message: "Replicator Error: Invalid Arguments", details: error.localizedDescription))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
