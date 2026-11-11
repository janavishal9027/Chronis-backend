package com.chronis.coaching;

import com.fasterxml.jackson.databind.node.ObjectNode;

public interface CoachingProvider {
    ObjectNode turn(String provider,String model,String key,ObjectNode context,String expectedKind);
    String transcribe(String provider,String model,String key,byte[] audio,String mime);
}
