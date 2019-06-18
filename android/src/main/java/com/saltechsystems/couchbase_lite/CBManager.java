package com.saltechsystems.couchbase_lite;

import android.content.res.AssetManager;

import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.DatabaseConfiguration;
import com.couchbase.lite.Document;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.LogFileConfiguration;
import com.couchbase.lite.LogLevel;
import com.couchbase.lite.MutableDocument;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.Query;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

class CBManager {
    private HashMap<String, Database> mDatabase = new HashMap<>();
    private HashMap<String, Query> mQueries = new HashMap<>();
    private HashMap<String, ListenerToken> mQueryListenerTokens = new HashMap<>();
    private HashMap<String, Replicator> mReplicators = new HashMap<>();
    private HashMap<String, ListenerToken> mReplicatorListenerTokens = new HashMap<>();
    private DatabaseConfiguration mDBConfig;
    private CBManagerDelegate mDelegate;

    CBManager(CBManagerDelegate delegate, boolean enableLogging) {
        mDelegate = delegate;
        mDBConfig = new DatabaseConfiguration(mDelegate.getContext());

        if (enableLogging) {
            final File path = mDelegate.getContext().getCacheDir();
            Database.log.getFile().setConfig(new LogFileConfiguration(path.toString()));
            Database.log.getFile().setLevel(LogLevel.INFO);
        }
    }

    Database getDatabase(String name) {
        if (mDatabase.containsKey(name)) {
            return mDatabase.get(name);
        }
        return null;
    }

    String saveDocument(Database database, Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_map);
        database.save(mutableDoc);
        return mutableDoc.getId();
    }

    String saveDocumentWithId(Database database, String _id, Map<String, Object> _map) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(_id, _map);
        database.save(mutableDoc);
        return mutableDoc.getId();
    }

    Map<String, Object> getDocumentWithId(Database database, String _id) {
        HashMap<String, Object> resultMap = new HashMap<>();

        Document document = database.getDocument(_id);
        if (document != null) {
            resultMap.put("doc", document.toMap());
            resultMap.put("id", _id);
        } else {
            resultMap.put("doc", null);
            resultMap.put("id", _id);
        }

        return resultMap;
    }

    void deleteDocumentWithId(Database database, String _id) throws CouchbaseLiteException {
        HashMap<String, Object> resultMap = new HashMap<>();

        Document document = database.getDocument(_id);

        if (document != null) {
            database.delete(document);
        }
    }

    Database initDatabaseWithName(String _name) throws CouchbaseLiteException {
        if (!mDatabase.containsKey(_name)) {
            Database database = new Database(_name, mDBConfig);
            mDatabase.put(_name, database);
            return database;
        }

        return mDatabase.get(_name);
    }

    void deleteDatabaseWithName(String _name) throws CouchbaseLiteException {
        Database.delete(_name,new File(mDBConfig.getDirectory()));
    }

    void closeDatabaseWithName(String _name) throws CouchbaseLiteException {
        Database _db = mDatabase.remove(_name);
        if (_db != null) {
            _db.close();
        }
    }

    void addQuery(String queryId, Query query, ListenerToken token) {
        mQueries.put(queryId,query);
        mQueryListenerTokens.put(queryId,token);
    }

    Query getQuery(String queryId) {
        return mQueries.get(queryId);
    }

    Query removeQuery(String queryId) {
        Query query = mQueries.remove(queryId);
        ListenerToken token = mQueryListenerTokens.remove(queryId);
        if (query != null && token != null) {
            query.removeChangeListener(token);
        }

        return query;
    }

    void addReplicator(String replicatorId, Replicator replicator, ListenerToken token) {
        mReplicators.put(replicatorId,replicator);
        mReplicatorListenerTokens.put(replicatorId,token);
    }

    Replicator getReplicator(String replicatorId) {
        return mReplicators.get(replicatorId);
    }

    Replicator removeReplicator(String replicatorId) {
        Replicator replicator = mReplicators.remove(replicatorId);
        ListenerToken token = mReplicatorListenerTokens.remove(replicatorId);
        if (replicator != null && token != null) {
            replicator.removeChangeListener(token);
        }

        return replicator;
    }

    byte[] getAssetByteArray(String assetKey) throws IOException {
        AssetManager assetManager = mDelegate.getAssets();
        String fileKey = mDelegate.lookupKeyForAsset(assetKey);

        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        try (InputStream is = assetManager.open(fileKey)) {
            int nRead;
            byte[] data = new byte[1024];
            while ((nRead = is.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }

            buffer.flush();
            return buffer.toByteArray();
        } finally {
            buffer.close();
        }
    }
}
