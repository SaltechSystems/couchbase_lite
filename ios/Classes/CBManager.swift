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
    private var mReplicatorListenerTokens : Dictionary<String,ListenerToken> = Dictionary();
    private var mDBConfig = DatabaseConfiguration();
    private weak var mDelegate: CBManagerDelegate?
    
    init(delegate: CBManagerDelegate, enableLogging: Bool) {
        mDelegate = delegate
        
        guard enableLogging else {
            return
        }
        
        let tempFolder = NSTemporaryDirectory().appending("cbllog")
        Database.log.file.config = LogFileConfiguration(directory: tempFolder)
        Database.log.file.level = .info
    }
    
    func getDatabase(name : String) -> Database? {
        if let result = mDatabase[name] {
            return result;
        } else {
            return nil;
        }
    }
    
    func saveDocument(database: Database, map: Dictionary<String, Any>) throws -> String? {
        let mutableDocument: MutableDocument = MutableDocument(data: map);
        try database.saveDocument(mutableDocument)
        return mutableDocument.id;
    }
    
    func saveDocumentWithId(database: Database, id: String, map: Dictionary<String, Any>) throws -> String? {
        let mutableDocument: MutableDocument = MutableDocument(id: id, data: map)
        try database.saveDocument(mutableDocument)
        return mutableDocument.id
    }
    
    func deleteDocumentWithId(database: Database, id: String) throws {
        if let document = database.document(withID: id) {
            try database.deleteDocument(document)
        }
    }
    
    func getDocumentWithId(database: Database, id: String) -> NSDictionary? {
        let resultMap: NSMutableDictionary = NSMutableDictionary.init()
        if let document: Document = database.document(withID: id) {
            let retrievedDocument: NSDictionary = NSDictionary.init(dictionary: document.toDictionary())
            // It is a repetition due to implementation of Document Dart Class
            resultMap["id"] = id
            resultMap["doc"] = retrievedDocument
        } else {
            resultMap["id"] = id
            resultMap["doc"] = NSDictionary.init()
        }
        return NSDictionary.init(dictionary: resultMap)
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
        try Database.delete(withName: name)
    }
    
    func closeDatabaseWithName(name: String) throws {
        if let _db = mDatabase.removeValue(forKey: name) {
            try _db.close()
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
    
    func addReplicator(replicationId: String, replicator: Replicator, listenerToken: ListenerToken) {
        mReplicators[replicationId] = replicator;
        mReplicatorListenerTokens[replicationId] = listenerToken;
    }
    
    func getReplicator(replicationId: String) -> Replicator? {
        return mReplicators[replicationId]
    }
    
    func removeReplicator(replicationId: String) -> Replicator? {
        guard let replicator = mReplicators.removeValue(forKey: replicationId) else {
            return nil
        }
        
        if let token = mReplicatorListenerTokens.removeValue(forKey: replicationId) {
            replicator.removeChangeListener(withToken: token)
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
        guard let map = json as? Dictionary<String,String> else {
            return nil
        }
        
        switch map["method"] {
        case "basic":
            guard let username = map["username"], let password = map["password"] else {
                throw CBManagerError.MissingArgument
            }
            
            return BasicAuthenticator(username: username, password: password)
        case "session":
            guard let sessionId = map["sessionId"] else {
                throw CBManagerError.MissingArgument
            }
            
            return SessionAuthenticator(sessionID: sessionId, cookieName: map["cookieName"])
        default:
            throw CBManagerError.IllegalArgument
        }
    }
}
