package com.saltechsystems.couchbase_lite;

import android.content.res.AssetManager;

import com.couchbase.lite.BasicAuthenticator;
import com.couchbase.lite.Database;
import com.couchbase.lite.Endpoint;
import com.couchbase.lite.Query;
import com.couchbase.lite.Replicator;
import com.couchbase.lite.ReplicatorConfiguration;
import com.couchbase.lite.SessionAuthenticator;
import com.couchbase.lite.URLEndpoint;

import org.json.JSONObject;
import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

import io.flutter.plugin.common.JSONUtil;

class ReplicatorJson {
    private ReplicatorMap replicatorMap;
    private Query query = null;
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

        if (replicatorMap.hasAuthenticator) {
            inflateAuthenticator();
        }
    }

    private void inflateAuthenticator() {
        if (!replicatorMap.authenticator.containsKey("method")) throw new IllegalArgumentException("Missing authentication method");

        String method = (String) replicatorMap.authenticator.get("method");

        switch (method) {
            case "basic":
                if (!replicatorMap.authenticator.containsKey("username") || !replicatorMap.authenticator.containsKey("password")) throw new IllegalArgumentException("Missing username or password");
                String username = (String) replicatorMap.authenticator.get("username");
                String password = (String) replicatorMap.authenticator.get("password");
                mReplicatorConfig.setAuthenticator(new BasicAuthenticator(username,password));
                break;
            case "session":
                if (!replicatorMap.authenticator.containsKey("sessionId")) throw new IllegalArgumentException("Missing sessionId");
                String sessionId = (String) replicatorMap.authenticator.get("sessionId");
                String cookieName = (String) replicatorMap.authenticator.get("cookieName");
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
    List channels;

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
                continuous = (Boolean) config.get("continuous");
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
                channels = (List) config.get("channels");
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

    private Map<String, Object> getMap(String key) {
        Object mapObject = replicatorMap.get(key);
        if (mapObject instanceof Map<?, ?>) {
            return getMapFromGenericMap(mapObject);
        }

        return new HashMap<>();
    }
}
