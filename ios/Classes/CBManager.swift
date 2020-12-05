//
//  CBManager.swift
//  Runner
//
//  Created by Luca Christille on 14/08/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

typealias ExpressionJson = Array<Dictionary<String,Any>>

enum CBManagerError: Error {
    case CertificatePinning
    case MissingArgument
    case IllegalArgument
    case DatabaseNotFound
}

protocol CBManagerDelegate : class {
    func lookupKey(forAsset assetKey: String) -> String?
}

class CBManager {
    private var mDatabase : Dictionary<String, Database> = Dictionary();
    private var mQueries : Dictionary<String,Query> = Dictionary();
    private var mQueryListenerTokens : Dictionary<String,ListenerToken> = Dictionary();
    private var mReplicators : Dictionary<String,Replicator> = Dictionary();
    private var mReplicatorListenerTokens : Dictionary<String,[ListenerToken]> = Dictionary();
    private var mDatabaseListenerTokens : Dictionary<String, ListenerToken> = Dictionary();
    private var mDBConfig = DatabaseConfiguration();
    private weak var mDelegate: CBManagerDelegate?
    private static var mBlobs : Dictionary<String,Blob> = Dictionary()
    
    init(delegate: CBManagerDelegate, logLevel: LogLevel) {
        mDelegate = delegate
        Database.log.console.level = logLevel
    }
    
    func getDatabase(name : String) -> Database? {
        if let result = mDatabase[name] {
            return result;
        } else {
            return nil;
        }
    }
    
    func saveDocument(database: Database, map: Dictionary<String, Any>, concurrencyControl: ConcurrencyControl) throws -> NSMutableDictionary {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        let mutableDocument: MutableDocument = MutableDocument(data: CBManager.convertSETDictionary(map));
        let success = try database.saveDocument(mutableDocument, concurrencyControl: concurrencyControl)
        resultMap["success"] = success
        if (success) {
            resultMap["id"] = mutableDocument.id
            resultMap["sequence"] = mutableDocument.sequence
            resultMap["doc"] = _documentToMap(mutableDocument)
        }
        return resultMap
    }
    
    func saveDocumentWithId(database: Database, id: String, map: Dictionary<String, Any>, concurrencyControl: ConcurrencyControl) throws -> NSMutableDictionary {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        let mutableDocument: MutableDocument = MutableDocument(id: id, data: CBManager.convertSETDictionary(map))
        let success = try database.saveDocument(mutableDocument, concurrencyControl: concurrencyControl)
        resultMap["success"] = success
        if (success) {
            resultMap["id"] = mutableDocument.id
            resultMap["sequence"] = mutableDocument.sequence
            resultMap["doc"] = _documentToMap(mutableDocument)
        }
        return resultMap
    }
    
    func saveDocumentWithId(database: Database, id: String, sequence: UInt64, map: Dictionary<String, Any>, concurrencyControl: ConcurrencyControl) throws -> NSMutableDictionary {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        let document = database.document(withID: id)
        
        if let currentSequence = document?.sequence, sequence != currentSequence {
            resultMap["success"] = false
            return resultMap
        }
        
        let mutableDocument: MutableDocument = document?.toMutable() ?? MutableDocument(id: id)
        mutableDocument.setData(CBManager.convertSETDictionary(map))
        
        let success = try database.saveDocument(mutableDocument, concurrencyControl: concurrencyControl)
        resultMap["success"] = success
        if (success) {
            resultMap["id"] = mutableDocument.id
            resultMap["sequence"] = mutableDocument.sequence
            resultMap["doc"] = _documentToMap(mutableDocument)
        }
        return resultMap
    }
    
    func deleteDocumentWithId(database: Database, id: String) throws {
        if let document = database.document(withID: id) {
            try database.deleteDocument(document)
        }
    }
    
    func getDocumentWithId(database: Database, id: String) -> NSDictionary? {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        if let document: Document = database.document(withID: id) {
            // It is a repetition due to implementation of Document Dart Class
            resultMap["id"] = document.id
            resultMap["sequence"] = document.sequence
            resultMap["doc"] = NSDictionary.init(dictionary:_documentToMap(document))
        } else {
            resultMap["id"] = id
            resultMap["doc"] = nil
        }
        
        return NSDictionary.init(dictionary: resultMap)
    }
    
    static func getBlobWithDigest(_ digest: String) -> Blob? {
        // mBlobs needs to be thread safe because of Queries
        objc_sync_enter(mBlobs)
        defer {
            objc_sync_exit(mBlobs)
        }
        
        return mBlobs[digest]
    }
    
    static func setBlobWithDigest(_ digest: String, blob: Blob) {
        // mBlobs needs to be thread safe because of Queries
        objc_sync_enter(mBlobs)
        defer {
            objc_sync_exit(mBlobs)
        }
        
        mBlobs[digest] = blob
    }
    
    static func clearBlobCache() {
        // mBlobs needs to be thread safe because of Queries
        objc_sync_enter(mBlobs)
        defer {
            objc_sync_exit(mBlobs)
        }
        
        mBlobs.removeAll()
    }
    
    private func _documentToMap(_ doc: Document) -> [String: Any] {
        var parsed: [String: Any] = [:]
        for key in doc.keys {
            parsed[key] = CBManager.convertGETValue(doc.value(forKey: key))
        }
        
        return parsed
    }
    
    func initDatabaseWithName(name: String) throws -> Database {
        if let database = mDatabase[name] {
            return database
        } else {
            let newDatabase = try Database(name: name,config: mDBConfig)
            mDatabase[name] = newDatabase
            return newDatabase
        }
    }
    
    func deleteDatabaseWithName(name: String) throws {
        if let _db = mDatabase.removeValue(forKey: name) {
            try _db.delete()
        } else {
            try Database.delete(withName: name)
        }
    }
    
    func closeDatabaseWithName(name: String) throws {
        if let _db = mDatabase.removeValue(forKey: name) {
        
            if let token = mDatabaseListenerTokens[name] {
                _db.removeChangeListener(withToken: token)
                mDatabaseListenerTokens.removeValue(forKey: name)
            }
            
            try _db.close()
        }
    }
    
    func getDatabaseListenerToken(dbname: String) -> ListenerToken? {
        return mDatabaseListenerTokens[dbname]
    }
    
    func addDatabaseListenerToken(dbname: String, token: ListenerToken) {
        mDatabaseListenerTokens[dbname] = token
    }
    
    func removeDatabaseListenerToken(dbname: String) throws {
        
        guard let database = getDatabase(name: dbname) else {
            throw CBManagerError.DatabaseNotFound
        }
        
        if let token = mDatabaseListenerTokens[dbname] {
            database.removeChangeListener(withToken: token)
            mDatabaseListenerTokens.removeValue(forKey: dbname)
        }
    }
    
    
    func addQuery(queryId: String, query: Query, listenerToken: ListenerToken) {
        mQueries[queryId] = query;
        mQueryListenerTokens[queryId] = listenerToken;
    }
    
    func getQuery(queryId: String) -> Query? {
        return mQueries[queryId]
    }
    
    func removeQuery(queryId: String) -> Query? {
        guard let query = mQueries.removeValue(forKey: queryId) else {
            return nil
        }
        
        if let token = mQueryListenerTokens.removeValue(forKey: queryId) {
            query.removeChangeListener(withToken: token)
        }
        
        return query
    }
    
    func addReplicator(replicationId: String, replicator: Replicator, listenerTokens: [ListenerToken]) {
        mReplicators[replicationId] = replicator;
        mReplicatorListenerTokens[replicationId] = listenerTokens;
    }
    
    func getReplicator(replicationId: String) -> Replicator? {
        return mReplicators[replicationId]
    }
    
    func removeReplicator(replicationId: String) -> Replicator? {
        guard let replicator = mReplicators.removeValue(forKey: replicationId) else {
            return nil
        }
        
        if let tokens = mReplicatorListenerTokens.removeValue(forKey: replicationId) {
            tokens.forEach {(token) in
                replicator.removeChangeListener(withToken: token)
            }
        }
        
        return replicator
    }
    
    func inflateReplicator(json: Any) throws -> Replicator {
        guard let map = json as? [String:Any], let config = map["config"] else {
            throw CBManagerError.MissingArgument
        }
        
        return try Replicator(config: inflateReplicatorConfiguration(json: config))
    }
    
    func inflateReplicatorConfiguration(json: Any) throws -> ReplicatorConfiguration {
        guard let map = json as? [String:Any], let dbname = map["database"] as? String, let target = map["target"] as? String else {
            throw CBManagerError.MissingArgument
        }
        
        guard let database = getDatabase(name: dbname) else {
            throw CBManagerError.DatabaseNotFound
        }
        
        let config = ReplicatorConfiguration(database: database, target: URLEndpoint(url: URL(string: target)!))
        
        if let replicatorType = map["replicatorType"] as? String {
            if (replicatorType == "PUSH") {
                config.replicatorType = .push
            } else if (replicatorType == "PULL") {
                config.replicatorType = .pull
            } else if (replicatorType == "PUSH_AND_PULL") {
                config.replicatorType = .pushAndPull
            } else {
                throw CBManagerError.IllegalArgument
            }
        }
        
        if let continuous = map["continuous"] as? Bool {
            config.continuous = continuous
        }
        
        if let delegate = mDelegate, let pinnedServerCertificate = map["pinnedServerCertificate"] as? String {
            let key = delegate.lookupKey(forAsset: pinnedServerCertificate)
            
            if let path = Bundle.main.path(forResource: key, ofType: nil), let data = NSData(contentsOfFile: path) {
                config.pinnedServerCertificate = SecCertificateCreateWithData(nil,data)
            } else {
                throw CBManagerError.CertificatePinning
            }
        }
        
        if let channels = map["channels"] as? [Any] {
            config.channels = channels.compactMap { $0 as? String }
        }

        if let pushFilters = map["pushAttributeFilters"] as? [String:[Any?]] {
            config.pushFilter = CBManager.inflateReplicationFilter(pushFilters)
        }

        if let pullFilters = map["pullAttributeFilters"] as? [String:[Any?]] {
            config.pullFilter = CBManager.inflateReplicationFilter(pullFilters)
        }

        if let headers = map["headers"] as? Dictionary<String,Any> {
            config.headers = headers.mapValues { $0 as? String ?? "" }
        }

        config.authenticator = try inflateAuthenticator(json: map["authenticator"])
        
        return config
    }
    
    static func docValueEquals(_ x : Any?, _ y : Any?) -> Bool {
        guard x is AnyHashable else { return false }
        guard y is AnyHashable else { return false }
        return (x as! AnyHashable) == (y as! AnyHashable)
    }

    func inflateAuthenticator(json: Any?) throws -> Authenticator? {
        guard let map = json as? Dictionary<String,Any> else {
            return nil
        }
        
        switch map["method"] as! String {
        case "basic":
            guard let username = map["username"] as? String, let password = map["password"] as? String else {
                throw CBManagerError.MissingArgument
            }
            
            return BasicAuthenticator(username: username, password: password)
        case "session":
            guard let sessionId = map["sessionId"] as? String else {
                throw CBManagerError.MissingArgument
            }
            
            return SessionAuthenticator(sessionID: sessionId, cookieName: map["cookieName"] as? String)
        default:
            throw CBManagerError.IllegalArgument
        }
    }

    static func inflateReplicationFilter(_ filterConfig: [String:[Any?]]) -> CouchbaseLiteSwift.ReplicationFilter {
        let filterValues: [String:[Any?]] = filterConfig.compactMapValues { $0.compactMap { CBManager.convertSETValue($0) } }
        return { (document, flags) in
            for (key, values) in filterValues {
                guard document.contains(key: key) else {
                    return false
                }

                let docValue = document.value(forKey: key);
                let matches = values.contains { (value) -> Bool in
                    return CBManager.docValueEquals(value,docValue)
                }
                if !matches {
                    return false
                }
            }
            return true
        }
    }
}
