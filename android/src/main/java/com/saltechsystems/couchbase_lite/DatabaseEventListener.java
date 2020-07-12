package com.saltechsystems.couchbase_lite;

import io.flutter.plugin.common.EventChannel;

public class DatabaseEventListener implements EventChannel.StreamHandler {
    public EventChannel.EventSink mEventSink;

    /*
     * IMPLEMENTATION OF EVENTCHANNEL.STREAMHANDLER
     */

    @Override
    public void onListen(Object args, final EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
    }

    @Override
    public void onCancel(Object args) {
        mEventSink = null;
    }
}
