package com.saltechsystems.couchbase_lite;


import androidx.annotation.NonNull;

import com.couchbase.lite.BasicAuthenticator;
import com.couchbase.lite.Database;
import com.couchbase.lite.Document;
import com.couchbase.lite.DocumentFlag;
import com.couchbase.lite.Endpoint;
import com.couchbase.lite.ReplicationFilter;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.ReplicatorConfiguration;
import com.couchbase.lite.SessionAuthenticator;
import com.couchbase.lite.URLEndpoint;

import org.json.JSONObject;
import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Objects;

import io.flutter.plugin.common.JSONUtil;

class ReplicatorJson {
    private ReplicatorMap replicatorMap;
    private CBManager mCBManager;
    private ReplicatorConfiguration mReplicatorConfig;

    ReplicatorJson(JSONObject json, CBManager manager) {
        this.mCBManager = manager;
        this.replicatorMap = new ReplicatorMap(json);
    }

    Replicator toCouchbaseReplicator() {
        if (replicatorMap.hasConfig) {
//            try {
//
//            } catch (Exception e) {
//
//            }
            inflateConfig();
        }

        if (mReplicatorConfig != null) {
            return new Replicator(mReplicatorConfig);
        } else {
            return null;
        }
    }

    private void inflateConfig() {
        if (!replicatorMap.hasDatabase || !replicatorMap.hasTarget) throw new IllegalArgumentException();

        Database database = mCBManager.getDatabase(replicatorMap.database);
        if (database == null) {
            throw new IllegalArgumentException("Database not found: " + replicatorMap.database);
        }

        Endpoint endpoint = new URLEndpoint(URI.create(replicatorMap.target));

        mReplicatorConfig = new ReplicatorConfiguration(database,endpoint);

        if (replicatorMap.hasReplicatorType) {
            switch (replicatorMap.replicatorType) {
                case "PUSH":
                    mReplicatorConfig.setReplicatorType(ReplicatorConfiguration.ReplicatorType.PUSH);
                    break;
                case "PULL":
                    mReplicatorConfig.setReplicatorType(ReplicatorConfiguration.ReplicatorType.PULL);
                    break;
                case "PUSH_AND_PULL":
                    mReplicatorConfig.setReplicatorType(ReplicatorConfiguration.ReplicatorType.PUSH_AND_PULL);
                    break;
                default:
                    throw new IllegalArgumentException("Invalid replicator type: " + replicatorMap.replicatorType);
            }
        }

        if (replicatorMap.hasContinuous) {
            mReplicatorConfig.setContinuous(replicatorMap.continuous);
        }

        if (replicatorMap.hasPinnedServerCertificate) {
            try {
                byte[] cert = mCBManager.getAssetByteArray(replicatorMap.pinnedServerCertificate);
                mReplicatorConfig.setPinnedServerCertificate(cert);
            } catch (IOException e) {
                throw new IllegalArgumentException("Failed to load certificate: " + replicatorMap.pinnedServerCertificate);
            }
        }

        if (replicatorMap.channels != null) {
            mReplicatorConfig.setChannels(replicatorMap.channels);
        }

        if (replicatorMap.pushAttributeKeyFilter != null &&
            replicatorMap.pushAttributeValuesFilter != null) {
            mReplicatorConfig.setPushFilter(new ReplicationFilter() {
                @Override
                public boolean filtered(@NonNull Document document,
                                        @NonNull EnumSet<DocumentFlag> flags) {
                    if (!document.contains(replicatorMap.pushAttributeKeyFilter)) {
                        return false;
                    }

                    Object value = document.getValue(replicatorMap.pushAttributeKeyFilter);
                    return replicatorMap.pushAttributeValuesFilter.contains(value);
                }
            });
        }

        if (replicatorMap.headers != null) {
            mReplicatorConfig.setHeaders(replicatorMap.headers);
        }

        if (replicatorMap.hasAuthenticator) {
            inflateAuthenticator();
        }
    }

    private void inflateAuthenticator() {
        if (!replicatorMap.authenticator.containsKey("method")) throw new IllegalArgumentException("Missing authentication method");

        String method = (String) replicatorMap.authenticator.get("method");

        assert method != null;
        switch (method) {
            case "basic":
                if (!replicatorMap.authenticator.containsKey("username") || !replicatorMap.authenticator.containsKey("password")) throw new IllegalArgumentException("Missing username or password");
                String username = (String) replicatorMap.authenticator.get("username");
                String password = (String) replicatorMap.authenticator.get("password");
                assert username != null;
                assert password != null;
                mReplicatorConfig.setAuthenticator(new BasicAuthenticator(username,password));
                break;
            case "session":
                if (!replicatorMap.authenticator.containsKey("sessionId")) throw new IllegalArgumentException("Missing sessionId");
                String sessionId = (String) replicatorMap.authenticator.get("sessionId");
                String cookieName = (String) replicatorMap.authenticator.get("cookieName");
                assert sessionId != null;
                mReplicatorConfig.setAuthenticator(new SessionAuthenticator(sessionId,cookieName));
                break;
            default:
                throw new IllegalArgumentException("Invalid authentication method: " + method);
        }
    }
}

class ReplicatorMap {
    private Map<String, Object> replicatorMap;
    boolean hasConfig = false;
    Map<String, Object> config;
    boolean hasDatabase = false;
    String database;
    boolean hasTarget = false;
    String target;
    boolean hasReplicatorType = false;
    String replicatorType;
    boolean hasContinuous = false;
    boolean continuous;
    boolean hasPinnedServerCertificate = false;
    String pinnedServerCertificate;
    boolean hasAuthenticator = false;
    Map<String, Object> authenticator;
    List<String> channels;
    String pushAttributeKeyFilter;
    List<Object> pushAttributeValuesFilter;
    Map<String, String> headers;


    ReplicatorMap(JSONObject jsonObject) {
        Object unwrappedJson = JSONUtil.unwrap(jsonObject);
        if (unwrappedJson instanceof Map<?, ?>) {
            this.replicatorMap = getMapFromGenericMap(unwrappedJson);
        }
        if (replicatorMap.containsKey("config")) {
            hasConfig = true;
            config = getMap("config");
            if (config.containsKey("database")) {
                hasDatabase = true;
                database = (String) this.config.get("database");
            }
            if (config.containsKey("target")) {
                hasTarget = true;
                target = (String) this.config.get("target");
            }
            if (config.containsKey("replicatorType")) {
                hasReplicatorType = true;
                replicatorType = (String) this.config.get("replicatorType");
            }
            if (config.containsKey("continuous")) {
                hasContinuous = true;
                Object continuousObject = config.get("continuous");
                if (continuousObject instanceof Boolean) {
                    continuous = (Boolean) continuousObject;
                }
            }
            if (config.containsKey("pinnedServerCertificate")) {
                hasPinnedServerCertificate = true;
                pinnedServerCertificate = (String) config.get("pinnedServerCertificate");
            }
            if (config.containsKey("authenticator")) {
                Object mapObject = config.get("authenticator");
                if (mapObject instanceof Map<?, ?>) {
                    hasAuthenticator = true;
                    authenticator = getMapFromGenericMap(mapObject);
                }
            }

            if (config.containsKey("channels")) {
                Object listObject = config.get("channels");
                if (listObject instanceof List<?>) {
                    channels = getListFromGenericList(listObject);
                }
            }

            if (config.containsKey("pushAttributeValuesFilter")) {
                Object listObject = config.get("pushAttributeValuesFilter");
                if (listObject instanceof List<?>) {
                    List<Object> pushValues = new ArrayList<>();
                    for (Object object : ((List<?>)listObject)) {
                        pushValues.add(Objects.toString(object, null));
                    }

                    pushAttributeValuesFilter = CBManager.convertSETArray(pushValues);
                }
            }

            if (config.containsKey("pushAttributeKeyFilter")) {
                Object pushKeyObject = config.get("pushAttributeKeyFilter");
                if (pushKeyObject instanceof String) {
                    pushAttributeKeyFilter = (String) pushKeyObject;
                }
            }

            if (config.containsKey("headers")) {
                Object mapObject = config.get("headers");
                if (mapObject instanceof Map<?, ?>) {
                    headers = getMapOfStringsFromGenericMap(mapObject);
                }
            }
        }
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

    private Map<String, String> getMapOfStringsFromGenericMap(Object objectMap) {
        Map<String, String> resultMap = new HashMap<>();
        if (objectMap instanceof Map<?, ?>) {
            Map<?,?> genericMap = (Map<?,?>) objectMap;
            for (Map.Entry<?, ?> entry : genericMap.entrySet()) {
                resultMap.put((String) entry.getKey(), Objects.toString(entry.getValue(), ""));
            }
        }
        return resultMap;
    }

    private List<String> getListFromGenericList(Object objectList) {
        List<String> resultList = new ArrayList<>();
        if (objectList instanceof List<?>) {
            List<?> genericList = (List<?>) objectList;
            for (Object object : genericList) {
                resultList.add(Objects.toString(object, null));
            }
        }
        return resultList;
    }

    private Map<String, Object> getMap(String key) {
        Object mapObject = replicatorMap.get(key);
        if (mapObject instanceof Map<?, ?>) {
            return getMapFromGenericMap(mapObject);
        }

        return new HashMap<>();
    }
}
