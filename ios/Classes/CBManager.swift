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
        let mutableDocument: MutableDocument = MutableDocument(data: DataConverter.convertSETDictionary(map));
        let success = try database.saveDocument(mutableDocument, concurrencyControl: concurrencyControl)
        resultMap["success"] = success
        if (success) {
            resultMap["id"] = mutableDocument.id
            resultMap["sequence"] = mutableDocument.sequence
            resultMap["doc"] = CBManager._documentToMap(mutableDocument)
        }
        return resultMap
    }
    
    func saveDocumentWithId(database: Database, id: String, map: Dictionary<String, Any>, concurrencyControl: ConcurrencyControl) throws -> NSMutableDictionary {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        let mutableDocument: MutableDocument = MutableDocument(id: id, data: DataConverter.convertSETDictionary(map))
        let success = try database.saveDocument(mutableDocument, concurrencyControl: concurrencyControl)
        resultMap["success"] = success
        if (success) {
            resultMap["id"] = mutableDocument.id
            resultMap["sequence"] = mutableDocument.sequence
            resultMap["doc"] = CBManager._documentToMap(mutableDocument)
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
        mutableDocument.setData(DataConverter.convertSETDictionary(map, origin: document?.toDictionary()))
        
        let success = try database.saveDocument(mutableDocument, concurrencyControl: concurrencyControl)
        resultMap["success"] = success
        if (success) {
            resultMap["id"] = mutableDocument.id
            resultMap["sequence"] = mutableDocument.sequence
            resultMap["doc"] = CBManager._documentToMap(mutableDocument)
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
            resultMap["doc"] = NSDictionary.init(dictionary:CBManager._documentToMap(document))
        } else {
            resultMap["id"] = id
            resultMap["doc"] = nil
        }
        
        return NSDictionary.init(dictionary: resultMap)
    }
    
    private static func _documentToMap(_ doc: Document) -> [String: Any] {
        var parsed: [String: Any] = [:]
        for key in doc.keys {
            parsed[key] = _valueToJson(doc.value(forKey: key), withData: false)
        }
        
        return parsed
    }
    
    static func _dictionaryToJson(_ dict: DictionaryObject) -> [String: Any?] {
        var rtnMap: [String: Any] = [:]
        for key in dict.keys {
            rtnMap[key] = _valueToJson(dict[key].value, withData: true)
        }
        
        return rtnMap
    }
    
    static func _arrayToJson(_ array: ArrayObject) -> [Any?] {
        var rtnList: [Any?] = [];
        for idx in 0..<array.count {
            rtnList.append(_valueToJson(array[idx].value, withData: true))
        }
        return rtnList
    }
    
    static func _valueToJson(_ value: Any?, withData: Bool) -> Any? {
        switch (value) {
        case let blob as Blob:
            if (withData) {
                return [
                    "content_type": blob.contentType as Any,
                    "digest": blob.digest as Any,
                    "length": blob.length,
                    "data": blob.content as Any,
                    "@type": "blob"
                ]
            } else {
                return [
                    "content_type": blob.contentType as Any,
                    "digest": blob.digest as Any,
                    "length": blob.length,
                    "@type": "blob"
                ]
            }
        case let dict as DictionaryObject:
            return _dictionaryToJson(dict)
        case let array as ArrayObject:
            return _arrayToJson(array)
        default:
            return value
        }
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
        
        config.authenticator = try inflateAuthenticator(json: map["authenticator"])
        
        return config
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
}
