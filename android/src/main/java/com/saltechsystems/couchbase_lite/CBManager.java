package com.saltechsystems.couchbase_lite;

import android.content.res.AssetManager;
import android.os.Debug;

import com.couchbase.lite.Blob;
import com.couchbase.lite.ConcurrencyControl;
import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.DatabaseConfiguration;
import com.couchbase.lite.Document;
import com.couchbase.lite.IndexBuilder;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.LogFileConfiguration;
import com.couchbase.lite.LogLevel;
import com.couchbase.lite.MutableDocument;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.Query;
import com.couchbase.lite.ValueIndexItem;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;

class CBManager {
    private HashMap<String, Database> mDatabase = new HashMap<>();
    private HashMap<String, Query> mQueries = new HashMap<>();
    private HashMap<String, ListenerToken> mQueryListenerTokens = new HashMap<>();
    private HashMap<String, Replicator> mReplicators = new HashMap<>();
    private HashMap<String, ListenerToken[]> mReplicatorListenerTokens = new HashMap<>();
    private HashMap<String, ListenerToken> mDatabaseListenerTokens = new HashMap<>();
    private DatabaseConfiguration mDBConfig;
    private CBManagerDelegate mDelegate;

    CBManager(CBManagerDelegate delegate, LogLevel logLevel) {
        mDelegate = delegate;
        mDBConfig = new DatabaseConfiguration();

        Database.log.getConsole().setLevel(logLevel);
    }

    Database getDatabase(String name) {
        if (mDatabase.containsKey(name)) {
            return mDatabase.get(name);
        }
        return null;
    }

    Map<String, Object> saveDocument(Database database, Map<String, Object> _map, ConcurrencyControl concurrencyControl) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(getParsedMap(_map, null));
        boolean success = database.save(mutableDoc, concurrencyControl);
        HashMap<String, Object> resultMap = new HashMap<>();
        resultMap.put("success", success);
        if (success) {
            resultMap.put("id", mutableDoc.getId());
            resultMap.put("sequence", mutableDoc.getSequence());
            resultMap.put("doc", getJSONMap(mutableDoc.toMap()));
        }
        return resultMap;
    }

    Map<String, Object> saveDocumentWithId(Database database, String _id, Map<String, Object> _map, ConcurrencyControl concurrencyControl) throws CouchbaseLiteException {
        HashMap<String, Object> resultMap = new HashMap<>();
        MutableDocument mutableDoc = new MutableDocument(_id, getParsedMap(_map, null));

        boolean success = database.save(mutableDoc, concurrencyControl);

        resultMap.put("success", success);
        if (success) {
            resultMap.put("id", mutableDoc.getId());
            resultMap.put("sequence", mutableDoc.getSequence());
            resultMap.put("doc", getJSONMap(mutableDoc.toMap()));
        }

        return resultMap;
    }

    Map<String, Object> saveDocumentWithId(Database database, String _id, long sequence, Map<String, Object> _map, ConcurrencyControl concurrencyControl) throws CouchbaseLiteException {
        HashMap<String, Object> resultMap = new HashMap<>();
        Document document = database.getDocument(_id);

        if (document != null && document.getSequence() != sequence) {
            resultMap.put("success", false);
            return resultMap;
        }

        MutableDocument mutableDoc;
        if (document == null) {
            mutableDoc = new MutableDocument(_id);
        } else {
            mutableDoc = document.toMutable();
        }

        mutableDoc.setData(getParsedMap(_map, document.toMap()));

        boolean success = database.save(mutableDoc, concurrencyControl);

        resultMap.put("success", success);
        if (success) {
            resultMap.put("id", mutableDoc.getId());
            resultMap.put("sequence", mutableDoc.getSequence());
            resultMap.put("doc", getJSONMap(mutableDoc.toMap()));
        }
        return resultMap;
    }

    private Map<String, Object> getParsedMap(Map<String, Object> _map, Map<String, Object> doc) {
        HashMap<String,Object> parsed = new HashMap<>();
        for (Map.Entry<String,Object> entry: _map.entrySet()) {
            Object value = entry.getValue();
            if (value instanceof Map<?, ?>) {
                Map<String, Object> parsedMap;
                Object originValue = doc == null ? null : doc.get(entry.getKey());

                if (originValue instanceof Map<?,?>) {
                    parsedMap = getParsedMap(getMapFromGenericMap(value), getMapFromGenericMap(originValue));
                } else {
                    parsedMap = getParsedMap(getMapFromGenericMap(value), null);
                }

                if (parsedMap.get("@type") instanceof String && ((String) parsedMap.get("@type")).equals("blob")) {
                    if (parsedMap.get("data") instanceof byte[] && parsedMap.get("contentType") instanceof String) {
                        String contentType = (String) parsedMap.get("contentType");
                        byte[] content = (byte[]) parsedMap.get("data");
                        parsed.put(entry.getKey(), new Blob(contentType,content));
                    } else if (originValue instanceof Blob) {
                        // Prevent blob from being deleted since the data isn't passed
                        parsed.put(entry.getKey(), originValue);
                    }
                } else {
                    parsed.put(entry.getKey(), parsedMap);
                }
            } else {
                parsed.put(entry.getKey(),value);
            }
        }

        return parsed;
    }

    private Map<String, Object> getMapFromGenericMap(Object objectMap) {
        Map<String, Object> resultMap = new HashMap<>();
        if (objectMap instanceof Map<?, ?>) {
            Map<?,?> genericMap = (Map<?,?>) objectMap;
            for (Map.Entry<?, ?> entry : genericMap.entrySet()) {
                resultMap.put((String) entry.getKey(), entry.getValue());
            }
        }
        return resultMap;
    }

    Map<String, Object> getDocumentWithId(Database database, String _id) {
        HashMap<String, Object> resultMap = new HashMap<>();

        Document document = database.getDocument(_id);
        if (document != null) {
            resultMap.put("doc", getJSONMap(document.toMap()));
            resultMap.put("id", document.getId());
            resultMap.put("sequence", document.getSequence());
        } else {
            resultMap.put("doc", null);
            resultMap.put("id", _id);
        }

        return resultMap;
    }

    private Map<String, Object> getJSONMap(Map<String, Object> _map) {
        HashMap<String,Object> parsed = new HashMap<>();
        for (Map.Entry<String,Object> entry: _map.entrySet()) {
            Object value = entry.getValue();
            if (value instanceof Blob) {
                Blob blob = (Blob) value;
                HashMap<String,Object> json = new HashMap<>();
                json.put("contentType", blob.getContentType());
                json.put("digest", blob.digest());
                json.put("length", blob.length());
                json.put("@type","blob");
                parsed.put(entry.getKey(),json);
            } else {
                parsed.put(entry.getKey(),entry.getValue());
            }
        }

        return parsed;
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
        Database _db = mDatabase.remove(_name);
        if (_db != null) {
            _db.delete();
        } else {
            Database.delete(_name, new File(mDBConfig.getDirectory()));
        }
    }

    void closeDatabaseWithName(String _name) throws CouchbaseLiteException {
        removeDatabaseListenerToken(_name);
        Database _db = mDatabase.remove(_name);
        if (_db != null) {
            _db.close();
        }
    }

    ListenerToken getDatabaseListenerToken(String dbname) {
        return mDatabaseListenerTokens.get(dbname);
    }

    void addDatabaseListenerToken(String dbname, ListenerToken token) {
        mDatabaseListenerTokens.put(dbname, token);
    }

    void removeDatabaseListenerToken(String dbname) {
        Database _db = mDatabase.get(dbname);
        ListenerToken token = mDatabaseListenerTokens.remove(dbname);
        if (_db != null && token != null) {
            _db.removeChangeListener(token);
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

    void addReplicator(String replicatorId, Replicator replicator, ListenerToken[] tokens) {
        mReplicators.put(replicatorId,replicator);
        mReplicatorListenerTokens.put(replicatorId,tokens);
    }

    Replicator getReplicator(String replicatorId) {
        return mReplicators.get(replicatorId);
    }

    Replicator removeReplicator(String replicatorId) {
        Replicator replicator = mReplicators.remove(replicatorId);
        ListenerToken[] tokens = mReplicatorListenerTokens.remove(replicatorId);
        if (replicator != null && tokens != null) {
            for (ListenerToken token : tokens) {
                replicator.removeChangeListener(token);
            }
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
