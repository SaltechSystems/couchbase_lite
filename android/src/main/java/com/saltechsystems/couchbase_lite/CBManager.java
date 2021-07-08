package com.saltechsystems.couchbase_lite;

import android.content.res.AssetManager;

import com.couchbase.lite.Array;
import com.couchbase.lite.Blob;
import com.couchbase.lite.ConcurrencyControl;
import com.couchbase.lite.CouchbaseLiteException;
import com.couchbase.lite.Database;
import com.couchbase.lite.DatabaseConfiguration;
import com.couchbase.lite.Dictionary;
import com.couchbase.lite.Document;
import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.LogLevel;
import com.couchbase.lite.MutableDocument;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.Query;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

class CBManager {
    private HashMap<String, Database> mDatabase = new HashMap<>();
    private HashMap<String, Query> mQueries = new HashMap<>();
    private final static HashMap<String, Blob> mBlobs = new HashMap<>();
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

    static void setConsoleLogLevel(LogLevel logLevel) {
        Database.log.getConsole().setLevel(logLevel);
    }

    Database getDatabase(String name) {
        if (mDatabase.containsKey(name)) {
            return mDatabase.get(name);
        }
        return null;
    }

    Map<String, Object> saveDocument(Database database, Map<String, Object> _map, ConcurrencyControl concurrencyControl) throws CouchbaseLiteException {
        MutableDocument mutableDoc = new MutableDocument(convertSETDictionary(_map));
        boolean success = database.save(mutableDoc, concurrencyControl);
        HashMap<String, Object> resultMap = new HashMap<>();
        resultMap.put("success", success);
        if (success) {
            resultMap.put("id", mutableDoc.getId());
            resultMap.put("sequence", mutableDoc.getSequence());
            resultMap.put("doc", _documentToMap(mutableDoc));
        }
        return resultMap;
    }

    Map<String, Object> saveDocumentWithId(Database database, String _id, Map<String, Object> _map, ConcurrencyControl concurrencyControl) throws CouchbaseLiteException {
        HashMap<String, Object> resultMap = new HashMap<>();
        MutableDocument mutableDoc = new MutableDocument(_id, convertSETDictionary(_map));

        boolean success = database.save(mutableDoc, concurrencyControl);

        resultMap.put("success", success);
        if (success) {
            resultMap.put("id", mutableDoc.getId());
            resultMap.put("sequence", mutableDoc.getSequence());
            resultMap.put("doc", _documentToMap(mutableDoc));
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

        mutableDoc.setData(convertSETDictionary(_map));

        boolean success = database.save(mutableDoc, concurrencyControl);

        resultMap.put("success", success);
        if (success) {
            resultMap.put("id", mutableDoc.getId());
            resultMap.put("sequence", mutableDoc.getSequence());
            resultMap.put("doc", _documentToMap(mutableDoc));
        }
        return resultMap;
    }

    static Blob getBlobWithDigest(String digest) {
        synchronized (mBlobs) {
            return mBlobs.get(digest);
        }
    }

    static void setBlobWithDigest(String digest, Blob blob) {
        synchronized (mBlobs) {
            mBlobs.put(digest, blob);
        }
    }

    static void clearBlobCache() {
        synchronized (mBlobs) {
            mBlobs.clear();
        }
    }

    private Map<String, Object> _documentToMap(Document doc) {
        HashMap<String,Object> parsed = new HashMap<>();
        for (String key: doc.getKeys()) {
            parsed.put(key, convertGETValue(doc.getValue(key)));
        }

        return parsed;
    }

    static Object convertSETValue(Object value) {
        if (value instanceof Map<?, ?>) {
            Map<String, Object> result = convertSETDictionary(getMapFromGenericMap(value));

            if (Objects.equals(result.get("@type"), "blob")) {
                Object dataObject = result.get("data");
                Object contentTypeObject = result.get("content_type");
                if (!(result.get("digest") instanceof String) && dataObject instanceof byte[] && contentTypeObject instanceof String) {
                    String contentType = (String) contentTypeObject;
                    byte[] content = (byte[]) dataObject;
                    return new Blob(contentType,content);
                } else {
                    // Prevent blob from updating when it doesn't change
                    return result;
                }
            } else {
                return result;
            }
        } else if (value instanceof List<?>) {
            return convertSETArray(getListFromGenericList(value));
        } else {
            return value;
        }
    }

    static Map<String, Object> convertSETDictionary(Map<String, Object> _map) {
        if (_map == null) {
            return null;
        }

        HashMap<String,Object> result = new HashMap<>();
        for (Map.Entry<String,Object> entry: _map.entrySet()) {
            result.put(entry.getKey(), convertSETValue(entry.getValue()));
        }

        return result;
    }

    static List<Object> convertSETArray(List<Object> array) {
        if (array == null) {
            return null;
        }

        List<Object> rtnList = new ArrayList<>();
        for (Object value: array) {
            rtnList.add(convertSETValue(value));
        }

        return rtnList;
    }

    static Map<String,Object> convertGETDictionary(Dictionary dict) {
        HashMap<String, Object> rtnMap = new HashMap<>();
        for (String key: dict.getKeys()) {
            rtnMap.put(key, convertGETValue(dict.getValue(key)));
        }

        return rtnMap;
    }

    static List<Object> convertGETArray(Array array) {
        List<Object> rtnList = new ArrayList<>();
        for (int idx = 0; idx < array.count(); idx++) {
            rtnList.add(convertGETValue(array.getValue(idx)));
        }

        return rtnList;
    }

    static Object convertGETValue(Object value) {
        if (value instanceof Blob) {
            Blob blob = (Blob) value;
            String digest = blob.digest();
            if (digest != null) {
                // Store the blob for retrieving the content
                setBlobWithDigest(digest,blob);
            }

            // Don't return the data, JSONMessageCodec doesn't support it
            HashMap<String,Object> json = new HashMap<>();
            json.put("content_type", blob.getContentType());
            json.put("digest", digest);
            json.put("length", blob.length());
            json.put("@type","blob");
            return json;
        } else if (value instanceof Dictionary){
            return convertGETDictionary((Dictionary) value);
        } else if (value instanceof Array){
            return convertGETArray((Array) value);
        } else {
            return value;
        }
    }

    private static Map<String, Object> getMapFromGenericMap(Object objectMap) {
        Map<String, Object> resultMap = new HashMap<>();
        if (objectMap instanceof Map<?, ?>) {
            Map<?,?> genericMap = (Map<?,?>) objectMap;
            for (Map.Entry<?, ?> entry : genericMap.entrySet()) {
                resultMap.put((String) entry.getKey(), entry.getValue());
            }
        }
        return resultMap;
    }

    private static List<Object> getListFromGenericList(Object objectList) {
        List<Object> resultList = new ArrayList<>();
        if (objectList instanceof List<?>) {
            List<?> genericList = (List<?>) objectList;
            resultList.addAll(genericList);
        }
        return resultList;
    }

    static List<Map<String, Object>> getListOfMapsFromGenericList(Object objectList) {
        List<Map<String, Object>> rtnList = new ArrayList<>();
        if (objectList instanceof List<?>) {
            List<?> genericList = (List<?>) objectList;
            for (Object objectMap : genericList) {
                rtnList.add(getMapFromGenericMap(objectMap));
            }
        }
        return rtnList;
    }

    Map<String, Object> getDocumentWithId(Database database, String _id) {
        HashMap<String, Object> resultMap = new HashMap<>();

        Document document = database.getDocument(_id);
        if (document != null) {
            resultMap.put("doc", _documentToMap(document));
            resultMap.put("id", document.getId());
            resultMap.put("sequence", document.getSequence());
        } else {
            resultMap.put("doc", null);
            resultMap.put("id", _id);
        }

        return resultMap;
    }

    void deleteDocumentWithId(Database database, String _id) throws CouchbaseLiteException {
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

        try (ByteArrayOutputStream buffer = new ByteArrayOutputStream(); InputStream is = assetManager.open(fileKey)) {
            int nRead;
            byte[] data = new byte[1024];
            while ((nRead = is.read(data, 0, data.length)) != -1) {
                buffer.write(data, 0, nRead);
            }

            buffer.flush();
            return buffer.toByteArray();
        }
    }
}
